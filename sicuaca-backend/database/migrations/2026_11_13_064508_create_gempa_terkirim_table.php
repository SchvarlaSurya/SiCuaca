<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gempa_terkirim', function (Blueprint $table) {
            $table->id();
            // "<DateTime>|<Coordinates>" dari autogempa.json, mis.
            // "2026-11-13T04:49:34+00:00|-8.22,116.77".
            $table->string('gempa_key')->unique();
            $table->decimal('magnitudo', 3, 1)->nullable();
            $table->string('wilayah');
            // Null bila gempa hanya dicatat tanpa dikirim (eksekusi pertama,
            // magnitudo di bawah ambang terendah, atau FCM gagal).
            $table->timestamp('dikirim_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gempa_terkirim');
    }
};
