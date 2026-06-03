<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_detection_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('camera_id')->constrained('cameras')->onDelete('cascade');
            $table->enum('detection_type', ['violence','face_recognition','crowd','unusual_activity','safety_check']);
            $table->boolean('is_threat')->default(false);
            $table->decimal('confidence', 5, 2);
            $table->json('raw_result')->nullable();
            $table->string('frame_path')->nullable();
            $table->integer('frame_number')->nullable();
            $table->foreignId('recognized_employee_id')->nullable()->constrained('employees')->onDelete('set null');
            $table->timestamp('processed_at');
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('ai_detection_logs'); }
};
