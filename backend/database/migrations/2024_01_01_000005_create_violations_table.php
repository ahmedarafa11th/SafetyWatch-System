<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('violations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('camera_id')->constrained('cameras')->onDelete('cascade');
            $table->foreignId('employee_id')->nullable()->constrained('employees')->onDelete('set null');
            $table->enum('type', ['violence','restricted_area','unusual_activity','crowd_detection','safety_violation','unauthorized_presence','unknown']);
            $table->text('description');
            $table->string('snapshot')->nullable();
            $table->enum('severity', ['low','medium','high','critical'])->default('medium');
            $table->enum('status', ['active','under_investigation','resolved','dismissed'])->default('active');
            $table->decimal('confidence', 5, 2)->nullable();
            $table->foreignId('ai_detection_log_id')->nullable()->constrained('ai_detection_logs')->onDelete('set null');
            $table->timestamp('detected_at');
            $table->timestamp('resolved_at')->nullable();
            $table->foreignId('resolved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('violations'); }
};
