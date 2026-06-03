<?php

namespace Database\Seeders;

use App\Models\Camera;
use Illuminate\Database\Seeder;

class CameraSeeder extends Seeder
{
    public function run(): void
    {
        $cameras = [
            ['name' => 'Camera 1 - Main Entrance',   'location' => 'Building A - Entrance',   'is_entrance' => true,  'status' => 'online',  'total_alerts' => 12],
            ['name' => 'Camera 2 - Office Floor',    'location' => 'Building A - Floor 2',    'is_entrance' => false, 'status' => 'online',  'total_alerts' => 5],
            ['name' => 'Camera 3 - Warehouse',       'location' => 'Building B - Warehouse',  'is_entrance' => false, 'status' => 'online',  'total_alerts' => 8],
            ['name' => 'Camera 4 - Storage',         'location' => 'Building B - Storage',    'is_entrance' => false, 'status' => 'online',  'total_alerts' => 2],
            ['name' => 'Camera 5 - Production Area', 'location' => 'Building C - Production', 'is_entrance' => false, 'status' => 'offline', 'total_alerts' => 0],
            ['name' => 'Camera 6 - Lobby',           'location' => 'Building A - Lobby',      'is_entrance' => true,  'status' => 'online',  'total_alerts' => 3],
            ['name' => 'Camera 7 - Parking Lot',     'location' => 'Outdoor - Parking',       'is_entrance' => false, 'status' => 'online',  'total_alerts' => 15],
            ['name' => 'Camera 8 - Server Room',     'location' => 'Building A - Floor 3',    'is_entrance' => false, 'status' => 'online',  'total_alerts' => 4],
            ['name' => 'Camera 9 - Cafeteria',       'location' => 'Building A - Floor 1',    'is_entrance' => false, 'status' => 'online',  'total_alerts' => 1],
            ['name' => 'Camera 10 - Loading Dock',   'location' => 'Building B - Dock',       'is_entrance' => false, 'status' => 'online',  'total_alerts' => 6],
            ['name' => 'Camera 11 - Emergency Exit', 'location' => 'Building C - Exit',       'is_entrance' => false, 'status' => 'online',  'total_alerts' => 0],
            ['name' => 'Camera 12 - Reception',      'location' => 'Building A - Reception',  'is_entrance' => true,  'status' => 'online',  'total_alerts' => 7],
        ];

        foreach ($cameras as $cam) {
            Camera::firstOrCreate(
                ['name' => $cam['name']],
                array_merge($cam, [
                    'is_ai_enabled'  => true,
                    'last_active_at' => now(),
                ])
            );
        }
    }
}
