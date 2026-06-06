<?php

namespace App\Http\Controllers\Employee;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class MyAttendanceController extends Controller
{
    use ApiResponse;

    // GET /api/employee/attendance
    public function index(Request $request)
    {
        $employee = Employee::withoutGlobalScopes()->where('user_id', $request->user()->id)->first();

        if (!$employee) {
            return $this->error('Employee profile not found.', 404);
        }

        $query = $employee->attendances()
            ->when($request->month, fn($q) =>
                $q->whereRaw("strftime('%Y-%m', date) = ?", [$request->month])
            )
            ->latest('date');

        $records = $query->paginate(20);

        // Stats للشهر المحدد أو الحالي
        $month = $request->month ?? now()->format('Y-m');
        [$year, $mon] = explode('-', $month);

        $monthData = $employee->attendances()
            ->whereYear('date', $year)
            ->whereMonth('date', $mon)
            ->get();

        $stats = [
            'days_present'  => $monthData->whereIn('status', ['present','late'])->count(),
            'days_late'     => $monthData->where('status', 'late')->count(),
            'days_absent'   => $monthData->where('status', 'absent')->count(),
            'total_hours'   => round($monthData->sum('total_hours'), 1) . 'h',
        ];

        return $this->success([
            'stats'   => $stats,
            'records' => $records->items(),
            'meta'    => [
                'current_page' => $records->currentPage(),
                'last_page'    => $records->lastPage(),
                'total'        => $records->total(),
            ],
        ]);
    }
}
