<#
.SYNOPSIS
  Membangun APK rilis SiCuaca yang sudah ditandatangani, dengan percobaan ulang.

.DESCRIPTION
  Di Windows, antivirus atau pengindeks kadang mengunci berkas build yang baru
  dibuat sehingga Gradle gagal dengan "The process cannot access the file
  because it is being used by another process". Kegagalan itu acak dan
  hilang bila diulang (langkah yang sudah selesai dilewati). Skrip ini
  mengulang sampai APK jadi (maksimal -Maks kali).

  Prasyarat: android\key.properties ada (jalankan tool\buat_keystore.ps1).

.PARAMETER Maks
  Jumlah percobaan maksimal (bawaan 6).

.PARAMETER PerAbi
  Bangun APK terpisah per arsitektur (lebih kecil) selain APK universal.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\bangun_rilis.ps1
#>
param(
    [int]$Maks = 6,
    [switch]$PerAbi
)

$proyek = Split-Path -Parent $PSScriptRoot
Set-Location $proyek

if (-not (Test-Path 'android\key.properties')) {
    throw 'android\key.properties belum ada. Jalankan tool\buat_keystore.ps1 dulu.'
}

function Bangun([string[]]$argumen, [string]$cari) {
    for ($i = 1; $i -le $Maks; $i++) {
        Write-Host "flutter build apk --release $($argumen -join ' ')  (percobaan $i/$Maks)"
        $keluar = & flutter build apk --release @argumen 2>&1
        $baris = $keluar | Where-Object { $_ -match 'Built build' }
        if ($baris) { $baris | ForEach-Object { Write-Host $_ }; return $true }
        $sebab = $keluar | Where-Object { $_ -match 'being used by another process|Permission denied' } | Select-Object -First 1
        if ($sebab) {
            Write-Host '  gagal karena berkas terkunci (acak), mengulang ...'
            Start-Sleep -Seconds 5
        } else {
            $keluar | Select-Object -Last 25 | ForEach-Object { Write-Host $_ }
            return $false
        }
    }
    return $false
}

$ok = Bangun @() 'app-release.apk'
if ($ok -and $PerAbi) { $ok = Bangun @('--split-per-abi') 'per-abi' }
if (-not $ok) { exit 1 }
Write-Host 'Selesai. APK ada di build\app\outputs\flutter-apk\'
