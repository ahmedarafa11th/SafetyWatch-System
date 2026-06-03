<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class IsEmployee
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || !$request->user()->hasRole('employee')) {
            return response()->json(['status' => false, 'message' => 'Unauthorized. Employee access required.'], 403);
        }
        return $next($request);
    }
}
