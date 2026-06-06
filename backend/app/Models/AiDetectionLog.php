<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use App\Traits\BelongsToAdmin;

class AiDetectionLog extends Model
{
    use HasFactory, BelongsToAdmin;

    protected $fillable = [
        'camera_id', 'detection_type', 'is_threat', 'confidence',
        'raw_result', 'frame_path', 'frame_number',
        'recognized_employee_id', 'processed_at',
    ];

    protected $casts = [
        'is_threat'    => 'boolean',
        'confidence'   => 'decimal:2',
        'raw_result'   => 'array',
        'processed_at' => 'datetime',
    ];

    public function camera()              { return $this->belongsTo(Camera::class); }
    public function recognizedEmployee()  { return $this->belongsTo(Employee::class, 'recognized_employee_id'); }
    public function violation()           { return $this->hasOne(Violation::class, 'ai_detection_log_id'); }

    public function scopeThreats($query)              { return $query->where('is_threat', true); }
    public function scopeByType($query, string $type) { return $query->where('detection_type', $type); }
    public function scopeFaceRecognition($query)      { return $query->where('detection_type', 'face_recognition'); }
}
