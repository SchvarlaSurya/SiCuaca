<#
.SYNOPSIS
  Membuat keystore penandatangan APK rilis SiCuaca dan android\key.properties,
  SEMUA di komputer ini dan di luar git.

.DESCRIPTION
  - Keystore disimpan di $env:USERPROFILE\.sicuaca-keystore\sicuaca-release.jks
    (di luar folder proyek).
  - Kata sandi dibuat acak saat skrip berjalan, ditulis HANYA ke
    android\key.properties (sudah di-ignore git), dan TIDAK dicetak.
  - Menolak menimpa keystore yang sudah ada: kehilangan atau mengganti keystore
    berarti APK baru tidak bisa memperbarui APK lama yang sudah terpasang.

  CADANGKAN setelah selesai (lihat docs\RILIS_ANDROID.md): salin
  sicuaca-release.jks DAN android\key.properties ke tempat aman di luar komputer
  ini (flash disk / penyimpanan pribadi). Jangan dikirim lewat chat/email/git.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tool\buat_keystore.ps1
#>
$ErrorActionPreference = 'Stop'

$proyek = Split-Path -Parent $PSScriptRoot
$folder = Join-Path $env:USERPROFILE '.sicuaca-keystore'
$jks = Join-Path $folder 'sicuaca-release.jks'
$props = Join-Path $proyek 'android\key.properties'

$keytool = (Get-Command keytool -ErrorAction SilentlyContinue).Source
if (-not $keytool) {
    $kandidat = 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe'
    if (Test-Path $kandidat) { $keytool = $kandidat }
}
if (-not $keytool) { throw 'keytool tidak ditemukan (pasang JDK atau Android Studio).' }

if ((Test-Path $jks) -or (Test-Path $props)) {
    throw "Keystore atau key.properties sudah ada. Tidak ditimpa. Hapus manual hanya bila Anda yakin ($jks)."
}

function Buat-Sandi {
    $b = New-Object byte[] 24
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($b)
    [Convert]::ToBase64String($b).Replace('+', 'a').Replace('/', 'b').Replace('=', 'c')
}

New-Item -ItemType Directory -Force -Path $folder | Out-Null
$env:SICUACA_STOREPASS = Buat-Sandi
try {
    # PKCS12: kata sandi keystore dan kunci sama.
    & $keytool -genkeypair -v -keystore $jks -storetype PKCS12 `
        -alias sicuaca -keyalg RSA -keysize 2048 -validity 10000 `
        -storepass:env SICUACA_STOREPASS -keypass:env SICUACA_STOREPASS `
        -dname 'CN=SiCuaca, OU=Proyek Sekolah, O=SiCuaca, C=ID' | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'keytool gagal membuat keystore.' }

    $jalur = $jks.Replace('\', '/')
    $isi = @(
        "storePassword=$($env:SICUACA_STOREPASS)",
        "keyPassword=$($env:SICUACA_STOREPASS)",
        'keyAlias=sicuaca',
        "storeFile=$jalur"
    )
    Set-Content -Path $props -Value $isi -Encoding ASCII
} finally {
    Remove-Item Env:SICUACA_STOREPASS -ErrorAction SilentlyContinue
}

Write-Host 'Keystore dan key.properties dibuat (isi TIDAK ditampilkan).'
Write-Host "  Keystore       : $jks"
Write-Host "  key.properties : $props"
Write-Host 'LANGKAH WAJIB: cadangkan KEDUA berkas itu ke tempat aman di luar komputer ini.'
