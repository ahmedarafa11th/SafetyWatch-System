<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('attendances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('employee_id')->constrained('employees')->onDelete('cascade');
            $table->date('date');
            $table->time('check_in')->nullable();
            $table->time('check_out')->nullable();
            $table->decimal('total_hours', 4, 2)->default(0);
            $table->enum('status', ['present','late','absent','on_leave'])->default('absent');
            $table->enum('check_in_source', ['face_recognition','manual','system'])->default('manual');
            $table->enum('check_out_source', ['face_recognition','manual','system'])->nullable();
            $table->foreignId('check_in_camera_id')->nullable()->constrained('cameras')->onDelete('set null');
            $table->foreignId('check_out_camera_id')->nullable()->constrained('cameras')->onDelete('set null');
            $table->text('notes')->nullable();
            $table->timestamps();
            $table->unique(['employee_id', 'date']);
        });
    }

    public function down(): void { Schema::dropIfExists('attendances'); }
};
