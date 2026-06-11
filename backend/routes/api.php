<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\EmployeeController;
use App\Http\Controllers\Admin\AttendanceController;
use App\Http\Controllers\Admin\ViolationController;
use App\Http\Controllers\Admin\AlertController;
use App\Http\Controllers\Admin\CameraController;
use App\Http\Controllers\Employee\MyDashboardController;
use App\Http\Controllers\Employee\MyAttendanceController;
use App\Http\Controllers\AI\DetectionController;

/*
|--------------------------------------------------------------------------
| Public Routes — لا تحتاج توكن
|--------------------------------------------------------------------------
*/
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login',    [AuthController::class, 'login']);
});

// AI Microservice endpoints — secured by token in middleware
Route::get('/ai/cameras', [DetectionController::class, 'getEdgeCameras'])
    ->middleware('auth:sanctum');
Route::post('/ai/detection', [DetectionController::class, 'store'])
    ->middleware('auth:sanctum');

/*
|--------------------------------------------------------------------------
| Protected Routes — تحتاج توكن
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me',      [AuthController::class, 'me']);
    });

    /*
    |----------------------------------------------------------------------
    | ADMIN ROUTES
    |----------------------------------------------------------------------
    */
    Route::middleware('is_admin')->prefix('admin')->group(function () {

        // Dashboard
        Route::get('/dashboard', [DashboardController::class, 'index']);

        // Employees — CRUD كامل
        Route::get('/employees',           [EmployeeController::class, 'index']);
        Route::get('/employees/{employee}', [EmployeeController::class, 'show']);
        Route::post('/employees',           [EmployeeController::class, 'store']);
        Route::put('/employees/{employee}', [EmployeeController::class, 'update']);
        Route::delete('/employees/{employee}', [EmployeeController::class, 'destroy']);

        // Attendance
        Route::get('/attendance',       [AttendanceController::class, 'index']);
        Route::post('/attendance',      [AttendanceController::class, 'store']);
        Route::get('/attendance/stats', [AttendanceController::class, 'stats']);

        // Violations
        Route::get('/violations',                      [ViolationController::class, 'index']);
        Route::post('/violations/{violation}/resolve', [ViolationController::class, 'resolve']);
        Route::post('/violations/{violation}/dismiss', [ViolationController::class, 'dismiss']);
        Route::put('/violations/{violation}/status',   [ViolationController::class, 'updateStatus']);

        // Alerts  ⚠️ mark-all-read يجي قبل {alert} عشان Laravel ميعتبرهاش wildcard
        Route::get('/alerts',                    [AlertController::class, 'index']);
        Route::post('/alerts/mark-all-read',     [AlertController::class, 'markAllRead']);
        Route::post('/alerts/{alert}/resolve',   [AlertController::class, 'resolve']);
        Route::post('/alerts/{alert}/dismiss',   [AlertController::class, 'dismiss']);

        // Cameras
        Route::get('/cameras',                         [CameraController::class, 'index']);
        Route::post('/cameras',                        [CameraController::class, 'store']);
        Route::put('/cameras/{camera}',                [CameraController::class, 'update']);
        Route::delete('/cameras/{camera}',             [CameraController::class, 'destroy']);
        Route::post('/cameras/{camera}/toggle-status', [CameraController::class, 'toggleStatus']);
    });

    /*
    |----------------------------------------------------------------------
    | EMPLOYEE ROUTES
    |----------------------------------------------------------------------
    */
    Route::middleware('is_employee')->prefix('employee')->group(function () {
        Route::get('/dashboard',   [MyDashboardController::class,  'index']);
        Route::get('/attendance',  [MyAttendanceController::class, 'index']);
    });

});
