<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    use ApiResponse;

    // POST /api/auth/register
    public function register(RegisterRequest $request)
    {
        $role = $request->role ?? 'employee';
        $isAdmin = $role === 'admin';

        $user = User::create([
            'name'      => $request->name,
            'email'     => $request->email,
            'password'  => Hash::make($request->password),
            'is_active' => $isAdmin, // Admins don't need approval
        ]);

        $user->assignRole($role);

        // No token issued immediately — user must log in manually
        $message = $isAdmin 
            ? 'Account created successfully.' 
            : 'Account created successfully. Please wait for admin approval.';

        return $this->success([
            'user' => $this->formatUser($user),
        ], $message, 201);
    }

    // POST /api/auth/login
    public function login(LoginRequest $request)
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return $this->error('Invalid email or password.', 401);
        }

        if (!$user->is_active) {
            return $this->error(
                'Your account is pending admin approval. Please wait until an admin activates your account.',
                403
            );
        }

        $user->updateLastLogin();

        $token = $user->createToken('safetywatch_token')->plainTextToken;

        return $this->success([
            'user'  => $this->formatUser($user),
            'token' => $token,
        ], 'Login successful');
    }

    // POST /api/auth/logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return $this->success(null, 'Logged out successfully');
    }

    // GET /api/auth/me
    public function me(Request $request)
    {
        $user = $request->user()->load('employee');
        return $this->success([
            'id'       => $user->id,
            'name'     => $user->name,
            'email'    => $user->email,
            'role'     => $user->getRoleNames()->first(),
            'employee' => $user->employee,
        ]);
    }

    private function formatUser(User $user): array
    {
        return [
            'id'    => $user->id,
            'name'  => $user->name,
            'email' => $user->email,
            'role'  => $user->getRoleNames()->first(),
        ];
    }
}
