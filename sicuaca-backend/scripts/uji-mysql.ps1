<#
.SYNOPSIS
  Menjalankan migrasi dan seluruh tes backend di MySQL sungguhan (bukan SQLite)
  pada server MySQL SEMENTARA yang terpisah dari server dan data Anda.

.DESCRIPTION
  - Membuat folder data baru, menginisialisasi server MySQL sementara dengan
    mysqld yang sudah terpasang (tanpa mengunduh apa pun), dan
    menjalankannya di 127.0.0.1:<Port> (hanya lokal).
  - Memberi akun root kata sandi acak yang dibuat saat berjalan dan hanya
    disimpan di variabel lingkungan proses ini (tidak dicetak, tidak ditulis ke
    berkas).
  - Menjalankan `php artisan migrate:fresh` lalu `php artisan test` dengan
    DB_CONNECTION=mysql.
  - Mematikan server dan menghapus folder data (kecuali -Simpan).

  Tidak menyentuh database `sicuaca` pada server MySQL biasa Anda.

.PARAMETER Port
  Port server sementara (bawaan 3307).

.PARAMETER Simpan
  Jangan hapus folder data setelah selesai.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts\uji-mysql.ps1
#>
param(
    [int]$Port = 3307,
    [switch]$Simpan
)

$ErrorActionPreference = 'Continue'
$backend = Split-Path -Parent $PSScriptRoot
$mysqld = (Get-Command mysqld -ErrorAction Stop).Source
$mysqladmin = Join-Path (Split-Path $mysqld) 'mysqladmin.exe'
$mysql = Join-Path (Split-Path $mysqld) 'mysql.exe'
$data = Join-Path $env:TEMP "sicuaca-mysql-uji-$Port"
$log = Join-Path $data 'galat.log'

if ((Test-NetConnection -ComputerName 127.0.0.1 -Port $Port -WarningAction SilentlyContinue).TcpTestSucceeded) {
    throw "Port $Port sudah dipakai. Pakai -Port lain."
}

# Kata sandi acak, hanya di memori proses ini.
$bytes = New-Object byte[] 24
[System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$sandi = [Convert]::ToBase64String($bytes).Replace('+', 'a').Replace('/', 'b').Replace('=', 'c')

$proses = $null
$kodeKeluar = 1
try {
    if (Test-Path $data) { Remove-Item $data -Recurse -Force }
    Write-Host "[1/5] Menginisialisasi server MySQL sementara di $data ..."
    $init = Start-Process -FilePath $mysqld -Wait -PassThru -WindowStyle Hidden `
        -RedirectStandardError (Join-Path $env:TEMP "sicuaca-mysql-init-$Port.log") `
        -ArgumentList @('--no-defaults', '--initialize-insecure', "--datadir=$data")
    if ($init.ExitCode -ne 0) { throw "Inisialisasi MySQL sementara gagal (lihat sicuaca-mysql-init-$Port.log di folder TEMP)." }

    Write-Host "[2/5] Menjalankan server di 127.0.0.1:$Port ..."
    $proses = Start-Process -FilePath $mysqld -PassThru -WindowStyle Hidden -ArgumentList @(
        '--no-defaults', "--datadir=$data", "--port=$Port", '--bind-address=127.0.0.1',
        '--mysqlx=OFF', "--log-error=$log",
        '--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci'
    )
    $siap = $false
    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 1
        & $mysqladmin --no-defaults -h 127.0.0.1 -P $Port -u root ping 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) { $siap = $true; break }
        if ($proses.HasExited) { throw "Server MySQL sementara berhenti (lihat $log)." }
    }
    if (-not $siap) { throw 'Server MySQL sementara tidak siap dalam 60 detik.' }

    Write-Host '[3/5] Membuat database uji dan mengunci akun root ...'
    $sql = "ALTER USER 'root'@'localhost' IDENTIFIED BY '$sandi'; " +
           'CREATE DATABASE sicuaca_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
    & $mysql --no-defaults -h 127.0.0.1 -P $Port -u root -e $sql
    if ($LASTEXITCODE -ne 0) { throw 'Gagal menyiapkan database uji.' }

    $env:DB_CONNECTION = 'mysql'
    $env:DB_HOST = '127.0.0.1'
    $env:DB_PORT = "$Port"
    $env:DB_DATABASE = 'sicuaca_test'
    $env:DB_USERNAME = 'root'
    $env:DB_PASSWORD = $sandi
    $env:APP_ENV = 'testing'

    Push-Location $backend
    try {
        Write-Host '[4/5] Migrasi dari nol di MySQL ...'
        & php artisan migrate:fresh --force --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'Migrasi gagal di MySQL.' }

        Write-Host '[5/5] Seluruh tes di MySQL ...'
        & php artisan test
        $kodeKeluar = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} finally {
    Remove-Item Env:DB_CONNECTION, Env:DB_HOST, Env:DB_PORT, Env:DB_DATABASE, `
        Env:DB_USERNAME, Env:DB_PASSWORD, Env:APP_ENV -ErrorAction SilentlyContinue
    if ($proses -and -not $proses.HasExited) {
        & $mysqladmin --no-defaults -h 127.0.0.1 -P $Port -u root "--password=$sandi" shutdown 2>$null | Out-Null
        Start-Sleep -Seconds 2
        if (-not $proses.HasExited) { Stop-Process -Id $proses.Id -Force }
    }
    if (-not $Simpan -and (Test-Path $data)) { Remove-Item $data -Recurse -Force -ErrorAction SilentlyContinue }
}
exit $kodeKeluar
