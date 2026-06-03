<?php
// ============================================================
// FILE: database/seeders/RoleSeeder.php
// ============================================================

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        $adminPerms = [
            'view-dashboard','manage-employees',
            'view-attendance','manage-attendance',
            'view-violations','manage-violations',
            'view-alerts','manage-alerts',
            'manage-cameras',
        ];

        $employeePerms = [
            'view-my-dashboard',
            'view-my-attendance',
        ];

        foreach (array_merge($adminPerms, $employeePerms) as $perm) {
            Permission::firstOrCreate(['name' => $perm, 'guard_name' => 'api']);
        }

        $admin    = Role::firstOrCreate(['name' => 'admin',    'guard_name' => 'api']);
        $employee = Role::firstOrCreate(['name' => 'employee', 'guard_name' => 'api']);

        $admin->syncPermissions($adminPerms);
        $employee->syncPermissions($employeePerms);
    }
}
