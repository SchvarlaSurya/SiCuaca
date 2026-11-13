// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'SiCuaca';

  @override
  String get sumberBmkg => 'Sumber: BMKG';

  @override
  String get cobaLagi => 'Coba lagi';

  @override
  String get navBeranda => 'Beranda';

  @override
  String get navCuaca => 'Cuaca';

  @override
  String get navGempa => 'Gempa';

  @override
  String get navPeringatan => 'Peringatan';

  @override
  String get navTentang => 'Tentang';

  @override
  String get errTidakAdaInternet =>
      'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.';

  @override
  String get errTimeout =>
      'Server BMKG terlalu lama merespons. Coba lagi beberapa saat lagi.';

  @override
  String errStatusHttp(String kode) {
    return 'Server BMKG mengembalikan status HTTP $kode.';
  }

  @override
  String get errDataTidakAda => 'Data tidak tersedia untuk lokasi ini.';

  @override
  String get errFormat => 'Format data dari BMKG tidak dikenali.';

  @override
  String get errTakTerduga =>
      'Terjadi kesalahan tak terduga saat mengambil data.';

  @override
  String get modeOffline => 'Mode offline: menampilkan data tersimpan.';

  @override
  String diperbarui(String waktu) {
    return 'Diperbarui: $waktu';
  }

  @override
  String get berandaJudul => 'Beranda';

  @override
  String get berandaKeterangan =>
      'Prakiraan cuaca dan info gempa bumi Indonesia.';

  @override
  String get gempaTabTerbaru => 'Terbaru';

  @override
  String get gempaTabTerkini => 'M 5.0+';

  @override
  String get gempaTabDirasakan => 'Dirasakan';

  @override
  String get gempaTerbaruJudul => 'Gempa terbaru';

  @override
  String get gempaTerbaruKeterangan => 'Gempa terakhir yang dicatat BMKG.';

  @override
  String get gempaTerkiniKeterangan =>
      '15 gempa terakhir dengan magnitudo 5,0 ke atas.';

  @override
  String get gempaDirasakanKeterangan =>
      '15 gempa terakhir yang dirasakan masyarakat.';

  @override
  String get memuatGempa => 'Memuat data gempa…';

  @override
  String get gempaKosong => 'Belum ada data gempa.';

  @override
  String get gempaDetailJudul => 'Detail gempa';

  @override
  String get magnitudo => 'Magnitudo';

  @override
  String get kedalaman => 'Kedalaman';

  @override
  String get waktuKejadian => 'Waktu';

  @override
  String get koordinat => 'Koordinat';

  @override
  String get pusatGempa => 'Pusat gempa';

  @override
  String get potensi => 'Potensi';

  @override
  String get dirasakanDi => 'Dirasakan di';

  @override
  String get jarakDariAnda => 'Jarak dari Anda';

  @override
  String get shakemapJudul => 'Peta guncangan (shakemap)';

  @override
  String get shakemapTidakTersedia =>
      'Peta guncangan tidak tersedia untuk gempa ini.';

  @override
  String get jarakAjak =>
      'Aktifkan lokasi untuk melihat jarak gempa dari posisi Anda.';

  @override
  String jarakKm(String km) {
    return '± $km km dari Anda';
  }

  @override
  String kedalamanSingkat(String nilai) {
    return 'Kedalaman $nilai';
  }

  @override
  String get baruSaja => 'Baru saja';

  @override
  String menitLalu(int n) {
    return '$n menit lalu';
  }

  @override
  String jamLalu(int n) {
    return '$n jam lalu';
  }

  @override
  String hariLalu(int n) {
    return '$n hari lalu';
  }

  @override
  String get cuacaSaatIni => 'Cuaca saat ini';

  @override
  String get memuatCuaca => 'Memuat prakiraan cuaca…';

  @override
  String get kelembapan => 'Kelembapan';

  @override
  String get angin => 'Angin';

  @override
  String get waktuSetempat => 'Waktu setempat';

  @override
  String get tidakAdaPrakiraan => 'Belum ada data prakiraan.';

  @override
  String pukul(String waktu) {
    return 'Pukul $waktu';
  }

  @override
  String kecepatanAngin(String kecepatan, String arah) {
    return '$kecepatan km/j dari $arah';
  }

  @override
  String kecepatanAnginSaja(String kecepatan) {
    return '$kecepatan km/j';
  }

  @override
  String get hariIni => 'Hari ini';

  @override
  String get besok => 'Besok';

  @override
  String get arahN => 'Utara';

  @override
  String get arahNE => 'Timur Laut';

  @override
  String get arahE => 'Timur';

  @override
  String get arahSE => 'Tenggara';

  @override
  String get arahS => 'Selatan';

  @override
  String get arahSW => 'Barat Daya';

  @override
  String get arahW => 'Barat';

  @override
  String get arahNW => 'Barat Laut';

  @override
  String get pilihWilayahJudul => 'Pilih wilayah';

  @override
  String get pilihWilayahKeterangan =>
      'Izinkan akses lokasi atau cari desa/kelurahan untuk melihat prakiraan cuaca.';

  @override
  String get gunakanLokasiSaya => 'Gunakan lokasi saya';

  @override
  String get cariWilayah => 'Cari wilayah';

  @override
  String get gantiWilayah => 'Ganti wilayah';

  @override
  String get mencariLokasi => 'Mencari lokasi Anda…';

  @override
  String get cariHint => 'Cari desa, kelurahan, atau kecamatan';

  @override
  String get cariMinimal => 'Ketik minimal 3 huruf.';

  @override
  String get cariTidakAdaHasil => 'Wilayah tidak ditemukan.';

  @override
  String get memuatDataWilayah => 'Memuat data wilayah…';

  @override
  String get gagalMemuatDataWilayah =>
      'Data wilayah tidak bisa dimuat. Pasang ulang aplikasi bila masalah berlanjut.';

  @override
  String get favorit => 'Favorit';

  @override
  String get belumAdaFavorit =>
      'Belum ada wilayah favorit. Ketuk ikon bintang untuk menyimpan.';

  @override
  String get tambahFavorit => 'Tambah ke favorit';

  @override
  String get hapusFavorit => 'Hapus dari favorit';

  @override
  String get gpsLayananMati =>
      'Layanan lokasi (GPS) sedang mati. Nyalakan lalu coba lagi, atau cari wilayah secara manual.';

  @override
  String get gpsDitolak =>
      'Izin lokasi ditolak. Anda tetap bisa mencari wilayah secara manual.';

  @override
  String get gpsDitolakPermanen =>
      'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi, atau cari wilayah secara manual.';

  @override
  String get gpsGagal =>
      'Lokasi Anda tidak bisa ditentukan. Silakan pilih wilayah secara manual.';

  @override
  String get gpsDiluarWilayah =>
      'Lokasi Anda tidak cocok dengan desa/kelurahan mana pun di Indonesia. Silakan pilih wilayah secara manual.';

  @override
  String get bukaPengaturanAplikasi => 'Buka pengaturan aplikasi';

  @override
  String get bukaPengaturanLokasi => 'Buka pengaturan lokasi';

  @override
  String get channelGempaNama => 'Gempa bumi';

  @override
  String get channelGempaDeskripsi =>
      'Notifikasi gempa baru sesuai ambang magnitudo yang dipilih.';

  @override
  String get notifJudul => 'Notifikasi gempa';

  @override
  String get notifKeterangan =>
      'Kirim notifikasi saat terjadi gempa dengan magnitudo minimal:';

  @override
  String get notifMati => 'Mati';

  @override
  String get notifMatiKeterangan => 'Tidak menerima notifikasi gempa';

  @override
  String get notifM4 => 'M 4,0 ke atas';

  @override
  String get notifM5 => 'M 5,0 ke atas';

  @override
  String get notifM6 => 'M 6,0 ke atas';

  @override
  String get notifM4Keterangan => 'Termasuk gempa kecil yang terasa';

  @override
  String get notifM5Keterangan => 'Gempa sedang hingga kuat';

  @override
  String get notifM6Keterangan => 'Hanya gempa kuat';

  @override
  String get notifBelumAktif =>
      'Notifikasi belum aktif di perangkat ini: Firebase belum dikonfigurasi atau platform tidak didukung.';

  @override
  String get notifIzinDitolak =>
      'Izin notifikasi ditolak. Aktifkan lewat pengaturan aplikasi agar notifikasi gempa bisa muncul.';

  @override
  String get notifGagalLangganan =>
      'Pengaturan notifikasi gagal disimpan. Periksa koneksi internet lalu coba lagi.';

  @override
  String get notifSumber =>
      'Notifikasi dikirim server SiCuaca berdasarkan data gempa terbaru. Sumber: BMKG';

  @override
  String get notifBahasaCatatan =>
      'Teks notifikasi dikirim server dalam Bahasa Indonesia.';

  @override
  String get peringatanDiniSegera => 'Peringatan dini cuaca: segera hadir';

  @override
  String get peringatanKeterangan =>
      'Peringatan dini cuaca ekstrem untuk wilayah Anda.';

  @override
  String get tentangKeterangan =>
      'Aplikasi prakiraan cuaca dan info gempa bumi Indonesia.';

  @override
  String get tentangSumber =>
      'Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika). SiCuaca bukan aplikasi resmi BMKG.';

  @override
  String get tentangDataWilayah =>
      'Data kode dan koordinat wilayah: cahyadsn/wilayah dan cahyadsn/wilayah_boundaries (lisensi MIT), mengikuti Kepmendagri No 300.2.2-2430 Tahun 2025.';

  @override
  String get tentangPengaturan => 'Pengaturan';

  @override
  String get tentangKredit => 'Kredit dan sumber data';

  @override
  String get tentangBahasa => 'Bahasa';

  @override
  String get tentangTema => 'Tema';

  @override
  String get tentangVersi => 'Versi aplikasi';

  @override
  String versiAplikasi(String versi, String build) {
    return '$versi (build $build)';
  }

  @override
  String get ikutiSistem => 'Ikuti sistem';

  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';

  @override
  String get bahasaInggris => 'English';

  @override
  String get temaTerang => 'Terang';

  @override
  String get temaGelap => 'Gelap';

  @override
  String get lisensiSumberTerbuka => 'Lisensi sumber terbuka';

  @override
  String get lisensiDataWilayah => 'Data wilayah (cahyadsn)';

  @override
  String get selengkapnya => 'Selengkapnya';

  @override
  String dataTerakhir(String waktu) {
    return 'Data terakhir diperbarui $waktu';
  }

  @override
  String get prakiraanPer3Jam => 'Prakiraan per 3 jam';

  @override
  String get magKecil => 'Kecil';

  @override
  String get magRingan => 'Ringan';

  @override
  String get magSedang => 'Sedang';

  @override
  String get magKuat => 'Kuat';

  @override
  String get magBesar => 'Besar';

  @override
  String get magTakDiketahui => 'Tak diketahui';

  @override
  String magnitudoSemantik(String nilai, String tingkat) {
    return 'Magnitudo $nilai, tingkat $tingkat';
  }

  @override
  String get navPengaturan => 'Pengaturan';

  @override
  String get pengaturanTampilan => 'Tampilan';

  @override
  String get tentangJudul => 'Tentang SiCuaca';

  @override
  String get dataTidakTersedia => 'Data tidak tersedia untuk lokasi ini.';

  @override
  String get pilihDariDaftar => 'Pilih dari daftar wilayah';

  @override
  String get pilihDariDaftarKeterangan =>
      'Provinsi, kabupaten/kota, kecamatan, lalu desa/kelurahan';

  @override
  String get pilihProvinsi => 'Pilih provinsi';

  @override
  String get pilihKabKota => 'Pilih kabupaten/kota';

  @override
  String get pilihKecamatan => 'Pilih kecamatan';

  @override
  String get pilihDesa => 'Pilih desa/kelurahan';

  @override
  String get saringDaftar => 'Saring daftar';

  @override
  String get semuaWilayah => 'Indonesia';
}
