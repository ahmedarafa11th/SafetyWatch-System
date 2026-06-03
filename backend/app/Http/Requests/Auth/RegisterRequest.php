<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'name'     => 'required|string|max:255',
            'email'    => [
                'required',
                'email',
                'unique:users,email',
            ],
            'password' => [
                'required',
                'confirmed',
                Password::min(8)
                    ->mixedCase()
                    ->numbers()
                    ->symbols(),
            ],
            'role'     => 'sometimes|in:admin,employee',
        ];
    }

    public function messages(): array
    {
        return [
            'password.min'      => 'Password must be at least 8 characters.',
            'password.mixed'    => 'Password must contain uppercase and lowercase letters.',
            'password.numbers'  => 'Password must contain at least one number.',
            'password.symbols'  => 'Password must contain at least one special character (!@#$%).',
            'password.confirmed'=> 'Passwords do not match.',
        ];
    }

    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            response()->json([
                'status'  => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422)
        );
    }
}

