<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('alerts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('violation_id')->constrained('violations')->onDelete('cascade');
            $table->foreignId('camera_id')->constrained('cameras')->onDelete('cascade');
            $table->string('title');
            $table->text('description');
            $table->enum('severity', ['low','medium','high','critical'])->default('medium');
            $table->enum('status', ['active','resolved','dismissed'])->default('active');
            $table->decimal('confidence', 5, 2)->nullable();
            $table->foreignId('actioned_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('actioned_at')->nullable();
            $table->boolean('is_read')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('alerts'); }
};
