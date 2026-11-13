<?php

use Illuminate\Support\Facades\Schedule;

// Cek gempa BMKG tiap menit. Lokal: `php artisan schedule:work`.
// Server: cron `* * * * * php /path/ke/artisan schedule:run`.
Schedule::command('sicuaca:cek-gempa')
    ->everyMinute()
    ->withoutOverlapping();
