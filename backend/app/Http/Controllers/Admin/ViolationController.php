<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Violation;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class ViolationController extends Controller
{
    use ApiResponse;

    // GET /api/admin/violations
    public function index(Request $request)
    {
        $violations = Violation::with(['camera', 'employee.user', 'resolvedBy'])
            ->when($request->camera_id, fn($q) => $q->where('camera_id', $request->camera_id))
            ->when($request->severity,  fn($q) => $q->where('severity', $request->severity))
            ->when($request->status,    fn($q) => $q->where('status', $request->status))
            ->when($request->type,      fn($q) => $q->where('type', $request->type))
            ->latest('detected_at')
            ->paginate(15);

        $stats = [
            'total'               => Violation::count(),
            'active'              => Violation::active()->count(),
            'high_severity'       => Violation::whereIn('severity', ['high','critical'])->count(),
            'under_investigation' => Violation::where('status','under_investigation')->count(),
            'resolved'            => Violation::where('status','resolved')->count(),
        ];

        return response()->json([
            'status'  => true,
            'message' => 'Violations fetched',
            'data'    => $violations->items(),
            'stats'   => $stats,
            'meta'    => [
                'current_page' => $violations->currentPage(),
                'last_page'    => $violations->lastPage(),
                'per_page'     => $violations->perPage(),
                'total'        => $violations->total(),
            ],
        ]);
    }

    // POST /api/admin/violations/{id}/resolve
    public function resolve(Request $request, Violation $violation)
    {
        $violation->resolve($request->user()->id);
        return $this->success(null, 'Violation resolved successfully');
    }

    // POST /api/admin/violations/{id}/dismiss
    public function dismiss(Request $request, Violation $violation)
    {
        $violation->dismiss($request->user()->id);
        return $this->success(null, 'Violation dismissed');
    }

    // PUT /api/admin/violations/{id}/status
    public function updateStatus(Request $request, Violation $violation)
    {
        $request->validate(['status' => 'required|in:active,under_investigation,resolved,dismissed']);
        $violation->update(['status' => $request->status]);
        return $this->success($violation, 'Status updated');
    }
}
