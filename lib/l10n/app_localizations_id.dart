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

  @override
  String get riwayatJudul => 'Riwayat Gempa';

  @override
  String get riwayatKosong =>
      'Belum ada riwayat gempa. Muat data gempa terlebih dahulu.';

  @override
  String riwayatJumlah(int n) {
    return '$n kejadian ditampilkan';
  }

  @override
  String get riwayatTidakCocok => 'Tidak ada data yang cocok dengan filter.';

  @override
  String get semuaMagnitudo => 'Semua magnitudo';

  @override
  String get dalam100Km => 'Dalam 100 km';

  @override
  String get statTerbesar => 'Terbesar';

  @override
  String get statTerdekat => 'Terdekat';

  @override
  String get statTotal => 'Total';

  @override
  String get siagaJudul => 'Siaga Gempa';

  @override
  String get siagaSebelum => 'Sebelum gempa';

  @override
  String get siagaSaat => 'Saat gempa';

  @override
  String get siagaSetelah => 'Setelah gempa';

  @override
  String tasSiagaJudul(String selesai, String total) {
    return 'Checklist tas siaga ($selesai/$total)';
  }

  @override
  String get siagaCatatan =>
      'Panduan ini bersifat edukasi. Ikuti arahan resmi pemerintah dan BMKG saat keadaan darurat.';

  @override
  String get salinRingkasan => 'Salin ringkasan';

  @override
  String get ringkasanDisalin => 'Ringkasan disalin ke clipboard.';

  @override
  String ringkasanGempa(
    String magnitudo,
    String wilayah,
    String waktu,
    String kedalaman,
  ) {
    return 'Gempa M $magnitudo di $wilayah, $waktu. Kedalaman $kedalaman. Sumber: BMKG.';
  }

  @override
  String get bagikan => 'Bagikan';

  @override
  String get bagikanCuaca => 'Bagikan info cuaca';

  @override
  String get bagikanGempa => 'Bagikan info gempa';

  @override
  String get onboardingLewati => 'Lewati';

  @override
  String get onboardingLanjut => 'Lanjut';

  @override
  String get onboardingMulai => 'Mulai';

  @override
  String get onboardingCuacaJudul => 'Prakiraan Cuaca Akurat';

  @override
  String get onboardingCuacaDeskripsi =>
      'Pantau cuaca terkini dan prakiraan per 3 jam di seluruh pelosok desa dan kelurahan Indonesia langsung dari BMKG.';

  @override
  String get onboardingGempaJudul => 'Info & Notifikasi Gempa';

  @override
  String get onboardingGempaDeskripsi =>
      'Ketahui gempa terbaru, magnitudo, jarak dari lokasi Anda, serta terima notifikasi otomatis saat terjadi gempa.';

  @override
  String get onboardingWilayahJudul => 'Pencarian Wilayah Mudah';

  @override
  String get onboardingWilayahDeskripsi =>
      'Gunakan GPS untuk mendeteksi wilayah Anda secara instan atau cari lebih dari 80.000 desa/kelurahan di Indonesia.';

  @override
  String get panduanAplikasi => 'Panduan aplikasi';

  @override
  String get panduanAplikasiKeterangan =>
      'Lihat kembali slide pengenalan fitur SiCuaca';

  @override
  String bagikanCuacaJudul(String lokasi) {
    return '🌤️ Cuaca di $lokasi';
  }

  @override
  String get bagikanGempaJudul => '⚠️ Info gempa bumi';

  @override
  String get bagikanSumber => 'Sumber: BMKG · via SiCuaca';

  @override
  String get subjudulBeranda => 'Cuaca dan gempa untuk hari ini';

  @override
  String get subjudulCuaca => 'Prakiraan lokal dari BMKG';

  @override
  String get subjudulGempa => 'Informasi seismik terkini';

  @override
  String get subjudulPeringatan => 'Atur notifikasi yang kamu perlukan';

  @override
  String get subjudulPengaturan => 'Sesuaikan pengalaman SiCuaca';

  @override
  String get bandingkanFavorit => 'Bandingkan favorit';

  @override
  String get bandingkanJudul => 'Bandingkan cuaca';

  @override
  String bandingkanKeterangan(String n) {
    return 'Membandingkan $n dari maksimal 3 wilayah favorit.';
  }

  @override
  String get kartuCuaca => 'Kartu Cuaca';

  @override
  String get bukanResmi => 'SiCuaca bukan aplikasi resmi BMKG.';

  @override
  String ringkasanCuaca(
    String lokasi,
    String kondisi,
    String suhu,
    String catatan,
  ) {
    return 'Cuaca di $lokasi: $kondisi, $suhu. ${catatan}Sumber: BMKG. SiCuaca bukan aplikasi resmi BMKG.';
  }

  @override
  String get bagikanKartuCuaca => 'Bagikan kartu cuaca';

  @override
  String get salinRingkasanTeks => 'Salin ringkasan teks';

  @override
  String get ringkasanCuacaDisalin => 'Ringkasan cuaca disalin';

  @override
  String get gempaSiagaJudul => 'Tetap siaga, tetap tenang';

  @override
  String get gempaSiagaKeterangan =>
      'Pantau informasi resmi dan siapkan langkah aman.';

  @override
  String get pengaturanIntro =>
      'Tampilan, bahasa, dan notifikasi tersimpan aman di perangkat ini.';

  @override
  String get peringatanIntro =>
      'Pilih ambang magnitudo agar pemberitahuan yang diterima tetap relevan untukmu.';

  @override
  String get jejakAktivitas => 'Jejak aktivitas';

  @override
  String get cariWilayahGempa => 'Cari wilayah gempa';

  @override
  String get hapusPencarian => 'Hapus pencarian';

  @override
  String get rentangGrafik => 'Rentang grafik';

  @override
  String get grafikPerHari => 'Grafik per hari';

  @override
  String get grafikPerMinggu => 'Grafik per minggu';

  @override
  String get saringMagnitudo => 'Filter magnitudo';

  @override
  String minimalMagnitudo(String nilai) {
    return 'Minimal M$nilai';
  }

  @override
  String get gempaDalam100Km => 'Gempa dalam 100 km';

  @override
  String get gempaPerHari => 'Gempa per hari';

  @override
  String get gempaPerMinggu => 'Gempa per minggu';

  @override
  String get grafikCatatan =>
      'Berdasarkan riwayat yang tersimpan di perangkat. Ini bukan jumlah seluruh kejadian BMKG.';

  @override
  String mingguKe(String n) {
    return 'Minggu $n';
  }

  @override
  String jumlahKejadian(int n) {
    return '$n kejadian';
  }

  @override
  String totalGrafik(int n) {
    return 'Total pada grafik: $n kejadian';
  }

  @override
  String get siagaHeroJudul => 'Kesiapsiagaan dimulai sebelum terjadi gempa.';

  @override
  String get siagaHeroKeterangan =>
      'Pelajari langkah aman dan lengkapi tas siaga secara bertahap.';

  @override
  String get grafikSuhuJudul => '24 jam ke depan';

  @override
  String grafikSuhuSemantik(
    String sekarang,
    String tertinggi,
    String terendah,
  ) {
    return 'Suhu 24 jam ke depan: sekarang $sekarang derajat, tertinggi $tertinggi, terendah $terendah';
  }

  @override
  String sapaPagi(String lokasi) {
    return 'Selamat pagi, $lokasi';
  }

  @override
  String sapaSiang(String lokasi) {
    return 'Selamat siang, $lokasi';
  }

  @override
  String sapaSore(String lokasi) {
    return 'Selamat sore, $lokasi';
  }

  @override
  String sapaMalam(String lokasi) {
    return 'Selamat malam, $lokasi';
  }

  @override
  String get riwayatNotifJudul => 'Riwayat notifikasi';

  @override
  String get riwayatNotifKeterangan =>
      'Gempa yang pernah dikirimi notifikasi ke perangkat ini.';

  @override
  String get riwayatNotifKosong =>
      'Belum ada notifikasi gempa yang diterima. Pilih ambang magnitudo di Peringatan agar notifikasi masuk.';

  @override
  String diterimaWaktu(String waktu) {
    return 'Diterima $waktu';
  }

  @override
  String get hapusRiwayat => 'Hapus riwayat';

  @override
  String get hapusRiwayatKonfirmasi =>
      'Hapus seluruh riwayat notifikasi di perangkat ini? Tindakan ini tidak bisa dibatalkan.';

  @override
  String get aksiBatal => 'Batal';

  @override
  String get aksiHapus => 'Hapus';

  @override
  String get urutanBerandaJudul => 'Urutan Beranda';

  @override
  String get urutanBerandaKeterangan =>
      'Seret atau pakai tombol panah untuk mengubah urutan bagian di Beranda.';

  @override
  String get urutanBerandaRingkas => 'Atur urutan bagian di Beranda';

  @override
  String get setelUlangUrutan => 'Setel ulang urutan';

  @override
  String naikkanBagian(String nama) {
    return 'Naikkan $nama';
  }

  @override
  String turunkanBagian(String nama) {
    return 'Turunkan $nama';
  }

  @override
  String get riwayatBiasLabel => 'Dari data yang tersimpan di perangkat ini';

  @override
  String riwayatRentangData(String mulai, String akhir) {
    return 'Data tersimpan: $mulai – $akhir';
  }

  @override
  String get riwayatBiasCatatan =>
      'BMKG hanya menyediakan daftar gempa terbaru, jadi riwayat ini hanya berisi gempa yang pernah dimuat atau diterima di perangkat ini. Angkanya bukan statistik lengkap kejadian gempa di Indonesia.';

  @override
  String riwayatDariTotal(String n, String total) {
    return '$n dari $total data tersimpan';
  }

  @override
  String get statJumlahGempa => 'Jumlah gempa';

  @override
  String get statLokasiTidakAda => 'Lokasi tidak tersedia';

  @override
  String get statLabelBias =>
      'Statistik dari data yang tersimpan di perangkat ini';

  @override
  String get riwayatGagalMuat =>
      'Riwayat gempa tidak bisa dibaca dari penyimpanan perangkat. Coba lagi.';

  @override
  String get riwayatKosongCatatan =>
      'Riwayat terisi otomatis saat data gempa BMKG dimuat atau notifikasi gempa diterima.';

  @override
  String get filterJudul => 'Filter riwayat';

  @override
  String get filterTanggal => 'Rentang tanggal';

  @override
  String get filterSemuaTanggal => 'Semua tanggal';

  @override
  String filterHariTerakhir(String n) {
    return '$n hari terakhir';
  }

  @override
  String get filterPilihTanggal => 'Pilih tanggal';

  @override
  String get filterPilihTanggalBantuan => 'Pilih rentang tanggal kejadian';

  @override
  String get filterMagnitudo => 'Magnitudo minimum';

  @override
  String get filterJarak => 'Jarak maksimum dari Anda';

  @override
  String get filterSemuaJarak => 'Semua jarak';

  @override
  String filterJarakKm(String km) {
    return '$km km';
  }

  @override
  String get filterJarakNonaktif =>
      'Filter jarak tidak bisa dipakai karena lokasi Anda belum diketahui. Aktifkan lokasi untuk memakainya.';

  @override
  String get filterTerapkan => 'Terapkan';

  @override
  String get filterSetelUlang => 'Setel ulang';

  @override
  String filterAktifJumlah(String n) {
    return 'Filter aktif: $n';
  }

  @override
  String get pSebelumG1 => 'Kunci utama';

  @override
  String get pSebelumG1B1 => 'Mengenali apa yang disebut gempabumi;';

  @override
  String get pSebelumG1B2 =>
      'Pastikan bahwa struktur dan letak rumah Anda dapat terhindar dari bahaya yang disebabkan oleh gempabumi (longsor, liquefaction, dll.);';

  @override
  String get pSebelumG1B3 =>
      'Mengevaluasi dan merenovasi ulang struktur bangunan Anda agar terhindar dari bahaya gempabumi.';

  @override
  String get pSebelumG2 => 'Kenali lingkungan tempat Anda bekerja';

  @override
  String get pSebelumG2B1 =>
      'Perhatikan letak pintu, lift serta tangga darurat; apabila terjadi gempabumi, sudah mengetahui tempat paling aman untuk berlindung;';

  @override
  String get pSebelumG2B2 => 'Belajar melakukan P3K;';

  @override
  String get pSebelumG2B3 => 'Belajar menggunakan alat pemadam kebakaran;';

  @override
  String get pSebelumG2B4 =>
      'Catat nomor telepon penting yang dapat dihubungi pada saat terjadi gempabumi.';

  @override
  String get pSebelumG3 =>
      'Persiapan rutin pada tempat Anda bekerja dan tinggal';

  @override
  String get pSebelumG3B1 =>
      'Perabotan (lemari, cabinet, dll.) diatur menempel pada dinding (dipaku, diikat, dll.) untuk menghindari jatuh, roboh, bergeser pada saat terjadi gempabumi;';

  @override
  String get pSebelumG3B2 =>
      'Simpan bahan yang mudah terbakar pada tempat yang tidak mudah pecah agar terhindar dari kebakaran;';

  @override
  String get pSebelumG3B3 =>
      'Selalu mematikan air, gas dan listrik apabila tidak sedang digunakan.';

  @override
  String get pSebelumG4 =>
      'Penyebab celaka yang paling banyak pada saat gempabumi adalah akibat kejatuhan material';

  @override
  String get pSebelumG4B1 =>
      'Atur benda yang berat sedapat mungkin berada pada bagian bawah;';

  @override
  String get pSebelumG4B2 =>
      'Cek kestabilan benda yang tergantung yang dapat jatuh pada saat gempabumi terjadi (misalnya lampu, dll.).';

  @override
  String get pSebelumG5 => 'Alat yang harus ada di setiap tempat';

  @override
  String get pSebelumG5B1 => 'Kotak P3K;';

  @override
  String get pSebelumG5B2 => 'Senter/lampu baterai;';

  @override
  String get pSebelumG5B3 => 'Radio;';

  @override
  String get pSebelumG5B4 => 'Makanan suplemen dan air.';

  @override
  String get pSaatG1 => 'Jika Anda berada di dalam bangunan';

  @override
  String get pSaatG1B1 =>
      'Lindungi kepala dan badan Anda dari reruntuhan bangunan (dengan bersembunyi di bawah meja, dll.);';

  @override
  String get pSaatG1B2 =>
      'Mencari tempat yang paling aman dari reruntuhan goncangan;';

  @override
  String get pSaatG1B3 => 'Berlari keluar apabila masih dapat dilakukan.';

  @override
  String get pSaatG2 => 'Jika berada di luar bangunan atau area terbuka';

  @override
  String get pSaatG2B1 =>
      'Menghindari bangunan yang ada di sekitar Anda (seperti gedung, tiang listrik, pohon, dll.);';

  @override
  String get pSaatG2B2 =>
      'Perhatikan tempat Anda berpijak, hindari apabila terjadi rekahan tanah.';

  @override
  String get pSaatG3 => 'Jika Anda sedang mengendarai mobil';

  @override
  String get pSaatG3B1 =>
      'Keluar, turun, dan menjauh dari mobil, hindari jika terjadi pergeseran atau kebakaran;';

  @override
  String get pSaatG3B2 =>
      'Perhatikan tempat Anda berpijak, hindari apabila terjadi rekahan tanah.';

  @override
  String get pSaatG4 => 'Jika Anda tinggal atau berada di pantai';

  @override
  String get pSaatG4B1 => 'Jauhi pantai untuk menghindari terjadinya tsunami.';

  @override
  String get pSaatG5 => 'Jika Anda tinggal di daerah pegunungan';

  @override
  String get pSaatG5B1 =>
      'Apabila terjadi gempa bumi hindari daerah yang mungkin terjadi longsoran.';

  @override
  String get pSetelahG1 => 'Jika Anda berada di dalam bangunan';

  @override
  String get pSetelahG1B1 => 'Keluar dari bangunan tersebut dengan tertib;';

  @override
  String get pSetelahG1B2 =>
      'Jangan menggunakan tangga berjalan atau lift, gunakan tangga biasa;';

  @override
  String get pSetelahG1B3 => 'Periksa apakah ada yang terluka, lakukan P3K;';

  @override
  String get pSetelahG1B4 =>
      'Telepon/minta pertolongan apabila terjadi luka parah pada Anda atau sekitar Anda.';

  @override
  String get pSetelahG2 => 'Periksa lingkungan sekitar Anda';

  @override
  String get pSetelahG2B1 => 'Periksa apabila terjadi kebakaran;';

  @override
  String get pSetelahG2B2 => 'Periksa apabila terjadi kebocoran gas;';

  @override
  String get pSetelahG2B3 => 'Periksa apabila terjadi arus pendek;';

  @override
  String get pSetelahG2B4 => 'Periksa aliran dan pipa air;';

  @override
  String get pSetelahG2B5 =>
      'Periksa segala hal yang dapat membahayakan (mematikan listrik, tidak menyalakan api, dll.).';

  @override
  String get pSetelahG3 => 'Jangan memasuki bangunan yang sudah terjadi gempa';

  @override
  String get pSetelahG3B1 =>
      'Bangunan yang sudah terjadi gempa menjadi rawan mengalami keruntuhan.';

  @override
  String get pSetelahG4 => 'Jangan berjalan di sekitar daerah gempa';

  @override
  String get pSetelahG4B1 =>
      'Gempa susulan masih mungkin terjadi di sekitar daerah gempa.';

  @override
  String get pSetelahG5 => 'Mendengarkan informasi';

  @override
  String get pSetelahG5B1 =>
      'Dengarkan informasi mengenai gempabumi dari radio (apabila terjadi gempa susulan);';

  @override
  String get pSetelahG5B2 =>
      'Jangan mudah terpancing oleh isu atau berita yang tidak jelas sumbernya.';

  @override
  String get pSetelahG6 =>
      'Mengisi angket yang diberikan oleh instansi terkait';

  @override
  String get pSetelahG6B1 =>
      'Pengisian angket tersebut dilakukan untuk mengetahui seberapa besar kerusakan yang terjadi di lokasi kejadian gempa.';

  @override
  String get pSetelahG7 =>
      'Jangan panik dan jangan lupa selalu berdoa kepada Tuhan Yang Maha Esa';

  @override
  String get pSetelahG7B1 =>
      'Berdoa kepada Tuhan Yang Maha Esa demi keamanan dan keselamatan kita semua.';

  @override
  String get tasItem1 =>
      'Surat-surat penting (surat tanah, surat kendaraan, ijazah, akta kelahiran, dan lain-lain)';

  @override
  String get tasItem2 =>
      'Sandang untuk tiga hari: pakaian dalam, celana panjang, jaket, selimut, handuk, jas hujan, dan lain-lain';

  @override
  String get tasItem3 =>
      'Makanan ringan tahan lama (mi instan, biskuit, abon, cokelat, dan lain-lain)';

  @override
  String get tasItem4 => 'Air minum (cukup untuk kurang lebih tiga hari)';

  @override
  String get tasItem5 =>
      'Kotak P3K berisi obat-obatan pribadi dan obat-obatan umum lainnya';

  @override
  String get tasItem6 =>
      'Radio/ponsel beserta baterai, pengisi daya, atau powerbank untuk memantau informasi bencana';

  @override
  String get tasItem7 =>
      'Perlengkapan mandi (sabun mandi, sikat gigi, odol, sisir, cotton bud, dan lain-lain)';

  @override
  String get tasItem8 => 'Masker (penyaring udara kotor/tercemar)';

  @override
  String get tasItem9 => 'Peluit (alat bantu meminta pertolongan saat darurat)';

  @override
  String get tasItem10 =>
      'Uang tunai secukupnya untuk perbekalan kurang lebih tiga hari';

  @override
  String get tasItem11 =>
      'Alat penerangan: senter, lampu kepala (headlamp), korek api, lilin, dan lain-lain';

  @override
  String get istilah_magnitudo_Nama => 'Magnitudo';

  @override
  String get istilah_magnitudo_Isi => 'Kekuatan gempa dalam skala Richter.';

  @override
  String get istilah_richter_Nama => 'Skala Richter';

  @override
  String get istilah_richter_Isi =>
      'Ukuran kekuatan gempabumi yang dihitung dari besarnya energi yang dilepaskan dari sumber gempa tersebut.';

  @override
  String get istilah_kedalaman_Nama => 'Kedalaman';

  @override
  String get istilah_kedalaman_Isi => 'Kedalaman gempa dalam kilometer.';

  @override
  String get istilah_mmi_Nama => 'Skala MMI (Modified Mercalli Intensity)';

  @override
  String get istilah_mmi_Isi =>
      'Ukuran kekuatan gempa bumi berdasarkan kerusakan yang diakibatkan oleh gempa tersebut.';

  @override
  String get istilah_waktu_Nama => 'Waktu kejadian';

  @override
  String get istilah_waktu_Isi => 'Waktu terjadinya gempa dalam WIB.';

  @override
  String siagaSumber(String nama) {
    return 'Sumber: $nama';
  }

  @override
  String get siagaTerjemahan =>
      'Teks panduan mengikuti sumber resmi di atas. Terjemahan bahasa Inggris dibuat oleh tim SiCuaca, bukan terjemahan resmi.';

  @override
  String get siagaIstilahJudul => 'Istilah gempa';

  @override
  String get tasSumberCatatan =>
      'Daftar tas siaga bencana dari BNPB. Sesuaikan dengan kebutuhan keluarga Anda.';

  @override
  String tasProgres(String n, String total) {
    return '$n dari $total siap';
  }

  @override
  String tasProgresBeranda(String n, String total) {
    return 'Tas siaga: $n dari $total siap';
  }

  @override
  String get splashTagline => 'Cuaca dan gempa dari data terbuka BMKG';

  @override
  String get onboardingSiagaJudul => 'Siap Siaga Gempa';

  @override
  String get onboardingSiagaDeskripsi =>
      'Pelajari langkah aman sebelum, saat, dan setelah gempa, lalu lengkapi tas siaga Anda. Isinya bersumber dari BMKG dan BNPB.';

  @override
  String get onboardingSumber =>
      'Sumber data: BMKG. SiCuaca bukan aplikasi resmi BMKG.';

  @override
  String get kacaCairJudul => 'Efek kaca cair';

  @override
  String get kacaCairKeterangan =>
      'Pembiasan kaca dan animasi tombol jeli. Matikan bila HP terasa berat; navbar dan tombol tetap ada dengan kaca sederhana.';

  @override
  String get lainnya => 'Lainnya';

  @override
  String get layananJudul => 'Layanan BMKG lainnya';

  @override
  String get layananRingkas =>
      'Cuaca maritim, radar, penerbangan, titik panas, iklim, siaran pers';

  @override
  String get layananTautanCatatan =>
      'Layanan bertanda \"Halaman resmi\" dibuka di situs BMKG; isinya tidak disalin ke SiCuaca.';

  @override
  String get layananBukaResmi => 'Buka halaman resmi';

  @override
  String get layananGagalBuka => 'Halaman resmi tidak bisa dibuka.';

  @override
  String get layananLabelTautan => 'Halaman resmi';

  @override
  String get layananMaritimJudul => 'Cuaca maritim';

  @override
  String get layananMaritimKet =>
      'Tinggi gelombang, angin, dan arus di perairan terdekat.';

  @override
  String get layananRadarJudul => 'Radar cuaca';

  @override
  String get layananRadarKet =>
      'Belum tersedia di SiCuaca karena data radar BMKG belum terbuka untuk aplikasi; lihat di halaman resmi.';

  @override
  String get layananPenerbanganJudul => 'Cuaca penerbangan';

  @override
  String get layananPenerbanganKet =>
      'Laporan METAR dan prakiraan TAF bandara.';

  @override
  String get layananTitikPanasJudul => 'Titik panas';

  @override
  String get layananTitikPanasKet => 'Citra sebaran titik panas dari satelit.';

  @override
  String get layananIklimJudul => 'Informasi iklim';

  @override
  String get layananIklimKet =>
      'Analisis dan prediksi hujan, musim, serta El Niño/La Niña.';

  @override
  String get layananSiaranPersJudul => 'Siaran pers';

  @override
  String get layananSiaranPersKet => 'Siaran pers resmi BMKG.';

  @override
  String maritimPerairanTerdekat(String jarak) {
    return 'Perairan terdekat dari lokasi Anda, ±$jarak km';
  }

  @override
  String get maritimPerairanPilihan => 'Perairan pilihan Anda';

  @override
  String get maritimPilihPerairan => 'Pilih perairan';

  @override
  String get maritimPakaiTerdekat => 'Gunakan perairan terdekat';

  @override
  String get maritimCariPerairan => 'Cari perairan atau provinsi';

  @override
  String get maritimPerluPilih =>
      'Izinkan lokasi untuk menemukan perairan terdekat, atau pilih perairan sendiri.';

  @override
  String get maritimMemuat => 'Memuat cuaca maritim…';

  @override
  String get maritimGagal => 'Cuaca maritim belum bisa dimuat.';

  @override
  String get maritimMemuatDaftar => 'Memuat daftar perairan…';

  @override
  String get maritimDaftarGagal => 'Daftar perairan belum bisa dimuat.';

  @override
  String get maritimTidakAdaHasil => 'Tidak ada perairan yang cocok.';

  @override
  String get maritimSaatIni => 'Saat ini';

  @override
  String get maritimGelombang => 'Gelombang';

  @override
  String maritimMeter(String nilai) {
    return '$nilai m';
  }

  @override
  String get maritimAngin => 'Angin';

  @override
  String maritimAnginNilai(String arah, String kecepatan, String hembusan) {
    return 'Dari $arah, $kecepatan knot (hembusan $hembusan)';
  }

  @override
  String get maritimArus => 'Arus';

  @override
  String maritimArusNilai(String arah, String kecepatan) {
    return 'Ke $arah, $kecepatan knot';
  }

  @override
  String get maritimCuaca => 'Cuaca';

  @override
  String maritimBerlaku(String jam) {
    return 'Berlaku pukul $jam';
  }

  @override
  String maritimDiterbitkan(String waktu) {
    return 'Diterbitkan BMKG $waktu';
  }

  @override
  String get maritimPrakiraanJam => '24 jam ke depan';

  @override
  String get maritimPrakiraanHari => 'Hari berikutnya (per 3 jam)';

  @override
  String maritimKategoriSemantik(String kategori, String tinggi) {
    return 'Gelombang $kategori, $tinggi meter';
  }

  @override
  String get maritimCatatanKategori =>
      'Kategori gelombang adalah label dari BMKG.';

  @override
  String get gelombangTenang => 'Tenang';

  @override
  String get gelombangRendah => 'Rendah';

  @override
  String get gelombangSedang => 'Sedang';

  @override
  String get gelombangTinggi => 'Tinggi';

  @override
  String get gelombangSangatTinggi => 'Sangat tinggi';

  @override
  String get gelombangEkstrem => 'Ekstrem';

  @override
  String get gelombangSangatEkstrem => 'Sangat ekstrem';

  @override
  String get menuTautanCatatan => '↗ membuka halaman resmi BMKG.';

  @override
  String get perJamJudul => 'Per jam';

  @override
  String get sekarang => 'Sekarang';

  @override
  String get jarakPandang => 'Jarak pandang';

  @override
  String get titikEmbun => 'Titik embun';

  @override
  String get langitJudul => 'Matahari dan bulan';

  @override
  String get matahari => 'Matahari';

  @override
  String get bulan => 'Bulan';

  @override
  String get terbit => 'Terbit';

  @override
  String get terbenam => 'Terbenam';

  @override
  String get tidakAdaHariIni => 'Tidak ada';

  @override
  String get diBawahHorizon => 'Di bawah cakrawala';

  @override
  String get uvJudul => 'Indeks UV';

  @override
  String get udaraUvJudul => 'Kualitas udara dan UV';

  @override
  String get udaraUvTautanKet => 'Perkiraan UV dan US AQI untuk wilayah ini';

  @override
  String get udaraUvTanpaKoordinat =>
      'Koordinat wilayah ini tidak tersedia, jadi UV dan kualitas udara tidak bisa dihitung.';

  @override
  String get udaraPrivasi =>
      'Hanya koordinat titik pusat wilayah ini, dibulatkan ke 0,1 derajat, yang dikirim ke Open-Meteo untuk kualitas udara. Tidak ada identitas atau lokasi tepat perangkat.';

  @override
  String get uvRendah => 'Rendah';

  @override
  String get uvSedang => 'Sedang';

  @override
  String get uvTinggi => 'Tinggi';

  @override
  String get uvSangatTinggi => 'Sangat tinggi';

  @override
  String get uvEkstrem => 'Ekstrem';

  @override
  String get uvSaranRendah => 'Aman beraktivitas di luar ruangan.';

  @override
  String get uvSaranSedang => 'Pakai tabir surya bila lama di luar ruangan.';

  @override
  String get uvSaranTinggi => 'Pakai tabir surya, topi, dan kacamata hitam.';

  @override
  String get uvSaranSangatTinggi =>
      'Kurangi paparan matahari pukul 10.00 sampai 16.00. Pakai tabir surya, topi, dan kacamata.';

  @override
  String get uvSaranEkstrem =>
      'Hindari matahari langsung pukul 10.00 sampai 16.00. Lindungi kulit dan mata.';

  @override
  String uvPerkiraan(int nilai) {
    return 'Perkiraan $nilai';
  }

  @override
  String get uvMalam => 'Tidak ada sinar UV saat malam.';

  @override
  String uvPuncak(String kategori, String jam) {
    return 'Puncak hari ini: $kategori, sekitar pukul $jam';
  }

  @override
  String get uvCatatan =>
      'Perkiraan dihitung SiCuaca dari posisi matahari dan tutupan awan BMKG; kabut asap tidak diperhitungkan.';

  @override
  String get udaraJudul => 'Kualitas udara';

  @override
  String aqiNilai(int nilai) {
    return 'US AQI $nilai';
  }

  @override
  String get aqiBaik => 'Baik';

  @override
  String get aqiSedang => 'Sedang';

  @override
  String get aqiSensitif => 'Tidak sehat bagi kelompok sensitif';

  @override
  String get aqiTidakSehat => 'Tidak sehat';

  @override
  String get aqiSangatTidakSehat => 'Sangat tidak sehat';

  @override
  String get aqiBerbahaya => 'Berbahaya';

  @override
  String get aqiSaranBaik => 'Udara baik untuk beraktivitas di luar ruangan.';

  @override
  String get aqiSaranSedang =>
      'Cukup baik. Orang yang sangat sensitif perhatikan gejala.';

  @override
  String get aqiSaranSensitif =>
      'Anak, lansia, dan penderita asma kurangi aktivitas berat di luar ruangan.';

  @override
  String get aqiSaranTidakSehat =>
      'Kurangi aktivitas berat di luar ruangan; pertimbangkan memakai masker.';

  @override
  String get aqiSaranSangatTidakSehat =>
      'Hindari aktivitas di luar ruangan; pakai masker bila harus keluar.';

  @override
  String get aqiSaranBerbahaya =>
      'Tetap di dalam ruangan; pakai masker N95 bila harus keluar.';

  @override
  String udaraPm25(String nilai) {
    return 'PM2,5 $nilai µg/m³';
  }

  @override
  String udaraWaktuModel(String jam) {
    return 'Data model pukul $jam';
  }

  @override
  String get udaraDataTersimpan => 'Data tersimpan, belum diperbarui.';

  @override
  String get udaraMemuat => 'Memuat kualitas udara...';

  @override
  String get udaraGagal => 'Kualitas udara tidak tersedia saat ini.';

  @override
  String get udaraSumber =>
      'Sumber: Open-Meteo (CC BY 4.0), data CAMS/Copernicus. Perkiraan model beresolusi sekitar 45 km, bukan sensor; kategori dan saran disusun SiCuaca.';

  @override
  String get lamaSiang => 'Lama siang';

  @override
  String lamaSiangNilai(int jam, int menit) {
    return '$jam j $menit m';
  }

  @override
  String terangBulan(int persen) {
    return '$persen% terang';
  }

  @override
  String get faseBaru => 'Bulan baru';

  @override
  String get faseSabitAwal => 'Sabit awal';

  @override
  String get fasePerempatPertama => 'Perempat pertama';

  @override
  String get faseCembungAwal => 'Cembung awal';

  @override
  String get fasePurnama => 'Purnama';

  @override
  String get faseCembungAkhir => 'Cembung akhir';

  @override
  String get fasePerempatAkhir => 'Perempat akhir';

  @override
  String get faseSabitAkhir => 'Sabit akhir';

  @override
  String get langitCatatan =>
      'Dihitung aplikasi dari lokasi dan tanggal, bukan data BMKG. Titik embun diturunkan dari suhu dan kelembapan. Foto bulan: NASA/LRO.';

  @override
  String get harianJudul => 'Prakiraan harian';

  @override
  String harianSemantik(
    String hari,
    String kondisi,
    String tertinggi,
    String terendah,
  ) {
    return '$hari, $kondisi, tertinggi $tertinggi, terendah $terendah';
  }
}
