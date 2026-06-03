<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Employee;
use App\Models\Camera;
use App\Models\Attendance;
use App\Models\Alert;
use App\Models\Violation;
use Carbon\Carbon;

class DummyDataSeeder extends Seeder
{
    public function run()
    {
        $employees = Employee::take(5)->get();
        $cameras   = Camera::take(5)->get();

        if ($employees->isEmpty() || $cameras->isEmpty()) {
            $this->command->warn('No employees or cameras found. Run DatabaseSeeder first.');
            return;
        }

        // ── 1. Attendance ────────────────────────────────────────────────
        foreach ($employees as $emp) {
            Attendance::firstOrCreate(
                ['employee_id' => $emp->id, 'date' => Carbon::today()->toDateString()],
                [
                    'check_in'       => '08:05:00',
                    'status'         => 'present',
                    'check_in_source'=> 'manual',
                ]
            );
        }

        // ── 2. Violations ────────────────────────────────────────────────
        $violationTypes = ['violence', 'restricted_area', 'unusual_activity', 'safety_violation', 'unauthorized_presence'];
        $severities     = ['low', 'medium', 'high', 'critical'];

        $violations = [];
        foreach ($employees as $emp) {
            $cam  = $cameras->random();
            $type = $violationTypes[array_rand($violationTypes)];
            $sev  = $severities[array_rand($severities)];

            $violation = Violation::create([
                'camera_id'   => $cam->id,
                'employee_id' => $emp->id,
                'type'        => $type,
                'description' => ucfirst(str_replace('_', ' ', $type)) . ' detected near ' . $cam->location,
                'severity'    => $sev,
                'status'      => 'active',
                'confidence'  => round(rand(75, 98) / 100, 2),
                'detected_at' => Carbon::now()->subMinutes(rand(10, 300)),
            ]);

            $violations[] = $violation;
        }

        // ── 3. Alerts (linked to violations) ────────────────────────────
        foreach ($violations as $violation) {
            Alert::create([
                'violation_id' => $violation->id,
                'camera_id'    => $violation->camera_id,
                'title'        => ucfirst(str_replace('_', ' ', $violation->type)) . ' Alert',
                'description'  => $violation->description,
                'severity'     => $violation->severity,
                'status'       => 'active',
                'confidence'   => $violation->confidence,
                'is_read'      => false,
            ]);
        }

        $this->command->info('✅ Dummy data seeded: ' . $employees->count() . ' attendances, ' . count($violations) . ' violations & alerts.');
    }
}
