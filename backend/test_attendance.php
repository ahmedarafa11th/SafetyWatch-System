<?php
require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Employee;
use App\Models\Attendance;

$emp = Employee::with('user')->first();
if (!$emp) { echo "❌ No employee found!\n"; exit(1); }

echo "=== Employee: {$emp->user->name} ===\n";
echo "Shift Start: {$emp->shift_start} | Late Threshold: {$emp->late_threshold} min\n\n";

// حذف سجلات الاختبار القديمة
Attendance::where('employee_id', $emp->id)
    ->whereIn('date', ['2026-04-28','2026-04-27','2026-04-26','2026-04-25','2026-04-24'])
    ->delete();

$tests = [
    ['date'=>'2026-04-28', 'check_in'=>'08:00:00', 'check_out'=>'17:00:00', 'label'=>'On Time (exact shift start)'],
    ['date'=>'2026-04-27', 'check_in'=>'08:10:00', 'check_out'=>'17:10:00', 'label'=>'Slightly Late (10 min — within threshold)'],
    ['date'=>'2026-04-26', 'check_in'=>'08:20:00', 'check_out'=>'17:20:00', 'label'=>'Late (20 min — exceeds threshold)'],
    ['date'=>'2026-04-25', 'check_in'=>null,        'check_out'=>null,        'label'=>'Absent (no check-in)'],
    ['date'=>'2026-04-24', 'check_in'=>'07:45:00', 'check_out'=>'16:45:00', 'label'=>'Early (15 min before shift)'],
];

$pass = 0; $fail = 0;
$expected = ['present','present','late','absent','present'];

foreach ($tests as $i => $t) {
    $att = Attendance::create([
        'employee_id'     => $emp->id,
        'date'            => $t['date'],
        'check_in'        => $t['check_in'],
        'check_out'       => $t['check_out'],
        'status'          => 'absent',
        'check_in_source' => 'manual',
        'total_hours'     => 0,
    ]);

    $status = $att->determineStatus();
    $hours  = $att->calculateTotalHours();
    $att->update(['status' => $status, 'total_hours' => $hours]);

    $ok = $status === $expected[$i];
    $ok ? $pass++ : $fail++;
    $icon = $ok ? '✅' : '❌';

    echo "{$icon} {$t['date']} | {$t['label']}\n";
    echo "   Status: " . strtoupper($status) . " (expected: " . strtoupper($expected[$i]) . ") | Hours: {$hours}h\n\n";
}

echo "=== Results: {$pass} passed, {$fail} failed ===\n";
echo "Data saved to DB — check /my-dashboard or /attendance in browser.\n";
