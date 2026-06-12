<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Camera;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;

class CameraController extends Controller
{
    use ApiResponse;

    // GET /api/admin/cameras
    public function index()
    {
        $cameras = Camera::withCount(['violations', 'alerts'])->get();

        $stats = [
            'total'       => $cameras->count(),
            'online'      => $cameras->where('status', 'online')->count(),
            'offline'     => $cameras->where('status', 'offline')->count(),
            'total_alerts'=> $cameras->sum('total_alerts'),
        ];

        return $this->success(['stats' => $stats, 'cameras' => $cameras]);
    }

    // POST /api/admin/cameras/upload-video
    public function uploadVideo(Request $request)
    {
        $request->validate([
            'video' => 'required|file|mimes:mp4,mov,avi|max:51200' // 50MB max
        ]);

        $file = $request->file('video');
        $filename = time() . '_' . $file->getClientOriginalName();
        $path = $file->storeAs('public/test_videos', $filename);

        return $this->success([
            'url' => asset('storage/test_videos/' . $filename)
        ], 'Video uploaded successfully');
    }

    // POST /api/admin/cameras
    public function store(Request $request)
    {
        $request->validate([
            'name'           => 'required|string',
            'location'       => 'required|string',
            'ip_address'    => 'nullable|string|max:255',
            'stream_url'     => 'nullable|url',
            'is_entrance'    => 'boolean',
            'is_ai_enabled'  => 'boolean',
        ]);

        $camera = Camera::create($request->only([
            'name', 'location', 'ip_address', 'stream_url', 'is_entrance', 'is_ai_enabled',
        ]));
        return $this->success($camera, 'Camera added successfully', 201);
    }

    // PUT /api/admin/cameras/{id}
    public function update(Request $request, Camera $camera)
    {
        $request->validate([
            'name'          => 'sometimes|string',
            'location'      => 'sometimes|string',
            'status'        => 'sometimes|in:online,offline,maintenance',
            'is_ai_enabled' => 'sometimes|boolean',
            'ip_address'    => 'nullable|string|max:255',
            'stream_url'    => 'nullable|string|max:500',
        ]);

        $camera->update($request->only([
            'name', 'location', 'status', 'is_ai_enabled', 'ip_address', 'stream_url',
        ]));
        return $this->success($camera, 'Camera updated');
    }

    // DELETE /api/admin/cameras/{id}
    public function destroy(Camera $camera)
    {
        $camera->delete();
        return $this->success(null, 'Camera removed');
    }

    // POST /api/admin/cameras/{id}/toggle-status
    public function toggleStatus(Camera $camera)
    {
        $camera->update([
            'status' => $camera->status === 'online' ? 'offline' : 'online',
        ]);
        return $this->success($camera, 'Camera status updated');
    }
}
