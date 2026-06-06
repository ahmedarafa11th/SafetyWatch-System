<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

use App\Traits\BelongsToAdmin;

class Employee extends Model
{
    use HasFactory, SoftDeletes, BelongsToAdmin;

    protected $fillable = [
        'user_id', 'employee_code', 'department', 'position',
        'join_date', 'phone', 'national_id', 'photo',
        'shift_start', 'shift_end', 'late_threshold', 'status',
    ];

    protected $casts = [
        'join_date'      => 'date',
        'late_threshold' => 'integer',
    ];

    public function user()       { return $this->belongsTo(User::class); }
    public function attendances(){ return $this->hasMany(Attendance::class); }
    public function violations() { return $this->hasMany(Violation::class); }

    public function scopeActive($query)                         { return $query->where('status', 'active'); }
    public function scopeByDepartment($query, string $dept)     { return $query->where('department', $dept); }

    public function getAttendanceRateForMonth(int $year, int $month): float
    {
        $total   = $this->attendances()->whereYear('date', $year)->whereMonth('date', $month)->count();
        $present = $this->attendances()->whereYear('date', $year)->whereMonth('date', $month)
                        ->whereIn('status', ['present', 'late'])->count();
        return $total > 0 ? round(($present / $total) * 100, 1) : 0;
    }

    public function getTotalHoursForMonth(int $year, int $month): float
    {
        return $this->attendances()->whereYear('date', $year)->whereMonth('date', $month)->sum('total_hours');
    }

    public static function generateCode(): string
    {
        // نجيب أكبر رقم موجود ونزود عليه 1 — حتى مع الـ soft deletes
        $last = static::withoutGlobalScopes()
                       ->withTrashed()
                       ->where('employee_code', 'like', 'EMP-%')
                       ->orderByRaw('CAST(SUBSTR(employee_code, 5) AS INTEGER) DESC')
                       ->first();
        $num = $last
            ? (intval(substr($last->employee_code, 4)) + 1)
            : 1;
        return 'EMP-' . str_pad($num, 3, '0', STR_PAD_LEFT);
    }
}
