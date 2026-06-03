<?php

namespace Database\Seeders;

use App\Models\Employee;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        // ── Admin ──────────────────────────────────────────────
        $admin = User::firstOrCreate(
            ['email' => 'admin@safetywatch.com'],
            [
                'name'      => 'Ahmed Hassan',
                'password'  => Hash::make('admin123'),
                'is_active' => true,
            ]
        );
        $admin->assignRole('admin');

        // ── Demo Employee ──────────────────────────────────────
        $empUser = User::firstOrCreate(
            ['email' => 'user@safetywatch.com'],
            [
                'name'      => 'Mohamed Ali',
                'password'  => Hash::make('user123'),
                'is_active' => true,
            ]
        );
        $empUser->assignRole('employee');

        // Employee profile
        Employee::firstOrCreate(
            ['user_id' => $empUser->id],
            [
                'employee_code'  => 'EMP-001',
                'department'     => 'Mobile Development',
                'position'       => 'Flutter Developer',
                'join_date'      => '2024-01-20',
                'shift_start'    => '08:00:00',
                'shift_end'      => '17:00:00',
                'late_threshold' => 15,
                'status'         => 'active',
            ]
        );

        // Admin employee profile
        Employee::firstOrCreate(
            ['user_id' => $admin->id],
            [
                'employee_code'  => 'EMP-000',
                'department'     => 'Administration',
                'position'       => 'System Admin',
                'join_date'      => '2023-01-01',
                'shift_start'    => '08:00:00',
                'shift_end'      => '17:00:00',
                'late_threshold' => 15,
                'status'         => 'active',
            ]
        );
    }
}
