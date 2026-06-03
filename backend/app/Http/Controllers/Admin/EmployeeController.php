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

        // التحقق أن المستخدم مش عنده Employee Profile بالفعل
        if ($user->employee) {
            return $this->error(
                'This account is already linked to an existing employee profile.',
                422
            );
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
            $employee->user->update(['name' => $request->name]);

            $employee->update([
                'department'     => $request->department,
                'position'       => $request->position,
                'join_date'      => $request->join_date,
                'phone'          => $request->phone,
                'shift_start'    => $request->shift_start,
                'shift_end'      => $request->shift_end,
                'late_threshold' => $request->late_threshold,
                'status'         => $request->status,
            ]);

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
        // خزّن الـ user قبل ما نعمل delete للـ employee
        $user = $employee->user;
        $employee->delete(); // softDelete للـ employee أولاً
        $user?->delete();    // بعدين softDelete للـ user
        return $this->success(null, 'Employee deleted successfully');
    }
}
