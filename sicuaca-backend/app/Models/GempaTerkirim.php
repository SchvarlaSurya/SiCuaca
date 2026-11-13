<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * Gempa yang sudah diproses, agar notifikasi tidak terkirim dua kali.
 */
class GempaTerkirim extends Model
{
    protected $table = 'gempa_terkirim';

    protected $fillable = ['gempa_key', 'magnitudo', 'wilayah', 'dikirim_at'];

    protected function casts(): array
    {
        return [
            'magnitudo' => 'float',
            'dikirim_at' => 'datetime',
        ];
    }
}
