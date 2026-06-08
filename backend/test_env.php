<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
echo 'DB: ' . config('database.connections.sqlite.database') . PHP_EOL;
echo 'Env DB_DATABASE: ' . env('DB_DATABASE', 'NOT_SET') . PHP_EOL;
echo 'getenv DB_DATABASE: ' . getenv('DB_DATABASE') . PHP_EOL;
