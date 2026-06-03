<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Models\Attendance;
use App\Models\Camera;
use App\Models\Employee;
use App\Traits\ApiResponse;

class DashboardController extends Controller
{
    use ApiResponse;

    // GET /api/admin/dashboard
    public function index()
    {
        $today = today();

        // Stats
        $totalEmployees  = Employee::active()->count();
        $presentToday    = Attendance::today()->present()->count();
        $lateToday       = Attendance::today()->where('status', 'late')->count();
        $absentToday     = $totalEmployees - $presentToday;
        $activeCameras   = Camera::online()->count();
        $activeAlerts    = Alert::active()->count();
        $attendanceRate  = $totalEmployees > 0
            ? round(($presentToday / $totalEmployees) * 100, 1)
            : 0;

        // Recent Attendance (آخر 5)
        $recentAttendance = Attendance::with('employee.user')
            ->today()
            ->latest()
            ->take(5)
            ->get()
            ->map(fn($a) => [
                'employee_name' => $a->employee->user->name,
                'check_in'      => $a->check_in,
                'status'        => $a->status,
            ]);

        // Recent Alerts (آخر 5)
        $recentAlerts = Alert::with('camera')
            ->active()
            ->latest()
            ->take(5)
            ->get()
            ->map(fn($al) => [
                'id'          => $al->id,
                'title'       => $al->title,
                'camera_name' => $al->camera->name,
                'severity'    => $al->severity,
                'created_at'  => $al->created_at->diffForHumans(),
            ]);

        return $this->success([
            'stats' => [
                'total_employees'  => $totalEmployees,
                'present_today'    => $presentToday,
                'late_today'       => $lateToday,
                'absent_today'     => $absentToday,
                'active_cameras'   => $activeCameras,
                'active_alerts'    => $activeAlerts,
                'attendance_rate'  => $attendanceRate,
            ],
            'recent_attendance' => $recentAttendance,
            'recent_alerts'     => $recentAlerts,
        ]);
    }
}
