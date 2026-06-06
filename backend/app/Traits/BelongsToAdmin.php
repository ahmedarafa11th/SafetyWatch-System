<?php

namespace App\Traits;

use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

trait BelongsToAdmin
{
    protected static function bootBelongsToAdmin()
    {
        static::creating(function ($model) {
            if (auth()->check()) {
                $user = auth()->user();
                if ($user->hasRole('admin')) {
                    $model->admin_id = $user->id;
                } elseif ($user->hasRole('employee')) {
                    $employee = \App\Models\Employee::withoutGlobalScopes()->where('user_id', $user->id)->first();
                    if ($employee) {
                        $model->admin_id = $employee->admin_id;
                    }
                }
            }
        });

        static::addGlobalScope('admin', function (Builder $builder) {
            if (auth()->check()) {
                $user = auth()->user();
                if ($user->hasRole('admin')) {
                    $builder->where('admin_id', $user->id);
                } elseif ($user->hasRole('employee')) {
                    $employee = \App\Models\Employee::withoutGlobalScopes()->where('user_id', $user->id)->first();
                    if ($employee) {
                        $builder->where('admin_id', $employee->admin_id);
                    }
                }
            }
        });
    }

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }
}
