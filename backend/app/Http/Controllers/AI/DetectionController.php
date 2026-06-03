<?php

namespace App\Http\Controllers\AI;

use App\Http\Controllers\Controller;
use App\Models\Camera;
use App\Models\Violation;
use App\Models\Alert;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class DetectionController extends Controller
{
    use ApiResponse;

    /**
     * POST /api/ai/detection
     * Called by the Python FastAPI microservice when violence is detected.
     */
    public function store(Request $request)
    {
        $request->validate([
            'camera_id'      => 'required|exists:cameras,id',
            'detection_type' => 'required|in:violence,face_recognition,crowd,unusual_activity,safety_check',
            'is_threat'      => 'boolean',
            'confidence'     => 'required|numeric|min:0|max:100',
            'raw_result'     => 'nullable|array',
            'frame_path'     => 'nullable|string',
            'processed_at'   => 'nullable|date',
        ]);

        $camera = Camera::find($request->camera_id);

        // Log the AI detection
        $log = \App\Models\AiDetectionLog::create([
            'camera_id'      => $request->camera_id,
            'detection_type' => $request->detection_type,
            'is_threat'      => $request->boolean('is_threat', false),
            'confidence'     => $request->confidence,
            'raw_result'     => $request->raw_result,
            'frame_path'     => $request->frame_path,
            'processed_at'   => $request->processed_at ?? now(),
        ]);

        // If it's a threat, create a violation + alert
        if ($request->boolean('is_threat', false)) {

            $violation = Violation::create([
                'camera_id'          => $request->camera_id,
                'type'               => $request->detection_type,
                'description'        => ucfirst(str_replace('_', ' ', $request->detection_type))
                                        . ' detected with ' . $request->confidence . '% confidence',
                'severity'           => $request->confidence >= 85 ? 'high' : ($request->confidence >= 70 ? 'medium' : 'low'),
                'status'             => 'active',
                'confidence'         => $request->confidence,
                'ai_detection_log_id'=> $log->id,
                'detected_at'        => $request->processed_at ?? now(),
            ]);

            // Use the built-in factory method — it handles title/description/severity correctly
            Alert::createFromViolation($violation);

            // Update camera stats
            $camera->increment('total_alerts');
            $camera->update(['last_active_at' => now()]);

            Log::warning("AI Detection: {$request->detection_type} at Camera {$request->camera_id} ({$request->confidence}%)");

            return $this->success([
                'log_id'       => $log->id,
                'violation_id' => $violation->id,
                'action'       => 'violation_created',
            ], 'Violation recorded', 201);
        }

        return $this->success(['log_id' => $log->id, 'action' => 'logged'], 'Detection logged');
    }
}
