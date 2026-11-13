<?php

namespace App\Providers;

use App\Services\FcmPengirimNotifikasi;
use App\Services\PengirimNotifikasi;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(PengirimNotifikasi::class, FcmPengirimNotifikasi::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
