<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class IsAdmin
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->user() || !$request->user()->hasRole('admin')) {
            return response()->json(['status' => false, 'message' => 'Unauthorized. Admin access required.'], 403);
        }
        return $next($request);
    }
}
