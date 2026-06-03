<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class EmployeeRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $isUpdate = $this->isMethod('PUT') || $this->isMethod('PATCH');

        return [
            'name'           => $isUpdate ? 'sometimes|string|max:255'        : 'prohibited',
            'email'          => $isUpdate ? 'sometimes|email|unique:users,email,' . $this->route('employee')?->user_id
                                           : 'required|email',
            'password'       => 'prohibited',
            'department'     => $isUpdate ? 'sometimes|string'                 : 'required|string',
            'position'       => $isUpdate ? 'sometimes|string'                 : 'required|string',
            'join_date'      => $isUpdate ? 'sometimes|date'                   : 'required|date',
            'phone'          => 'nullable|string|max:20',
            'national_id'    => 'nullable|string|max:20',
            'shift_start'    => 'nullable|date_format:H:i',
            'shift_end'      => 'nullable|date_format:H:i',
            'late_threshold' => 'nullable|integer|min:0|max:60',
            'status'         => 'nullable|in:active,inactive,on_leave',
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
