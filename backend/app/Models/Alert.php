<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Alert extends Model
{
    use HasFactory;

    protected $fillable = [
        'violation_id', 'camera_id', 'title', 'description',
        'severity', 'status', 'confidence',
        'actioned_by', 'actioned_at', 'is_read',
    ];

    protected $casts = [
        'actioned_at' => 'datetime',
        'confidence'  => 'decimal:2',
        'is_read'     => 'boolean',
    ];

    public function violation()  { return $this->belongsTo(Violation::class); }
    public function camera()     { return $this->belongsTo(Camera::class); }
    public function actionedBy() { return $this->belongsTo(User::class, 'actioned_by'); }

    public function scopeActive($query)   { return $query->where('status', 'active'); }
    public function scopeUnread($query)   { return $query->where('is_read', false); }
    public function scopeCritical($query) { return $query->where('severity', 'critical'); }

    public function markAsRead(): void { $this->update(['is_read' => true]); }

    public static function createFromViolation(Violation $violation): self
    {
        return static::create([
            'violation_id' => $violation->id,
            'camera_id'    => $violation->camera_id,
            'title'        => static::getTitleForType($violation->type),
            'description'  => $violation->description,
            'severity'     => $violation->severity,
            'confidence'   => $violation->confidence,
            'status'       => 'active',
        ]);
    }

    private static function getTitleForType(string $type): string
    {
        return match($type) {
            'violence'              => 'Violence Detected',
            'restricted_area'       => 'Restricted Area Access',
            'unusual_activity'      => 'Suspicious Activity',
            'crowd_detection'       => 'Crowd Detection',
            'safety_violation'      => 'Safety Violation',
            'unauthorized_presence' => 'Unauthorized Presence',
            default                 => 'Security Alert',
        };
    }
}
