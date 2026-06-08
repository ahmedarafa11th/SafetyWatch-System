<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\EmployeeRequest;
use App\Models\Employee;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class EmployeeController extends Controller
{
    use ApiResponse;

    // GET /api/admin/employees
    public function index(Request $request)
    {
        $query = Employee::with('user')
            ->when($request->search, fn($q) =>
                $q->where('department', 'like', "%{$request->search}%")
                  ->orWhere('position', 'like', "%{$request->search}%")
                  ->orWhereHas('user', fn($u) =>
                      $u->where('name', 'like', "%{$request->search}%")
                  )
            )
            ->when($request->status, fn($q) => $q->where('status', $request->status))
            ->when($request->department, fn($q) => $q->where('department', $request->department));

        $employees = $query->latest()->paginate(15);

        return $this->paginated($employees);
    }

    // GET /api/admin/employees/{id}
    public function show(Employee $employee)
    {
        $employee->load('user');
        return $this->success($employee);
    }

    // POST /api/admin/employees
    public function store(EmployeeRequest $request)
    {
        // البحث عن المستخدم الموجود بالإيميل
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return $this->error(
                'No account found with this email. The user must create an account first.',
                422
            );
        }

        // Check if the user already has an active Employee Profile
        $existingEmployee = Employee::withoutGlobalScopes()->where('user_id', $user->id)->first();
        if ($existingEmployee) {
            if ($existingEmployee->trashed()) {
                // Previously deleted — hard-delete the old record so we can create a fresh one
                $existingEmployee->forceDelete();
            } else {
                return $this->error(
                    'This employee is already registered with another admin.',
                    422
                );
            }
        }

        DB::beginTransaction();
        try {
            // تعيين دور الـ employee إذا لم يكن موجوداً
            if (!$user->hasRole('employee')) {
                $user->assignRole('employee');
            }

            // ✅ تفعيل الحساب — المستخدم أصبح بإمكانه تسجيل الدخول الآن
            $user->update(['is_active' => true]);

            // ربط الـ Employee Profile بالـ User الموجود
            $employee = Employee::create([
                'user_id'         => $user->id,
                'employee_code'   => Employee::generateCode(),
                'department'      => $request->department,
                'position'        => $request->position,
                'join_date'       => $request->join_date,
                'phone'           => $request->phone,
                'national_id'     => $request->national_id,
                'shift_start'     => $request->shift_start ?? '08:00:00',
                'shift_end'       => $request->shift_end   ?? '17:00:00',
                'late_threshold'  => $request->late_threshold ?? 15,
                'status'          => $request->status ?? 'active',
            ]);

            DB::commit();

            // Save and Forward photos to Runpod Face Recognition API
            if ($request->hasFile('photo_front')) {
                try {
                    $path = "public/faces/{$employee->employee_code}";
                    
                    // Save locally
                    $request->file('photo_front')->storeAs($path, 'front.jpg');
                    if ($request->hasFile('photo_left')) $request->file('photo_left')->storeAs($path, 'left.jpg');
                    if ($request->hasFile('photo_right')) $request->file('photo_right')->storeAs($path, 'right.jpg');

                    // Only forward to the AI service if it's explicitly configured
                    $aiUrl = env('FACE_RECOGNITION_API_URL');
                    if ($aiUrl) {
                        $runpodUrl = $aiUrl . '/api/register';

                        $httpReq = Http::timeout(5)->asMultipart()
                            ->attach('photo_front', file_get_contents($request->file('photo_front')->getRealPath()), $request->file('photo_front')->getClientOriginalName());

                        if ($request->hasFile('photo_left')) {
                            $httpReq->attach('photo_left', file_get_contents($request->file('photo_left')->getRealPath()), $request->file('photo_left')->getClientOriginalName());
                        }
                        if ($request->hasFile('photo_right')) {
                            $httpReq->attach('photo_right', file_get_contents($request->file('photo_right')->getRealPath()), $request->file('photo_right')->getClientOriginalName());
                        }

                        $httpReq->post($runpodUrl, [
                            'name' => $user->name,
                            'employee_code' => $employee->employee_code,
                        ]);
                    } else {
                        Log::info("AI Face Recognition service not configured. Photos saved locally only.");
                    }
                } catch (\Exception $apiException) {
                    Log::error("Failed to register face with AI API: " . $apiException->getMessage());
                    // We don't rollback the employee creation if AI sync fails, just log it.
                }
            }

            return $this->success($employee->load('user'), 'Employee linked and account activated successfully', 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->error('Failed to link employee: ' . $e->getMessage(), 500);
        }
    }

    // PUT /api/admin/employees/{id}
    public function update(EmployeeRequest $request, Employee $employee)
    {
        DB::beginTransaction();
        try {
            if ($request->has('name')) {
                $employee->user->update(['name' => $request->name]);
            }

            // Only update fields that are actually present in the request
            // to avoid setting NOT NULL columns to null
            $updateData = array_filter([
                'department'     => $request->department,
                'position'       => $request->position,
                'join_date'      => $request->join_date,
                'phone'          => $request->phone,
                'shift_start'    => $request->shift_start,
                'shift_end'      => $request->shift_end,
                'late_threshold' => $request->late_threshold,
                'status'         => $request->status,
            ], fn($value) => $value !== null);

            $employee->update($updateData);

            // Handle photo uploads on edit
            if ($request->hasFile('photo_front')) {
                try {
                    $path = "public/faces/{$employee->employee_code}";
                    $request->file('photo_front')->storeAs($path, 'front.jpg');
                    if ($request->hasFile('photo_left')) $request->file('photo_left')->storeAs($path, 'left.jpg');
                    if ($request->hasFile('photo_right')) $request->file('photo_right')->storeAs($path, 'right.jpg');

                    // Only forward to the AI service if it's explicitly configured
                    $aiUrl = env('FACE_RECOGNITION_API_URL');
                    if ($aiUrl) {
                        $runpodUrl = $aiUrl . '/api/register';
                        $httpReq = Http::timeout(5)->asMultipart()
                            ->attach('photo_front', file_get_contents($request->file('photo_front')->getRealPath()), $request->file('photo_front')->getClientOriginalName());
                        if ($request->hasFile('photo_left')) {
                            $httpReq->attach('photo_left', file_get_contents($request->file('photo_left')->getRealPath()), $request->file('photo_left')->getClientOriginalName());
                        }
                        if ($request->hasFile('photo_right')) {
                            $httpReq->attach('photo_right', file_get_contents($request->file('photo_right')->getRealPath()), $request->file('photo_right')->getClientOriginalName());
                        }
                        $httpReq->post($runpodUrl, [
                            'name' => $employee->user->name,
                            'employee_code' => $employee->employee_code,
                        ]);
                    } else {
                        Log::info("AI Face Recognition service not configured. Photos saved locally only.");
                    }
                } catch (\Exception $apiException) {
                    Log::error("Failed to update face with AI API: " . $apiException->getMessage());
                }
            }

            DB::commit();
            return $this->success($employee->load('user'), 'Employee updated successfully');
        } catch (\Exception $e) {
            DB::rollBack();
            return $this->error('Failed to update employee: ' . $e->getMessage(), 500);
        }
    }

    // DELETE /api/admin/employees/{id}
    public function destroy(Employee $employee)
    {
        $user = $employee->user;

        // Only soft-delete the employee profile, NOT the user account.
        // Deleting the user makes it impossible to login or re-register.
        // Instead, deactivate the user so the admin can re-add them later.
        $employee->delete();

        if ($user) {
            $user->update(['is_active' => false]);
        }

        return $this->success(null, 'Employee removed successfully');
    }
}
