import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'SiCuaca'**
  String get appName;

  /// No description provided for @sumberBmkg.
  ///
  /// In id, this message translates to:
  /// **'Sumber: BMKG'**
  String get sumberBmkg;

  /// No description provided for @cobaLagi.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get cobaLagi;

  /// No description provided for @navBeranda.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navBeranda;

  /// No description provided for @navCuaca.
  ///
  /// In id, this message translates to:
  /// **'Cuaca'**
  String get navCuaca;

  /// No description provided for @navGempa.
  ///
  /// In id, this message translates to:
  /// **'Gempa'**
  String get navGempa;

  /// No description provided for @navPeringatan.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get navPeringatan;

  /// No description provided for @navTentang.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get navTentang;

  /// No description provided for @errTidakAdaInternet.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.'**
  String get errTidakAdaInternet;

  /// No description provided for @errTimeout.
  ///
  /// In id, this message translates to:
  /// **'Server BMKG terlalu lama merespons. Coba lagi beberapa saat lagi.'**
  String get errTimeout;

  /// No description provided for @errStatusHttp.
  ///
  /// In id, this message translates to:
  /// **'Server BMKG mengembalikan status HTTP {kode}.'**
  String errStatusHttp(String kode);

  /// No description provided for @errDataTidakAda.
  ///
  /// In id, this message translates to:
  /// **'Data tidak tersedia untuk lokasi ini.'**
  String get errDataTidakAda;

  /// No description provided for @errFormat.
  ///
  /// In id, this message translates to:
  /// **'Format data dari BMKG tidak dikenali.'**
  String get errFormat;

  /// No description provided for @errTakTerduga.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan tak terduga saat mengambil data.'**
  String get errTakTerduga;

  /// No description provided for @modeOffline.
  ///
  /// In id, this message translates to:
  /// **'Mode offline: menampilkan data tersimpan.'**
  String get modeOffline;

  /// No description provided for @diperbarui.
  ///
  /// In id, this message translates to:
  /// **'Diperbarui: {waktu}'**
  String diperbarui(String waktu);

  /// No description provided for @berandaJudul.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get berandaJudul;

  /// No description provided for @berandaKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Prakiraan cuaca dan info gempa bumi Indonesia.'**
  String get berandaKeterangan;

  /// No description provided for @gempaTabTerbaru.
  ///
  /// In id, this message translates to:
  /// **'Terbaru'**
  String get gempaTabTerbaru;

  /// No description provided for @gempaTabTerkini.
  ///
  /// In id, this message translates to:
  /// **'M 5.0+'**
  String get gempaTabTerkini;

  /// No description provided for @gempaTabDirasakan.
  ///
  /// In id, this message translates to:
  /// **'Dirasakan'**
  String get gempaTabDirasakan;

  /// No description provided for @gempaTerbaruJudul.
  ///
  /// In id, this message translates to:
  /// **'Gempa terbaru'**
  String get gempaTerbaruJudul;

  /// No description provided for @gempaTerbaruKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Gempa terakhir yang dicatat BMKG.'**
  String get gempaTerbaruKeterangan;

  /// No description provided for @gempaTerkiniKeterangan.
  ///
  /// In id, this message translates to:
  /// **'15 gempa terakhir dengan magnitudo 5,0 ke atas.'**
  String get gempaTerkiniKeterangan;

  /// No description provided for @gempaDirasakanKeterangan.
  ///
  /// In id, this message translates to:
  /// **'15 gempa terakhir yang dirasakan masyarakat.'**
  String get gempaDirasakanKeterangan;

  /// No description provided for @memuatGempa.
  ///
  /// In id, this message translates to:
  /// **'Memuat data gempa…'**
  String get memuatGempa;

  /// No description provided for @gempaKosong.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data gempa.'**
  String get gempaKosong;

  /// No description provided for @gempaDetailJudul.
  ///
  /// In id, this message translates to:
  /// **'Detail gempa'**
  String get gempaDetailJudul;

  /// No description provided for @magnitudo.
  ///
  /// In id, this message translates to:
  /// **'Magnitudo'**
  String get magnitudo;

  /// No description provided for @kedalaman.
  ///
  /// In id, this message translates to:
  /// **'Kedalaman'**
  String get kedalaman;

  /// No description provided for @waktuKejadian.
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get waktuKejadian;

  /// No description provided for @koordinat.
  ///
  /// In id, this message translates to:
  /// **'Koordinat'**
  String get koordinat;

  /// No description provided for @pusatGempa.
  ///
  /// In id, this message translates to:
  /// **'Pusat gempa'**
  String get pusatGempa;

  /// No description provided for @potensi.
  ///
  /// In id, this message translates to:
  /// **'Potensi'**
  String get potensi;

  /// No description provided for @dirasakanDi.
  ///
  /// In id, this message translates to:
  /// **'Dirasakan di'**
  String get dirasakanDi;

  /// No description provided for @jarakDariAnda.
  ///
  /// In id, this message translates to:
  /// **'Jarak dari Anda'**
  String get jarakDariAnda;

  /// No description provided for @shakemapJudul.
  ///
  /// In id, this message translates to:
  /// **'Peta guncangan (shakemap)'**
  String get shakemapJudul;

  /// No description provided for @shakemapTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Peta guncangan tidak tersedia untuk gempa ini.'**
  String get shakemapTidakTersedia;

  /// No description provided for @jarakAjak.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan lokasi untuk melihat jarak gempa dari posisi Anda.'**
  String get jarakAjak;

  /// No description provided for @jarakKm.
  ///
  /// In id, this message translates to:
  /// **'± {km} km dari Anda'**
  String jarakKm(String km);

  /// No description provided for @kedalamanSingkat.
  ///
  /// In id, this message translates to:
  /// **'Kedalaman {nilai}'**
  String kedalamanSingkat(String nilai);

  /// No description provided for @baruSaja.
  ///
  /// In id, this message translates to:
  /// **'Baru saja'**
  String get baruSaja;

  /// No description provided for @menitLalu.
  ///
  /// In id, this message translates to:
  /// **'{n} menit lalu'**
  String menitLalu(int n);

  /// No description provided for @jamLalu.
  ///
  /// In id, this message translates to:
  /// **'{n} jam lalu'**
  String jamLalu(int n);

  /// No description provided for @hariLalu.
  ///
  /// In id, this message translates to:
  /// **'{n} hari lalu'**
  String hariLalu(int n);

  /// No description provided for @cuacaSaatIni.
  ///
  /// In id, this message translates to:
  /// **'Cuaca saat ini'**
  String get cuacaSaatIni;

  /// No description provided for @memuatCuaca.
  ///
  /// In id, this message translates to:
  /// **'Memuat prakiraan cuaca…'**
  String get memuatCuaca;

  /// No description provided for @kelembapan.
  ///
  /// In id, this message translates to:
  /// **'Kelembapan'**
  String get kelembapan;

  /// No description provided for @angin.
  ///
  /// In id, this message translates to:
  /// **'Angin'**
  String get angin;

  /// No description provided for @waktuSetempat.
  ///
  /// In id, this message translates to:
  /// **'Waktu setempat'**
  String get waktuSetempat;

  /// No description provided for @tidakAdaPrakiraan.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data prakiraan.'**
  String get tidakAdaPrakiraan;

  /// No description provided for @pukul.
  ///
  /// In id, this message translates to:
  /// **'Pukul {waktu}'**
  String pukul(String waktu);

  /// No description provided for @kecepatanAngin.
  ///
  /// In id, this message translates to:
  /// **'{kecepatan} km/j dari {arah}'**
  String kecepatanAngin(String kecepatan, String arah);

  /// No description provided for @kecepatanAnginSaja.
  ///
  /// In id, this message translates to:
  /// **'{kecepatan} km/j'**
  String kecepatanAnginSaja(String kecepatan);

  /// No description provided for @hariIni.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get hariIni;

  /// No description provided for @besok.
  ///
  /// In id, this message translates to:
  /// **'Besok'**
  String get besok;

  /// No description provided for @arahN.
  ///
  /// In id, this message translates to:
  /// **'Utara'**
  String get arahN;

  /// No description provided for @arahNE.
  ///
  /// In id, this message translates to:
  /// **'Timur Laut'**
  String get arahNE;

  /// No description provided for @arahE.
  ///
  /// In id, this message translates to:
  /// **'Timur'**
  String get arahE;

  /// No description provided for @arahSE.
  ///
  /// In id, this message translates to:
  /// **'Tenggara'**
  String get arahSE;

  /// No description provided for @arahS.
  ///
  /// In id, this message translates to:
  /// **'Selatan'**
  String get arahS;

  /// No description provided for @arahSW.
  ///
  /// In id, this message translates to:
  /// **'Barat Daya'**
  String get arahSW;

  /// No description provided for @arahW.
  ///
  /// In id, this message translates to:
  /// **'Barat'**
  String get arahW;

  /// No description provided for @arahNW.
  ///
  /// In id, this message translates to:
  /// **'Barat Laut'**
  String get arahNW;

  /// No description provided for @pilihWilayahJudul.
  ///
  /// In id, this message translates to:
  /// **'Pilih wilayah'**
  String get pilihWilayahJudul;

  /// No description provided for @pilihWilayahKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Izinkan akses lokasi atau cari desa/kelurahan untuk melihat prakiraan cuaca.'**
  String get pilihWilayahKeterangan;

  /// No description provided for @gunakanLokasiSaya.
  ///
  /// In id, this message translates to:
  /// **'Gunakan lokasi saya'**
  String get gunakanLokasiSaya;

  /// No description provided for @cariWilayah.
  ///
  /// In id, this message translates to:
  /// **'Cari wilayah'**
  String get cariWilayah;

  /// No description provided for @gantiWilayah.
  ///
  /// In id, this message translates to:
  /// **'Ganti wilayah'**
  String get gantiWilayah;

  /// No description provided for @mencariLokasi.
  ///
  /// In id, this message translates to:
  /// **'Mencari lokasi Anda…'**
  String get mencariLokasi;

  /// No description provided for @cariHint.
  ///
  /// In id, this message translates to:
  /// **'Cari desa, kelurahan, atau kecamatan'**
  String get cariHint;

  /// No description provided for @cariMinimal.
  ///
  /// In id, this message translates to:
  /// **'Ketik minimal 3 huruf.'**
  String get cariMinimal;

  /// No description provided for @cariTidakAdaHasil.
  ///
  /// In id, this message translates to:
  /// **'Wilayah tidak ditemukan.'**
  String get cariTidakAdaHasil;

  /// No description provided for @memuatDataWilayah.
  ///
  /// In id, this message translates to:
  /// **'Memuat data wilayah…'**
  String get memuatDataWilayah;

  /// No description provided for @gagalMemuatDataWilayah.
  ///
  /// In id, this message translates to:
  /// **'Data wilayah tidak bisa dimuat. Pasang ulang aplikasi bila masalah berlanjut.'**
  String get gagalMemuatDataWilayah;

  /// No description provided for @favorit.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get favorit;

  /// No description provided for @belumAdaFavorit.
  ///
  /// In id, this message translates to:
  /// **'Belum ada wilayah favorit. Ketuk ikon bintang untuk menyimpan.'**
  String get belumAdaFavorit;

  /// No description provided for @tambahFavorit.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke favorit'**
  String get tambahFavorit;

  /// No description provided for @hapusFavorit.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari favorit'**
  String get hapusFavorit;

  /// No description provided for @gpsLayananMati.
  ///
  /// In id, this message translates to:
  /// **'Layanan lokasi (GPS) sedang mati. Nyalakan lalu coba lagi, atau cari wilayah secara manual.'**
  String get gpsLayananMati;

  /// No description provided for @gpsDitolak.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak. Anda tetap bisa mencari wilayah secara manual.'**
  String get gpsDitolak;

  /// No description provided for @gpsDitolakPermanen.
  ///
  /// In id, this message translates to:
  /// **'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi, atau cari wilayah secara manual.'**
  String get gpsDitolakPermanen;

  /// No description provided for @gpsGagal.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Anda tidak bisa ditentukan. Silakan pilih wilayah secara manual.'**
  String get gpsGagal;

  /// No description provided for @gpsDiluarWilayah.
  ///
  /// In id, this message translates to:
  /// **'Lokasi Anda tidak cocok dengan desa/kelurahan mana pun di Indonesia. Silakan pilih wilayah secara manual.'**
  String get gpsDiluarWilayah;

  /// No description provided for @bukaPengaturanAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan aplikasi'**
  String get bukaPengaturanAplikasi;

  /// No description provided for @bukaPengaturanLokasi.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan lokasi'**
  String get bukaPengaturanLokasi;

  /// No description provided for @channelGempaNama.
  ///
  /// In id, this message translates to:
  /// **'Gempa bumi'**
  String get channelGempaNama;

  /// No description provided for @channelGempaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi gempa baru sesuai ambang magnitudo yang dipilih.'**
  String get channelGempaDeskripsi;

  /// No description provided for @notifJudul.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi gempa'**
  String get notifJudul;

  /// No description provided for @notifKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Kirim notifikasi saat terjadi gempa dengan magnitudo minimal:'**
  String get notifKeterangan;

  /// No description provided for @notifMati.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get notifMati;

  /// No description provided for @notifMatiKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Tidak menerima notifikasi gempa'**
  String get notifMatiKeterangan;

  /// No description provided for @notifM4.
  ///
  /// In id, this message translates to:
  /// **'M 4,0 ke atas'**
  String get notifM4;

  /// No description provided for @notifM5.
  ///
  /// In id, this message translates to:
  /// **'M 5,0 ke atas'**
  String get notifM5;

  /// No description provided for @notifM6.
  ///
  /// In id, this message translates to:
  /// **'M 6,0 ke atas'**
  String get notifM6;

  /// No description provided for @notifM4Keterangan.
  ///
  /// In id, this message translates to:
  /// **'Termasuk gempa kecil yang terasa'**
  String get notifM4Keterangan;

  /// No description provided for @notifM5Keterangan.
  ///
  /// In id, this message translates to:
  /// **'Gempa sedang hingga kuat'**
  String get notifM5Keterangan;

  /// No description provided for @notifM6Keterangan.
  ///
  /// In id, this message translates to:
  /// **'Hanya gempa kuat'**
  String get notifM6Keterangan;

  /// No description provided for @notifBelumAktif.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi belum aktif di perangkat ini: Firebase belum dikonfigurasi atau platform tidak didukung.'**
  String get notifBelumAktif;

  /// No description provided for @notifIzinDitolak.
  ///
  /// In id, this message translates to:
  /// **'Izin notifikasi ditolak. Aktifkan lewat pengaturan aplikasi agar notifikasi gempa bisa muncul.'**
  String get notifIzinDitolak;

  /// No description provided for @notifGagalLangganan.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan notifikasi gagal disimpan. Periksa koneksi internet lalu coba lagi.'**
  String get notifGagalLangganan;

  /// No description provided for @notifSumber.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi dikirim server SiCuaca berdasarkan data gempa terbaru. Sumber: BMKG'**
  String get notifSumber;

  /// No description provided for @notifBahasaCatatan.
  ///
  /// In id, this message translates to:
  /// **'Teks notifikasi dikirim server dalam Bahasa Indonesia.'**
  String get notifBahasaCatatan;

  /// No description provided for @peringatanDiniSegera.
  ///
  /// In id, this message translates to:
  /// **'Peringatan dini cuaca: segera hadir'**
  String get peringatanDiniSegera;

  /// No description provided for @peringatanKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Peringatan dini cuaca ekstrem untuk wilayah Anda.'**
  String get peringatanKeterangan;

  /// No description provided for @tentangKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi prakiraan cuaca dan info gempa bumi Indonesia.'**
  String get tentangKeterangan;

  /// No description provided for @tentangSumber.
  ///
  /// In id, this message translates to:
  /// **'Sumber data: BMKG (Badan Meteorologi, Klimatologi, dan Geofisika). SiCuaca bukan aplikasi resmi BMKG.'**
  String get tentangSumber;

  /// No description provided for @tentangDataWilayah.
  ///
  /// In id, this message translates to:
  /// **'Data kode dan koordinat wilayah: cahyadsn/wilayah dan cahyadsn/wilayah_boundaries (lisensi MIT), mengikuti Kepmendagri No 300.2.2-2430 Tahun 2025.'**
  String get tentangDataWilayah;

  /// No description provided for @tentangPengaturan.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get tentangPengaturan;

  /// No description provided for @tentangKredit.
  ///
  /// In id, this message translates to:
  /// **'Kredit dan sumber data'**
  String get tentangKredit;

  /// No description provided for @tentangBahasa.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get tentangBahasa;

  /// No description provided for @tentangTema.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get tentangTema;

  /// No description provided for @tentangVersi.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi'**
  String get tentangVersi;

  /// No description provided for @versiAplikasi.
  ///
  /// In id, this message translates to:
  /// **'{versi} (build {build})'**
  String versiAplikasi(String versi, String build);

  /// No description provided for @ikutiSistem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti sistem'**
  String get ikutiSistem;

  /// No description provided for @bahasaIndonesia.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesia;

  /// No description provided for @bahasaInggris.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get bahasaInggris;

  /// No description provided for @temaTerang.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get temaTerang;

  /// No description provided for @temaGelap.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get temaGelap;

  /// No description provided for @lisensiSumberTerbuka.
  ///
  /// In id, this message translates to:
  /// **'Lisensi sumber terbuka'**
  String get lisensiSumberTerbuka;

  /// No description provided for @lisensiDataWilayah.
  ///
  /// In id, this message translates to:
  /// **'Data wilayah (cahyadsn)'**
  String get lisensiDataWilayah;

  /// No description provided for @selengkapnya.
  ///
  /// In id, this message translates to:
  /// **'Selengkapnya'**
  String get selengkapnya;

  /// No description provided for @dataTerakhir.
  ///
  /// In id, this message translates to:
  /// **'Data terakhir diperbarui {waktu}'**
  String dataTerakhir(String waktu);

  /// No description provided for @prakiraanPer3Jam.
  ///
  /// In id, this message translates to:
  /// **'Prakiraan per 3 jam'**
  String get prakiraanPer3Jam;

  /// No description provided for @magKecil.
  ///
  /// In id, this message translates to:
  /// **'Kecil'**
  String get magKecil;

  /// No description provided for @magRingan.
  ///
  /// In id, this message translates to:
  /// **'Ringan'**
  String get magRingan;

  /// No description provided for @magSedang.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get magSedang;

  /// No description provided for @magKuat.
  ///
  /// In id, this message translates to:
  /// **'Kuat'**
  String get magKuat;

  /// No description provided for @magBesar.
  ///
  /// In id, this message translates to:
  /// **'Besar'**
  String get magBesar;

  /// No description provided for @magTakDiketahui.
  ///
  /// In id, this message translates to:
  /// **'Tak diketahui'**
  String get magTakDiketahui;

  /// No description provided for @magnitudoSemantik.
  ///
  /// In id, this message translates to:
  /// **'Magnitudo {nilai}, tingkat {tingkat}'**
  String magnitudoSemantik(String nilai, String tingkat);

  /// No description provided for @navPengaturan.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navPengaturan;

  /// No description provided for @pengaturanTampilan.
  ///
  /// In id, this message translates to:
  /// **'Tampilan'**
  String get pengaturanTampilan;

  /// No description provided for @tentangJudul.
  ///
  /// In id, this message translates to:
  /// **'Tentang SiCuaca'**
  String get tentangJudul;

  /// No description provided for @dataTidakTersedia.
  ///
  /// In id, this message translates to:
  /// **'Data tidak tersedia untuk lokasi ini.'**
  String get dataTidakTersedia;

  /// No description provided for @pilihDariDaftar.
  ///
  /// In id, this message translates to:
  /// **'Pilih dari daftar wilayah'**
  String get pilihDariDaftar;

  /// No description provided for @pilihDariDaftarKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Provinsi, kabupaten/kota, kecamatan, lalu desa/kelurahan'**
  String get pilihDariDaftarKeterangan;

  /// No description provided for @pilihProvinsi.
  ///
  /// In id, this message translates to:
  /// **'Pilih provinsi'**
  String get pilihProvinsi;

  /// No description provided for @pilihKabKota.
  ///
  /// In id, this message translates to:
  /// **'Pilih kabupaten/kota'**
  String get pilihKabKota;

  /// No description provided for @pilihKecamatan.
  ///
  /// In id, this message translates to:
  /// **'Pilih kecamatan'**
  String get pilihKecamatan;

  /// No description provided for @pilihDesa.
  ///
  /// In id, this message translates to:
  /// **'Pilih desa/kelurahan'**
  String get pilihDesa;

  /// No description provided for @saringDaftar.
  ///
  /// In id, this message translates to:
  /// **'Saring daftar'**
  String get saringDaftar;

  /// No description provided for @semuaWilayah.
  ///
  /// In id, this message translates to:
  /// **'Indonesia'**
  String get semuaWilayah;

  /// No description provided for @riwayatJudul.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Gempa'**
  String get riwayatJudul;

  /// No description provided for @riwayatKosong.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat gempa. Muat data gempa terlebih dahulu.'**
  String get riwayatKosong;

  /// No description provided for @riwayatJumlah.
  ///
  /// In id, this message translates to:
  /// **'{n} kejadian ditampilkan'**
  String riwayatJumlah(int n);

  /// No description provided for @riwayatTidakCocok.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data yang cocok dengan filter.'**
  String get riwayatTidakCocok;

  /// No description provided for @semuaMagnitudo.
  ///
  /// In id, this message translates to:
  /// **'Semua magnitudo'**
  String get semuaMagnitudo;

  /// No description provided for @dalam100Km.
  ///
  /// In id, this message translates to:
  /// **'Dalam 100 km'**
  String get dalam100Km;

  /// No description provided for @statTerbesar.
  ///
  /// In id, this message translates to:
  /// **'Terbesar'**
  String get statTerbesar;

  /// No description provided for @statTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Terdekat'**
  String get statTerdekat;

  /// No description provided for @statTotal.
  ///
  /// In id, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @siagaJudul.
  ///
  /// In id, this message translates to:
  /// **'Siaga Gempa'**
  String get siagaJudul;

  /// No description provided for @siagaSebelum.
  ///
  /// In id, this message translates to:
  /// **'Sebelum gempa'**
  String get siagaSebelum;

  /// No description provided for @siagaSebelum1.
  ///
  /// In id, this message translates to:
  /// **'Kenali jalur evakuasi dan titik kumpul.'**
  String get siagaSebelum1;

  /// No description provided for @siagaSebelum2.
  ///
  /// In id, this message translates to:
  /// **'Amankan benda berat agar tidak jatuh.'**
  String get siagaSebelum2;

  /// No description provided for @siagaSebelum3.
  ///
  /// In id, this message translates to:
  /// **'Siapkan tas siaga dan simpan nomor darurat.'**
  String get siagaSebelum3;

  /// No description provided for @siagaSaat.
  ///
  /// In id, this message translates to:
  /// **'Saat gempa'**
  String get siagaSaat;

  /// No description provided for @siagaSaat1.
  ///
  /// In id, this message translates to:
  /// **'Merunduk, lindungi kepala, dan bertahan.'**
  String get siagaSaat1;

  /// No description provided for @siagaSaat2.
  ///
  /// In id, this message translates to:
  /// **'Jauhi kaca, lemari, dan benda yang mudah jatuh.'**
  String get siagaSaat2;

  /// No description provided for @siagaSaat3.
  ///
  /// In id, this message translates to:
  /// **'Jangan menggunakan lift.'**
  String get siagaSaat3;

  /// No description provided for @siagaSetelah.
  ///
  /// In id, this message translates to:
  /// **'Setelah gempa'**
  String get siagaSetelah;

  /// No description provided for @siagaSetelah1.
  ///
  /// In id, this message translates to:
  /// **'Keluar dengan tertib setelah guncangan berhenti.'**
  String get siagaSetelah1;

  /// No description provided for @siagaSetelah2.
  ///
  /// In id, this message translates to:
  /// **'Periksa kondisi diri dan orang sekitar.'**
  String get siagaSetelah2;

  /// No description provided for @siagaSetelah3.
  ///
  /// In id, this message translates to:
  /// **'Jika berada di pantai dan guncangan kuat, segera menuju tempat tinggi.'**
  String get siagaSetelah3;

  /// No description provided for @tasSiagaJudul.
  ///
  /// In id, this message translates to:
  /// **'Checklist tas siaga ({selesai}/{total})'**
  String tasSiagaJudul(String selesai, String total);

  /// No description provided for @tas1.
  ///
  /// In id, this message translates to:
  /// **'Air minum'**
  String get tas1;

  /// No description provided for @tas2.
  ///
  /// In id, this message translates to:
  /// **'Makanan tahan lama'**
  String get tas2;

  /// No description provided for @tas3.
  ///
  /// In id, this message translates to:
  /// **'Senter dan baterai'**
  String get tas3;

  /// No description provided for @tas4.
  ///
  /// In id, this message translates to:
  /// **'Kotak P3K dan obat pribadi'**
  String get tas4;

  /// No description provided for @tas5.
  ///
  /// In id, this message translates to:
  /// **'Dokumen penting'**
  String get tas5;

  /// No description provided for @tas6.
  ///
  /// In id, this message translates to:
  /// **'Peluit'**
  String get tas6;

  /// No description provided for @tas7.
  ///
  /// In id, this message translates to:
  /// **'Masker'**
  String get tas7;

  /// No description provided for @tas8.
  ///
  /// In id, this message translates to:
  /// **'Power bank'**
  String get tas8;

  /// No description provided for @siagaCatatan.
  ///
  /// In id, this message translates to:
  /// **'Panduan ini bersifat edukasi. Ikuti arahan resmi pemerintah dan BMKG saat keadaan darurat.'**
  String get siagaCatatan;

  /// No description provided for @salinRingkasan.
  ///
  /// In id, this message translates to:
  /// **'Salin ringkasan'**
  String get salinRingkasan;

  /// No description provided for @ringkasanDisalin.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan disalin ke clipboard.'**
  String get ringkasanDisalin;

  /// No description provided for @ringkasanGempa.
  ///
  /// In id, this message translates to:
  /// **'Gempa M {magnitudo} di {wilayah}, {waktu}. Kedalaman {kedalaman}. Sumber: BMKG.'**
  String ringkasanGempa(
    String magnitudo,
    String wilayah,
    String waktu,
    String kedalaman,
  );

  /// No description provided for @bagikan.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get bagikan;

  /// No description provided for @bagikanCuaca.
  ///
  /// In id, this message translates to:
  /// **'Bagikan info cuaca'**
  String get bagikanCuaca;

  /// No description provided for @bagikanGempa.
  ///
  /// In id, this message translates to:
  /// **'Bagikan info gempa'**
  String get bagikanGempa;

  /// No description provided for @onboardingLewati.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get onboardingLewati;

  /// No description provided for @onboardingLanjut.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get onboardingLanjut;

  /// No description provided for @onboardingMulai.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get onboardingMulai;

  /// No description provided for @onboardingCuacaJudul.
  ///
  /// In id, this message translates to:
  /// **'Prakiraan Cuaca Akurat'**
  String get onboardingCuacaJudul;

  /// No description provided for @onboardingCuacaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Pantau cuaca terkini dan prakiraan per 3 jam di seluruh pelosok desa dan kelurahan Indonesia langsung dari BMKG.'**
  String get onboardingCuacaDeskripsi;

  /// No description provided for @onboardingGempaJudul.
  ///
  /// In id, this message translates to:
  /// **'Info & Notifikasi Gempa'**
  String get onboardingGempaJudul;

  /// No description provided for @onboardingGempaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Ketahui gempa terbaru, magnitudo, jarak dari lokasi Anda, serta terima notifikasi otomatis saat terjadi gempa.'**
  String get onboardingGempaDeskripsi;

  /// No description provided for @onboardingWilayahJudul.
  ///
  /// In id, this message translates to:
  /// **'Pencarian Wilayah Mudah'**
  String get onboardingWilayahJudul;

  /// No description provided for @onboardingWilayahDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Gunakan GPS untuk mendeteksi wilayah Anda secara instan atau cari lebih dari 80.000 desa/kelurahan di Indonesia.'**
  String get onboardingWilayahDeskripsi;

  /// No description provided for @panduanAplikasi.
  ///
  /// In id, this message translates to:
  /// **'Panduan aplikasi'**
  String get panduanAplikasi;

  /// No description provided for @panduanAplikasiKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Lihat kembali slide pengenalan fitur SiCuaca'**
  String get panduanAplikasiKeterangan;

  /// No description provided for @bagikanCuacaJudul.
  ///
  /// In id, this message translates to:
  /// **'🌤️ Cuaca di {lokasi}'**
  String bagikanCuacaJudul(String lokasi);

  /// No description provided for @bagikanGempaJudul.
  ///
  /// In id, this message translates to:
  /// **'⚠️ Info gempa bumi'**
  String get bagikanGempaJudul;

  /// No description provided for @bagikanSumber.
  ///
  /// In id, this message translates to:
  /// **'Sumber: BMKG · via SiCuaca'**
  String get bagikanSumber;

  /// No description provided for @subjudulBeranda.
  ///
  /// In id, this message translates to:
  /// **'Cuaca dan gempa untuk hari ini'**
  String get subjudulBeranda;

  /// No description provided for @subjudulCuaca.
  ///
  /// In id, this message translates to:
  /// **'Prakiraan lokal dari BMKG'**
  String get subjudulCuaca;

  /// No description provided for @subjudulGempa.
  ///
  /// In id, this message translates to:
  /// **'Informasi seismik terkini'**
  String get subjudulGempa;

  /// No description provided for @subjudulPeringatan.
  ///
  /// In id, this message translates to:
  /// **'Atur notifikasi yang kamu perlukan'**
  String get subjudulPeringatan;

  /// No description provided for @subjudulPengaturan.
  ///
  /// In id, this message translates to:
  /// **'Sesuaikan pengalaman SiCuaca'**
  String get subjudulPengaturan;

  /// No description provided for @bandingkanFavorit.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan favorit'**
  String get bandingkanFavorit;

  /// No description provided for @bandingkanJudul.
  ///
  /// In id, this message translates to:
  /// **'Bandingkan cuaca'**
  String get bandingkanJudul;

  /// No description provided for @bandingkanKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Membandingkan {n} dari maksimal 3 wilayah favorit.'**
  String bandingkanKeterangan(String n);

  /// No description provided for @kartuCuaca.
  ///
  /// In id, this message translates to:
  /// **'Kartu Cuaca'**
  String get kartuCuaca;

  /// No description provided for @bukanResmi.
  ///
  /// In id, this message translates to:
  /// **'SiCuaca bukan aplikasi resmi BMKG.'**
  String get bukanResmi;

  /// No description provided for @ringkasanCuaca.
  ///
  /// In id, this message translates to:
  /// **'Cuaca di {lokasi}: {kondisi}, {suhu}. {catatan}Sumber: BMKG. SiCuaca bukan aplikasi resmi BMKG.'**
  String ringkasanCuaca(
    String lokasi,
    String kondisi,
    String suhu,
    String catatan,
  );

  /// No description provided for @bagikanKartuCuaca.
  ///
  /// In id, this message translates to:
  /// **'Bagikan kartu cuaca'**
  String get bagikanKartuCuaca;

  /// No description provided for @salinRingkasanTeks.
  ///
  /// In id, this message translates to:
  /// **'Salin ringkasan teks'**
  String get salinRingkasanTeks;

  /// No description provided for @ringkasanCuacaDisalin.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan cuaca disalin'**
  String get ringkasanCuacaDisalin;

  /// No description provided for @gempaSiagaJudul.
  ///
  /// In id, this message translates to:
  /// **'Tetap siaga, tetap tenang'**
  String get gempaSiagaJudul;

  /// No description provided for @gempaSiagaKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Pantau informasi resmi dan siapkan langkah aman.'**
  String get gempaSiagaKeterangan;

  /// No description provided for @pengaturanIntro.
  ///
  /// In id, this message translates to:
  /// **'Tampilan, bahasa, dan notifikasi tersimpan aman di perangkat ini.'**
  String get pengaturanIntro;

  /// No description provided for @peringatanIntro.
  ///
  /// In id, this message translates to:
  /// **'Pilih ambang magnitudo agar pemberitahuan yang diterima tetap relevan untukmu.'**
  String get peringatanIntro;

  /// No description provided for @jejakAktivitas.
  ///
  /// In id, this message translates to:
  /// **'Jejak aktivitas'**
  String get jejakAktivitas;

  /// No description provided for @cariWilayahGempa.
  ///
  /// In id, this message translates to:
  /// **'Cari wilayah gempa'**
  String get cariWilayahGempa;

  /// No description provided for @hapusPencarian.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get hapusPencarian;

  /// No description provided for @rentangGrafik.
  ///
  /// In id, this message translates to:
  /// **'Rentang grafik'**
  String get rentangGrafik;

  /// No description provided for @grafikPerHari.
  ///
  /// In id, this message translates to:
  /// **'Grafik per hari'**
  String get grafikPerHari;

  /// No description provided for @grafikPerMinggu.
  ///
  /// In id, this message translates to:
  /// **'Grafik per minggu'**
  String get grafikPerMinggu;

  /// No description provided for @saringMagnitudo.
  ///
  /// In id, this message translates to:
  /// **'Filter magnitudo'**
  String get saringMagnitudo;

  /// No description provided for @minimalMagnitudo.
  ///
  /// In id, this message translates to:
  /// **'Minimal M{nilai}'**
  String minimalMagnitudo(String nilai);

  /// No description provided for @gempaDalam100Km.
  ///
  /// In id, this message translates to:
  /// **'Gempa dalam 100 km'**
  String get gempaDalam100Km;

  /// No description provided for @gempaPerHari.
  ///
  /// In id, this message translates to:
  /// **'Gempa per hari'**
  String get gempaPerHari;

  /// No description provided for @gempaPerMinggu.
  ///
  /// In id, this message translates to:
  /// **'Gempa per minggu'**
  String get gempaPerMinggu;

  /// No description provided for @grafikCatatan.
  ///
  /// In id, this message translates to:
  /// **'Berdasarkan riwayat yang tersimpan di perangkat. Ini bukan jumlah seluruh kejadian BMKG.'**
  String get grafikCatatan;

  /// No description provided for @mingguKe.
  ///
  /// In id, this message translates to:
  /// **'Minggu {n}'**
  String mingguKe(String n);

  /// No description provided for @jumlahKejadian.
  ///
  /// In id, this message translates to:
  /// **'{n} kejadian'**
  String jumlahKejadian(int n);

  /// No description provided for @totalGrafik.
  ///
  /// In id, this message translates to:
  /// **'Total pada grafik: {n} kejadian'**
  String totalGrafik(int n);

  /// No description provided for @siagaHeroJudul.
  ///
  /// In id, this message translates to:
  /// **'Kesiapsiagaan dimulai sebelum terjadi gempa.'**
  String get siagaHeroJudul;

  /// No description provided for @siagaHeroKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Pelajari langkah aman dan lengkapi tas siaga secara bertahap.'**
  String get siagaHeroKeterangan;

  /// No description provided for @grafikSuhuJudul.
  ///
  /// In id, this message translates to:
  /// **'24 jam ke depan'**
  String get grafikSuhuJudul;

  /// No description provided for @grafikSuhuSemantik.
  ///
  /// In id, this message translates to:
  /// **'Suhu 24 jam ke depan: sekarang {sekarang} derajat, tertinggi {tertinggi}, terendah {terendah}'**
  String grafikSuhuSemantik(String sekarang, String tertinggi, String terendah);

  /// No description provided for @sapaPagi.
  ///
  /// In id, this message translates to:
  /// **'Selamat pagi, {lokasi}'**
  String sapaPagi(String lokasi);

  /// No description provided for @sapaSiang.
  ///
  /// In id, this message translates to:
  /// **'Selamat siang, {lokasi}'**
  String sapaSiang(String lokasi);

  /// No description provided for @sapaSore.
  ///
  /// In id, this message translates to:
  /// **'Selamat sore, {lokasi}'**
  String sapaSore(String lokasi);

  /// No description provided for @sapaMalam.
  ///
  /// In id, this message translates to:
  /// **'Selamat malam, {lokasi}'**
  String sapaMalam(String lokasi);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
