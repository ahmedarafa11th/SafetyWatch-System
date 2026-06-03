<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cameras', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('location');
            $table->string('ip_address')->nullable()->unique();
            $table->string('stream_url')->nullable();
            $table->enum('status', ['online', 'offline', 'maintenance'])->default('online');
            $table->boolean('is_entrance')->default(false);
            $table->boolean('is_ai_enabled')->default(true);
            $table->timestamp('last_active_at')->nullable();
            $table->integer('total_alerts')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void { Schema::dropIfExists('cameras'); }
};
