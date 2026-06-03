<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Violation extends Model
{
    use HasFactory;

    protected $fillable = [
        'camera_id', 'employee_id', 'type', 'description', 'snapshot',
        'severity', 'status', 'confidence', 'ai_detection_log_id',
        'detected_at', 'resolved_at', 'resolved_by',
    ];

    protected $casts = [
        'detected_at' => 'datetime',
        'resolved_at' => 'datetime',
        'confidence'  => 'decimal:2',
    ];

    public function camera()         { return $this->belongsTo(Camera::class); }
    public function employee()       { return $this->belongsTo(Employee::class); }
    public function alert()          { return $this->hasOne(Alert::class); }
    public function aiDetectionLog() { return $this->belongsTo(AiDetectionLog::class); }
    public function resolvedBy()     { return $this->belongsTo(User::class, 'resolved_by'); }

    public function scopeActive($query)                     { return $query->where('status', 'active'); }
    public function scopeBySeverity($query, string $sev)    { return $query->where('severity', $sev); }
    public function scopeByCamera($query, int $camId)       { return $query->where('camera_id', $camId); }

    public function resolve(int $userId): void
    {
        $this->update(['status' => 'resolved', 'resolved_at' => now(), 'resolved_by' => $userId]);
        $this->alert?->update(['status' => 'resolved', 'actioned_by' => $userId, 'actioned_at' => now()]);
    }

    public function dismiss(int $userId): void
    {
        $this->update(['status' => 'dismissed']);
        $this->alert?->update(['status' => 'dismissed', 'actioned_by' => $userId, 'actioned_at' => now()]);
    }

    public function shouldCreateAlert(): bool
    {
        return in_array($this->severity, ['high', 'critical']);
    }
}
