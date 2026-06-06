<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\Attendance;
use App\Models\Employee;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class MyDashboardController extends Controller
{
    use ApiResponse;

    // GET /api/employee/dashboard
    public function index(Request $request)
    {
        $employee = Employee::withoutGlobalScopes()->where('user_id', $request->user()->id)->first();

        if (!$employee) {
            return $this->error('Employee profile not found.', 404);
        }

        $year  = now()->year;
        $month = now()->month;

        $monthAttendances = $employee->attendances()
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->get();

        $daysPresent  = $monthAttendances->whereIn('status', ['present', 'late'])->count();
        $daysAbsent   = $monthAttendances->where('status', 'absent')->count();
        $daysLate     = $monthAttendances->where('status', 'late')->count();
        $totalHours   = $monthAttendances->sum('total_hours');
        $avgHours     = $daysPresent > 0 ? round($totalHours / $daysPresent, 1) : 0;
        $attendRate   = $employee->getAttendanceRateForMonth($year, $month);

        // آخر 5 سجلات
        $recentAttendance = $employee->attendances()
            ->latest('date')
            ->take(5)
            ->get()
            ->map(fn($a) => [
                'date'        => $a->date->format('Y-m-d'),
                'check_in'    => $a->check_in,
                'check_out'   => $a->check_out,
                'total_hours' => $a->total_hours . 'h',
                'status'      => $a->status,
            ]);

        // Punctuality
        $totalDays      = $monthAttendances->whereIn('status', ['present','late'])->count();
        $punctualDays   = $monthAttendances->where('status','present')->count();
        $punctualityRate = $totalDays > 0 ? round(($punctualDays / $totalDays) * 100, 1) : 0;

        return $this->success([
            'stats' => [
                'days_present'     => $daysPresent,
                'days_absent'      => $daysAbsent,
                'days_late'        => $daysLate,
                'average_hours'    => $avgHours,
                'total_hours'      => round($totalHours, 1),
                'attendance_rate'  => $attendRate,
                'punctuality_rate' => $punctualityRate,
            ],
            'recent_attendance' => $recentAttendance,
            'employee' => [
                'name'       => $employee->user->name,
                'department' => $employee->department,
                'position'   => $employee->position,
                'code'       => $employee->employee_code,
            ],
        ]);
    }
}
