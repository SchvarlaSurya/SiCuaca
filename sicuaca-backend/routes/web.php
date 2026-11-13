<?php

use App\Http\Controllers\HealthController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Pemantauan: kapan gempa terakhir dicek (200 = normal, 503 = bermasalah).
Route::get('/health', HealthController::class);
