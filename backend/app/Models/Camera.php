<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Camera extends Model
{
    use HasFactory;

    protected $fillable = [
        'name', 'location', 'ip_address', 'stream_url',
        'status', 'is_entrance', 'is_ai_enabled',
        'last_active_at', 'total_alerts',
    ];

    protected $casts = [
        'is_entrance'    => 'boolean',
        'is_ai_enabled'  => 'boolean',
        'last_active_at' => 'datetime',
        'total_alerts'   => 'integer',
    ];

    public function violations()        { return $this->hasMany(Violation::class); }
    public function alerts()            { return $this->hasMany(Alert::class); }
    public function aiDetectionLogs()   { return $this->hasMany(AiDetectionLog::class); }
    public function attendancesCheckIn(){ return $this->hasMany(Attendance::class, 'check_in_camera_id'); }

    public function scopeOnline($query)     { return $query->where('status', 'online'); }
    public function scopeAiEnabled($query)  { return $query->where('is_ai_enabled', true); }
    public function scopeEntrance($query)   { return $query->where('is_entrance', true); }

    public function isOnline(): bool    { return $this->status === 'online'; }
    public function markAsActive(): void{ $this->update(['last_active_at' => now(), 'status' => 'online']); }
    public function incrementAlerts(): void { $this->increment('total_alerts'); }
}
