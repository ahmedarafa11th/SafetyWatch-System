<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Alert;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class AlertController extends Controller
{
    use ApiResponse;

    // GET /api/admin/alerts
    public function index(Request $request)
    {
        $alerts = Alert::with(['camera', 'violation', 'actionedBy'])
            ->when($request->status,   fn($q) => $q->where('status', $request->status))
            ->when($request->severity, fn($q) => $q->where('severity', $request->severity))
            ->latest()
            ->paginate(15);

        $stats = [
            'active'         => Alert::active()->count(),
            'critical'       => Alert::critical()->count(),
            'unread'         => Alert::unread()->count(),
            'resolved_today' => Alert::whereDate('actioned_at', today())->where('status','resolved')->count(),
            'avg_confidence' => round(Alert::avg('confidence'), 1),
        ];

        return response()->json([
            'status'  => true,
            'message' => 'Alerts fetched',
            'data'    => [
                'stats'  => $stats,
                'alerts' => $alerts->items(),
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
    public function resolve(Request $request, Alert $alert)
    {
        $alert->update([
            'status'      => 'resolved',
            'actioned_by' => $request->user()->id,
            'actioned_at' => now(),
            'is_read'     => true,
        ]);
        return $this->success(null, 'Alert resolved');
    }

    // POST /api/admin/alerts/{id}/dismiss
    public function dismiss(Request $request, Alert $alert)
    {
        $alert->update([
            'status'      => 'dismissed',
            'actioned_by' => $request->user()->id,
            'actioned_at' => now(),
            'is_read'     => true,
        ]);
        return $this->success(null, 'Alert dismissed');
    }

    // POST /api/admin/alerts/mark-all-read
    public function markAllRead()
    {
        Alert::unread()->update(['is_read' => true]);
        return $this->success(null, 'All alerts marked as read');
    }
}
