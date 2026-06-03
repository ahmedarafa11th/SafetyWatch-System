<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('employees', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('employee_code')->unique();
            $table->string('department');
            $table->string('position');
            $table->date('join_date');
            $table->string('phone')->nullable();
            $table->string('national_id')->nullable()->unique();
            $table->string('photo')->nullable();
            $table->time('shift_start')->default('08:00:00');
            $table->time('shift_end')->default('17:00:00');
            $table->integer('late_threshold')->default(15);
            $table->enum('status', ['active', 'inactive', 'on_leave'])->default('active');
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void { Schema::dropIfExists('employees'); }
};
