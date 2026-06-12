<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Employee;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AttendanceController extends Controller
{
    use ApiResponse;

    // GET /api/admin/attendance
    public function index(Request $request)
    {
        $query = Attendance::with('employee.user')
            ->when($request->month, fn($q) =>
                $q->whereRaw("strftime('%Y-%m', date) = ?", [$request->month])
            )
            ->when($request->date,   fn($q) => $q->whereDate('date', $request->date))
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->when($request->employee_id, fn($q) => $q->where('employee_id', $request->employee_id));

        $records = $query->latest('date')->paginate(20);

        // stats لليوم الحالي
        $todayStats = [
            'present'         => Attendance::today()->where('status', 'present')->count(),
            'late'            => Attendance::today()->where('status', 'late')->count(),
            'absent'          => Employee::active()->count() - Attendance::today()->present()->count(),
            'attendance_rate' => $this->getTodayRate(),
        ];

        return response()->json([
            'status'  => true,
            'message' => 'Attendance records fetched',
            'data'    => $records->items(),
            'stats'   => $todayStats,
            'meta'    => [
                'current_page' => $records->currentPage(),
                'last_page'    => $records->lastPage(),
                'per_page'     => $records->perPage(),
                'total'        => $records->total(),
            ],
        ]);
    }

    // POST /api/admin/attendance  (تسجيل يدوي)
    public function store(Request $request)
    {
        $request->validate([
            'employee_id' => 'required|exists:employees,id',
            'date'        => 'required|date',
            'check_in'    => 'nullable|date_format:H:i',
            'check_out'   => 'nullable|date_format:H:i',
            'status'      => 'required|in:present,late,absent,on_leave',
            'notes'       => 'nullable|string',
        ]);

        $attendance = Attendance::updateOrCreate(
            ['employee_id' => $request->employee_id, 'date' => $request->date],
            [
                'check_in'         => $request->check_in,
                'check_out'        => $request->check_out,
                'status'           => $request->status,
                'check_in_source'  => 'manual',
                'check_out_source' => $request->check_out ? 'manual' : null,
                'notes'            => $request->notes,
                'total_hours'      => $this->calcHours($request->check_in, $request->check_out, $request->date),
            ]
        );

        return $this->success($attendance->load('employee.user'), 'Attendance recorded');
    }

    // GET /api/admin/attendance/stats
    public function stats(Request $request)
    {
        $month = $request->month ?? now()->format('Y-m');
        [$year, $mon] = explode('-', $month);

        return $this->success([
            'month'           => $month,
            'total_present'   => Attendance::whereRaw("strftime('%Y-%m', date)=?", [$month])->where('status','present')->count(),
            'total_late'      => Attendance::whereRaw("strftime('%Y-%m', date)=?", [$month])->where('status','late')->count(),
            'total_absent'    => Attendance::whereRaw("strftime('%Y-%m', date)=?", [$month])->where('status','absent')->count(),
            'attendance_rate' => $this->getMonthRate($year, $mon),
        ]);
    }

    // POST /api/admin/attendance/log-via-face
    public function logViaFace(Request $request)
    {
        $request->validate([
            'employee_code' => 'required|exists:employees,employee_code',
            'action'        => 'nullable|in:check_in,check_out'
        ]);

        $employee = Employee::where('employee_code', $request->employee_code)->first();
        $date = now()->format('Y-m-d');
        $time = now()->format('H:i');
        $action = $request->action; // 'check_in' or 'check_out'

        $attendance = Attendance::where('employee_id', $employee->id)->whereDate('date', $date)->first();

        // Handle Check In
        if ($action === 'check_in') {
            if ($attendance) {
                if ($attendance->check_out) {
                    return $this->success(null, 'You have already completed your attendance for today.');
                }
                if ($attendance->check_in) {
                    return $this->success($attendance, 'You are already checked in.');
                }
            }

            $shiftStart = \Carbon\Carbon::parse($employee->shift_start);
            $actualStart = \Carbon\Carbon::parse($time);
            
            // diffInMinutes with false returns positive if actualStart is before shiftStart, negative if after
            $lateMinutes = $shiftStart->diffInMinutes($actualStart, false); 
            
            if ($lateMinutes <= 15) {
                $status = 'present'; // On Time
            } elseif ($lateMinutes > 15 && $lateMinutes < 60) {
                $status = 'late';
            } else {
                $status = 'absent';
            }

            $attendance = Attendance::create([
                'employee_id'      => $employee->id,
                'date'             => $date,
                'check_in'         => $time,
                'status'           => $status,
                'check_in_source'  => 'face_recognition',
                'notes'            => 'Auto-logged via Face Recognition'
            ]);

            return $this->success($attendance, "{$employee->user->name} Checked IN via Face Recognition");
        }

        // Handle Check Out
        if ($action === 'check_out') {
            if (!$attendance || !$attendance->check_in) {
                return $this->success(null, 'Cannot check out without checking in first!');
            }

            if ($attendance->check_out) {
                return $this->success($attendance, 'You are already checked out. Please check in again tomorrow before checking out.');
            }

            $checkInTime = \Carbon\Carbon::parse("$date " . $attendance->check_in);
            if (now()->diffInMinutes($checkInTime) > 1) { // Changed cooldown to 1 minute for easier testing, though normal is 5
                $attendance->update([
                    'check_out'        => $time,
                    'check_out_source' => 'face_recognition',
                    'total_hours'      => $this->calcHours($attendance->check_in, $time, $date),
                ]);
                return $this->success($attendance, "{$employee->user->name} Checked OUT via Face Recognition");
            }
            return $this->success($attendance, 'Face recognized (Cooldown active)');
        }

        // Fallback for auto-detection (if action is null)
        if (!$action) {
            // Auto check-in if no record today
            if (!$attendance) {
                $request->merge(['action' => 'check_in']);
                return $this->logViaFace($request);
            }
            // Auto check-out if checked in but not checked out
            if ($attendance->check_in && !$attendance->check_out) {
                $request->merge(['action' => 'check_out']);
                return $this->logViaFace($request);
            }
            // If already completed today
            return $this->success($attendance, 'You have already completed your attendance for today.');
        }
    }

    private function getTodayRate(): float
    {
        $total   = Employee::active()->count();
        $present = Attendance::today()->present()->count();
        return $total > 0 ? round(($present / $total) * 100, 1) : 0;
    }

    private function getMonthRate(int $year, int $month): float
    {
        $total   = Attendance::whereYear('date', $year)->whereMonth('date', $month)->count();
        $present = Attendance::whereYear('date', $year)->whereMonth('date', $month)->present()->count();
        return $total > 0 ? round(($present / $total) * 100, 1) : 0;
    }

    private function calcHours(?string $in, ?string $out, string $date): float
    {
        if (!$in || !$out) return 0;
        $start = \Carbon\Carbon::parse("$date $in");
        $end   = \Carbon\Carbon::parse("$date $out");
        return round($end->diffInMinutes($start) / 60, 2);
    }
}
