<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $tables = ['employees', 'cameras', 'alerts', 'attendances', 'violations', 'ai_detection_logs'];

        foreach ($tables as $table) {
            Schema::table($table, function (Blueprint $table_blueprint) {
                $table_blueprint->unsignedBigInteger('admin_id')->nullable()->after('id');
                $table_blueprint->foreign('admin_id')->references('id')->on('users')->onDelete('cascade');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        $tables = ['employees', 'cameras', 'alerts', 'attendances', 'violations', 'ai_detection_logs'];

        foreach ($tables as $table) {
            Schema::table($table, function (Blueprint $table_blueprint) {
                $table_blueprint->dropForeign(['admin_id']);
                $table_blueprint->dropColumn('admin_id');
            });
        }
    }
};
