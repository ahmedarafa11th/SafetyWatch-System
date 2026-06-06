<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    use ApiResponse;

    public function index(Request $request)
    {
        // Merge Violations into Alerts by fetching Violations directly
        $alerts = \App\Models\Violation::with(['camera', 'employee.user', 'resolvedBy'])
            ->when($request->status,   fn($q) => $q->where('status', $request->status))
            ->when($request->severity, fn($q) => $q->where('severity', $request->severity))
            ->latest('detected_at')
            ->paginate(15);

        // Map violations to alert format for the frontend
        $mappedItems = collect($alerts->items())->map(function ($violation) {
            $title = match($violation->type) {
                'violence'              => 'Violence Detected',
                'restricted_area'       => 'Restricted Area Access',
                'unusual_activity'      => 'Suspicious Activity',
                'crowd_detection'       => 'Crowd Detection',
                'safety_violation'      => 'Safety Violation',
                'unauthorized_presence' => 'Unauthorized Presence',
                default                 => 'Security Alert',
            };

            return [
                'id'          => $violation->id,
                'title'       => $title,
                'description' => $violation->description,
                'severity'    => $violation->severity,
                'status'      => $violation->status,
                'confidence'  => $violation->confidence,
                'camera'      => $violation->camera,
                'created_at'  => $violation->detected_at,
            ];
        });

        $stats = [
            'active'         => \App\Models\Violation::active()->count(),
            'critical'       => \App\Models\Violation::where('severity', 'critical')->count(),
            'unread'         => \App\Models\Violation::where('status', 'active')->count(),
            'resolved_today' => \App\Models\Violation::whereDate('resolved_at', today())->count(),
            'avg_confidence' => round(\App\Models\Violation::avg('confidence') ?? 0, 1),
        ];

        return response()->json([
            'status'  => true,
            'message' => 'Alerts and Violations fetched',
            'data'    => [
                'stats'  => $stats,
                'alerts' => $mappedItems,
            ],
            'meta'    => [
                'current_page' => $alerts->currentPage(),
                'last_page'    => $alerts->lastPage(),
                'per_page'     => $alerts->perPage(),
                'total'        => $alerts->total(),
            ],
        ]);
    }

    // POST /api/admin/alerts/{id}/resolve
    public function resolve(Request $request, \App\Models\Violation $alert)
    {
        $alert->resolve($request->user()->id);
        return $this->success(null, 'Alert resolved');
    }

    // POST /api/admin/alerts/{id}/dismiss
    public function dismiss(Request $request, \App\Models\Violation $alert)
    {
        $alert->dismiss($request->user()->id);
        return $this->success(null, 'Alert dismissed');
    }

    // POST /api/admin/alerts/mark-all-read
    public function markAllRead()
    {
        \App\Models\Violation::active()->update(['status' => 'dismissed']); // Equivalent to marking low severity as dismissed
        return $this->success(null, 'All alerts marked as read/dismissed');
    }
}
