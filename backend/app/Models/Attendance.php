<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

use App\Traits\BelongsToAdmin;

class Attendance extends Model
{
    use HasFactory, BelongsToAdmin;

    protected $fillable = [
        'employee_id', 'date', 'check_in', 'check_out',
        'total_hours', 'status', 'check_in_source', 'check_out_source',
        'check_in_camera_id', 'check_out_camera_id', 'notes',
    ];

    protected $casts = [
        'date'        => 'date',
        'total_hours' => 'decimal:2',
    ];

    public function employee()       { return $this->belongsTo(Employee::class); }
    public function checkInCamera()  { return $this->belongsTo(Camera::class, 'check_in_camera_id'); }
    public function checkOutCamera() { return $this->belongsTo(Camera::class, 'check_out_camera_id'); }

    public function scopeForMonth($query, int $year, int $month)
    {
        return $query->whereYear('date', $year)->whereMonth('date', $month);
    }
    public function scopeToday($query)   { return $query->whereDate('date', today()); }
    public function scopePresent($query) { return $query->whereIn('status', ['present', 'late']); }

    public function calculateTotalHours(): float
    {
        if (!$this->check_in || !$this->check_out) return 0;
        $in  = Carbon::parse($this->date->format('Y-m-d') . ' ' . $this->check_in);
        $out = Carbon::parse($this->date->format('Y-m-d') . ' ' . $this->check_out);
        return round($out->diffInMinutes($in) / 60, 2);
    }

    public function determineStatus(): string
    {
        if (!$this->check_in) return 'absent';
        $employee   = $this->employee;
        $shiftStart = Carbon::parse($this->date->format('Y-m-d') . ' ' . $employee->shift_start);
        $checkIn    = Carbon::parse($this->date->format('Y-m-d') . ' ' . $this->check_in);

        // minutesLate: موجبة = متأخر، سالبة = مبكر
        $minutesLate = $shiftStart->diffInMinutes($checkIn, false);

        return $minutesLate <= $employee->late_threshold ? 'present' : 'late';
    }
}
