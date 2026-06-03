<?php

namespace App\Http\Controllers\AI;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Attendance;
use App\Models\AiDetectionLog;
use App\Models\Camera;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Carbon\Carbon;

/**
 * يُستدعى من FastAPI بعد التعرف على وجه الموظف بالكاميرا.
 * لا يحتاج Sanctum token — يُحمى بـ X-AI-Key header.
 */
class AiAttendanceController extends Controller
{
    use ApiResponse;

    /**
     * POST /api/ai/attendance
     *
     * Body (من FastAPI):
     * {
     *   "employee_code": "EMP-001",   // أو
     *   "employee_id": 1,
     *   "camera_id": 2,
     *   "event": "check_in" | "check_out",
     *   "confidence": 0.97,
     *   "frame_path": "frames/abc.jpg"   // اختياري
     * }
     */
    public function record(Request $request)
    {
        // ── التحقق من الـ AI Secret Key ───────────────────────────
        $expectedKey = config('app.ai_secret_key', env('AI_SECRET_KEY', 'safetywatch-ai-key'));
        if ($request->header('X-AI-Key') !== $expectedKey) {
            return response()->json(['status' => false, 'message' => 'Unauthorized AI request.'], 401);
        }

        // ── Validation ────────────────────────────────────────────
        $request->validate([
            'employee_code' => 'required_without:employee_id|string',
            'employee_id'   => 'required_without:employee_code|integer|exists:employees,id',
            'camera_id'     => 'required|integer|exists:cameras,id',
            'event'         => 'required|in:check_in,check_out',
            'confidence'    => 'required|numeric|min:0|max:1',
            'frame_path'    => 'nullable|string',
        ]);

        // ── إيجاد الموظف ──────────────────────────────────────────
        $employee = isset($request->employee_id)
            ? Employee::find($request->employee_id)
            : Employee::where('employee_code', $request->employee_code)->first();

        if (!$employee) {
            return $this->error('Employee not found.', 404);
        }

        $today = Carbon::today()->toDateString();
        $now   = Carbon::now()->format('H:i:s');

        // ── سجّل في جدول ai_detection_logs ───────────────────────
        AiDetectionLog::create([
            'camera_id'             => $request->camera_id,
            'detection_type'        => 'face_recognition',
            'is_threat'             => false,
            'confidence'            => $request->confidence * 100, // نحوله لـ percentage
            'frame_path'            => $request->frame_path,
            'recognized_employee_id'=> $employee->id,
            'raw_result'            => json_encode(['event' => $request->event, 'employee_code' => $employee->employee_code]),
            'processed_at'          => now(),
        ]);

        // ── تسجيل الحضور ─────────────────────────────────────────
        $attendance = Attendance::firstOrNew(
            ['employee_id' => $employee->id, 'date' => $today]
        );

        if ($request->event === 'check_in' && !$attendance->check_in) {
            $attendance->check_in          = $now;
            $attendance->check_in_source   = 'face_recognition';
            $attendance->check_in_camera_id= $request->camera_id;
            $attendance->save(); // نحفظ الأول عشان determineStatus يشتغل
            $attendance->status            = $attendance->determineStatus();
            $attendance->save();

        } elseif ($request->event === 'check_out') {
            $attendance->check_out          = $now;
            $attendance->check_out_source   = 'face_recognition';
            $attendance->check_out_camera_id= $request->camera_id;
            $attendance->total_hours        = $attendance->calculateTotalHours();
            $attendance->save();
        }

        return $this->success([
            'employee'   => $employee->employee_code,
            'name'       => $employee->user->name ?? 'Unknown',
            'event'      => $request->event,
            'time'       => $now,
            'status'     => $attendance->status,
            'total_hours'=> $attendance->total_hours,
        ], 'Attendance recorded via face recognition.');
    }
}
