<?php

namespace App\Support;

use RuntimeException;

/** BMKG tidak bisa dihubungi atau membalas dengan status HTTP gagal. */
class BmkgTidakMerespons extends RuntimeException {}
