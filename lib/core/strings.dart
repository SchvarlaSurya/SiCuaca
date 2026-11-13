/// Semua teks yang tampil ke pengguna. Dikumpulkan di satu tempat supaya
/// mudah diterjemahkan saat dukungan dua bahasa ditambahkan.
class Str {
  const Str._();

  // Umum
  static const String appName = 'SiCuaca';
  static const String sumberBmkg = 'Sumber: BMKG';
  static const String cobaLagi = 'Coba lagi';
  static const String segeraHadir = 'Segera hadir';

  // Navigasi
  static const String navBeranda = 'Beranda';
  static const String navCuaca = 'Cuaca';
  static const String navGempa = 'Gempa';
  static const String navPeringatan = 'Peringatan';
  static const String navTentang = 'Tentang';

  // Error API
  static const String errTidakAdaInternet =
      'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.';
  static const String errTimeout =
      'Server BMKG terlalu lama merespons. Coba lagi beberapa saat lagi.';
  static String errStatusHttp(int? kode) =>
      'Server BMKG mengembalikan status HTTP ${kode ?? '-'}.';
  static const String errDataTidakAda =
      'Data cuaca untuk wilayah ini belum tersedia di BMKG.';
  static const String errFormat = 'Format data dari BMKG tidak dikenali.';
  static String errFormatDetail(String detail) =>
      'Format data dari BMKG tidak dikenali: $detail';
  static const String errTakTerduga =
      'Terjadi kesalahan tak terduga saat mengambil data.';

  // Beranda
  static const String berandaJudul = 'Beranda';
  static const String berandaKeterangan =
      'Prakiraan cuaca dan info gempa bumi Indonesia.';

  // Uji koneksi
  static const String ujiKoneksiJudul = 'Uji Koneksi API';
  static const String ujiUlang = 'Uji ulang';
  static const String menghubungiBmkg = 'Menghubungi server BMKG…';
  static const String terhubungGempaTerbaru = 'Terhubung. Gempa terbaru:';
  static const String magnitudo = 'Magnitudo';

  // Cuaca
  static const String cuacaSaatIni = 'Cuaca saat ini';
  static const String memuatCuaca = 'Memuat prakiraan cuaca…';
  static const String kelembapan = 'Kelembapan';
  static const String angin = 'Angin';
  static const String waktuSetempat = 'Waktu setempat';
  static const String tidakAdaPrakiraan = 'Belum ada data prakiraan.';
  static String pukul(String jam, String zona) =>
      zona.isEmpty ? 'Pukul $jam' : 'Pukul $jam $zona';
  static String kecepatanAngin(String kecepatan, String arah) =>
      arah.isEmpty ? '$kecepatan km/j' : '$kecepatan km/j dari $arah';
  static const String hariIni = 'Hari ini';
  static const String besok = 'Besok';
  static const List<String> namaHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const List<String> namaBulanPendek = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  // Pilih wilayah
  static const String pilihWilayahJudul = 'Pilih wilayah';
  static const String pilihWilayahKeterangan =
      'Izinkan akses lokasi atau cari desa/kelurahan untuk melihat prakiraan '
      'cuaca.';
  static const String gunakanLokasiSaya = 'Gunakan lokasi saya';
  static const String cariWilayah = 'Cari wilayah';
  static const String gantiWilayah = 'Ganti wilayah';
  static const String mencariLokasi = 'Mencari lokasi Anda…';

  // Pencarian
  static const String cariHint = 'Cari desa, kelurahan, atau kecamatan';
  static const String cariMinimal = 'Ketik minimal 3 huruf.';
  static const String cariTidakAdaHasil = 'Wilayah tidak ditemukan.';
  static const String memuatDataWilayah = 'Memuat data wilayah…';
  static const String gagalMemuatDataWilayah =
      'Data wilayah tidak bisa dimuat. Pasang ulang aplikasi bila masalah '
      'berlanjut.';
  static const String favorit = 'Favorit';
  static const String belumAdaFavorit =
      'Belum ada wilayah favorit. Ketuk ikon bintang untuk menyimpan.';
  static const String tambahFavorit = 'Tambah ke favorit';
  static const String hapusFavorit = 'Hapus dari favorit';

  // Lokasi / GPS
  static const String gpsLayananMati =
      'Layanan lokasi (GPS) sedang mati. Nyalakan lalu coba lagi, atau cari '
      'wilayah secara manual.';
  static const String gpsDitolak =
      'Izin lokasi ditolak. Anda tetap bisa mencari wilayah secara manual.';
  static const String gpsDitolakPermanen =
      'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi, atau '
      'cari wilayah secara manual.';
  static const String gpsGagal =
      'Lokasi Anda tidak bisa ditentukan. Silakan pilih wilayah secara manual.';
  static const String gpsDiluarWilayah =
      'Lokasi Anda tidak cocok dengan desa/kelurahan mana pun di Indonesia. '
      'Silakan pilih wilayah secara manual.';
  static const String bukaPengaturanAplikasi = 'Buka pengaturan aplikasi';
  static const String bukaPengaturanLokasi = 'Buka pengaturan lokasi';

  // Placeholder tab
  static const String gempaJudul = 'Info Gempa Bumi';
  static const String gempaKeterangan =
      'Gempa terbaru, gempa dirasakan, dan peta guncangan.';
  static const String peringatanJudul = 'Peringatan Dini';
  static const String peringatanKeterangan =
      'Peringatan dini cuaca ekstrem untuk wilayah Anda.';

  // Notifikasi gempa (tab Peringatan)
  static const String channelGempaNama = 'Gempa bumi';
  static const String channelGempaDeskripsi =
      'Notifikasi gempa baru sesuai ambang magnitudo yang dipilih.';
  static const String notifJudul = 'Notifikasi gempa';
  static const String notifKeterangan =
      'Kirim notifikasi saat terjadi gempa dengan magnitudo minimal:';
  static const String notifMati = 'Mati';
  static const String notifMatiKeterangan = 'Tidak menerima notifikasi gempa';
  static const String notifM4 = 'M 4,0 ke atas';
  static const String notifM5 = 'M 5,0 ke atas';
  static const String notifM6 = 'M 6,0 ke atas';
  static const String notifM4Keterangan = 'Termasuk gempa kecil yang terasa';
  static const String notifM5Keterangan = 'Gempa sedang hingga kuat';
  static const String notifM6Keterangan = 'Hanya gempa kuat';
  static const String notifBelumAktif =
      'Notifikasi belum aktif di perangkat ini: Firebase belum dikonfigurasi '
      'atau platform tidak didukung.';
  static const String notifIzinDitolak =
      'Izin notifikasi ditolak. Aktifkan lewat pengaturan aplikasi agar '
      'notifikasi gempa bisa muncul.';
  static const String notifGagalLangganan =
      'Pengaturan notifikasi gagal disimpan. Periksa koneksi internet lalu '
      'coba lagi.';
  static const String notifSumber =
      'Notifikasi dikirim server SiCuaca berdasarkan data gempa terbaru. '
      'Sumber: BMKG';
  static const String peringatanDiniSegera =
      'Peringatan dini cuaca: segera hadir';

  // Tentang
  static const String tentangKeterangan =
      'Aplikasi prakiraan cuaca dan info gempa bumi Indonesia.';
  static const String tentangSumber =
      'Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika). '
      'SiCuaca bukan aplikasi resmi BMKG.';
  static const String lisensiSumberTerbuka = 'Lisensi sumber terbuka';
  static const String lisensiDataWilayah = 'Data wilayah (cahyadsn)';

  // Satuan dan arah angin
  static const String satuanSuhu = '°C';
  static const String tandaKosong = '-';
  static const Map<String, String> arahAngin = {
    'N': 'Utara',
    'NE': 'Timur Laut',
    'E': 'Timur',
    'SE': 'Tenggara',
    'S': 'Selatan',
    'SW': 'Barat Daya',
    'W': 'Barat',
    'NW': 'Barat Laut',
  };
  static const Map<int, String> zonaWaktu = {7: 'WIB', 8: 'WITA', 9: 'WIT'};

  static const String tentangDataWilayah =
      'Data kode dan koordinat wilayah: cahyadsn/wilayah dan '
      'cahyadsn/wilayah_boundaries (lisensi MIT), mengikuti Kepmendagri No '
      '300.2.2-2430 Tahun 2025.';
}
