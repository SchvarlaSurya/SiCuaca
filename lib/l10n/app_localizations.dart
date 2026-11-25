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

  /// No description provided for @pengaturanPreferensi.
  ///
  /// In id, this message translates to:
  /// **'Preferensi aplikasi'**
  String get pengaturanPreferensi;

  /// No description provided for @pengaturanPeringatan.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get pengaturanPeringatan;

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

  /// No description provided for @siagaSaat.
  ///
  /// In id, this message translates to:
  /// **'Saat gempa'**
  String get siagaSaat;

  /// No description provided for @siagaSetelah.
  ///
  /// In id, this message translates to:
  /// **'Setelah gempa'**
  String get siagaSetelah;

  /// No description provided for @tasSiagaJudul.
  ///
  /// In id, this message translates to:
  /// **'Checklist tas siaga ({selesai}/{total})'**
  String tasSiagaJudul(String selesai, String total);

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

  /// No description provided for @riwayatNotifJudul.
  ///
  /// In id, this message translates to:
  /// **'Riwayat notifikasi'**
  String get riwayatNotifJudul;

  /// No description provided for @riwayatNotifKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Gempa yang pernah dikirimi notifikasi ke perangkat ini.'**
  String get riwayatNotifKeterangan;

  /// No description provided for @riwayatNotifKosong.
  ///
  /// In id, this message translates to:
  /// **'Belum ada notifikasi gempa yang diterima. Pilih ambang magnitudo di Peringatan agar notifikasi masuk.'**
  String get riwayatNotifKosong;

  /// No description provided for @diterimaWaktu.
  ///
  /// In id, this message translates to:
  /// **'Diterima {waktu}'**
  String diterimaWaktu(String waktu);

  /// No description provided for @hapusRiwayat.
  ///
  /// In id, this message translates to:
  /// **'Hapus riwayat'**
  String get hapusRiwayat;

  /// No description provided for @hapusRiwayatKonfirmasi.
  ///
  /// In id, this message translates to:
  /// **'Hapus seluruh riwayat notifikasi di perangkat ini? Tindakan ini tidak bisa dibatalkan.'**
  String get hapusRiwayatKonfirmasi;

  /// No description provided for @aksiBatal.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get aksiBatal;

  /// No description provided for @aksiHapus.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get aksiHapus;

  /// No description provided for @urutanBerandaJudul.
  ///
  /// In id, this message translates to:
  /// **'Urutan Beranda'**
  String get urutanBerandaJudul;

  /// No description provided for @urutanBerandaKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Seret atau pakai tombol panah untuk mengubah urutan bagian di Beranda.'**
  String get urutanBerandaKeterangan;

  /// No description provided for @urutanBerandaRingkas.
  ///
  /// In id, this message translates to:
  /// **'Atur urutan bagian di Beranda'**
  String get urutanBerandaRingkas;

  /// No description provided for @setelUlangUrutan.
  ///
  /// In id, this message translates to:
  /// **'Setel ulang urutan'**
  String get setelUlangUrutan;

  /// No description provided for @naikkanBagian.
  ///
  /// In id, this message translates to:
  /// **'Naikkan {nama}'**
  String naikkanBagian(String nama);

  /// No description provided for @turunkanBagian.
  ///
  /// In id, this message translates to:
  /// **'Turunkan {nama}'**
  String turunkanBagian(String nama);

  /// No description provided for @riwayatBiasLabel.
  ///
  /// In id, this message translates to:
  /// **'Dari data yang tersimpan di perangkat ini'**
  String get riwayatBiasLabel;

  /// No description provided for @riwayatRentangData.
  ///
  /// In id, this message translates to:
  /// **'Data tersimpan: {mulai} – {akhir}'**
  String riwayatRentangData(String mulai, String akhir);

  /// No description provided for @riwayatBiasCatatan.
  ///
  /// In id, this message translates to:
  /// **'BMKG hanya menyediakan daftar gempa terbaru, jadi riwayat ini hanya berisi gempa yang pernah dimuat atau diterima di perangkat ini. Angkanya bukan statistik lengkap kejadian gempa di Indonesia.'**
  String get riwayatBiasCatatan;

  /// No description provided for @riwayatDariTotal.
  ///
  /// In id, this message translates to:
  /// **'{n} dari {total} data tersimpan'**
  String riwayatDariTotal(String n, String total);

  /// No description provided for @statJumlahGempa.
  ///
  /// In id, this message translates to:
  /// **'Jumlah gempa'**
  String get statJumlahGempa;

  /// No description provided for @statLokasiTidakAda.
  ///
  /// In id, this message translates to:
  /// **'Lokasi tidak tersedia'**
  String get statLokasiTidakAda;

  /// No description provided for @statLabelBias.
  ///
  /// In id, this message translates to:
  /// **'Statistik dari data yang tersimpan di perangkat ini'**
  String get statLabelBias;

  /// No description provided for @riwayatGagalMuat.
  ///
  /// In id, this message translates to:
  /// **'Riwayat gempa tidak bisa dibaca dari penyimpanan perangkat. Coba lagi.'**
  String get riwayatGagalMuat;

  /// No description provided for @riwayatKosongCatatan.
  ///
  /// In id, this message translates to:
  /// **'Riwayat terisi otomatis saat data gempa BMKG dimuat atau notifikasi gempa diterima.'**
  String get riwayatKosongCatatan;

  /// No description provided for @filterJudul.
  ///
  /// In id, this message translates to:
  /// **'Filter riwayat'**
  String get filterJudul;

  /// No description provided for @filterTanggal.
  ///
  /// In id, this message translates to:
  /// **'Rentang tanggal'**
  String get filterTanggal;

  /// No description provided for @filterSemuaTanggal.
  ///
  /// In id, this message translates to:
  /// **'Semua tanggal'**
  String get filterSemuaTanggal;

  /// No description provided for @filterHariTerakhir.
  ///
  /// In id, this message translates to:
  /// **'{n} hari terakhir'**
  String filterHariTerakhir(String n);

  /// No description provided for @filterPilihTanggal.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get filterPilihTanggal;

  /// No description provided for @filterPilihTanggalBantuan.
  ///
  /// In id, this message translates to:
  /// **'Pilih rentang tanggal kejadian'**
  String get filterPilihTanggalBantuan;

  /// No description provided for @filterMagnitudo.
  ///
  /// In id, this message translates to:
  /// **'Magnitudo minimum'**
  String get filterMagnitudo;

  /// No description provided for @filterJarak.
  ///
  /// In id, this message translates to:
  /// **'Jarak maksimum dari Anda'**
  String get filterJarak;

  /// No description provided for @filterSemuaJarak.
  ///
  /// In id, this message translates to:
  /// **'Semua jarak'**
  String get filterSemuaJarak;

  /// No description provided for @filterJarakKm.
  ///
  /// In id, this message translates to:
  /// **'{km} km'**
  String filterJarakKm(String km);

  /// No description provided for @filterJarakNonaktif.
  ///
  /// In id, this message translates to:
  /// **'Filter jarak tidak bisa dipakai karena lokasi Anda belum diketahui. Aktifkan lokasi untuk memakainya.'**
  String get filterJarakNonaktif;

  /// No description provided for @filterTerapkan.
  ///
  /// In id, this message translates to:
  /// **'Terapkan'**
  String get filterTerapkan;

  /// No description provided for @filterSetelUlang.
  ///
  /// In id, this message translates to:
  /// **'Setel ulang'**
  String get filterSetelUlang;

  /// No description provided for @filterAktifJumlah.
  ///
  /// In id, this message translates to:
  /// **'Filter aktif: {n}'**
  String filterAktifJumlah(String n);

  /// No description provided for @pSebelumG1.
  ///
  /// In id, this message translates to:
  /// **'Kunci utama'**
  String get pSebelumG1;

  /// No description provided for @pSebelumG1B1.
  ///
  /// In id, this message translates to:
  /// **'Mengenali apa yang disebut gempabumi;'**
  String get pSebelumG1B1;

  /// No description provided for @pSebelumG1B2.
  ///
  /// In id, this message translates to:
  /// **'Pastikan bahwa struktur dan letak rumah Anda dapat terhindar dari bahaya yang disebabkan oleh gempabumi (longsor, liquefaction, dll.);'**
  String get pSebelumG1B2;

  /// No description provided for @pSebelumG1B3.
  ///
  /// In id, this message translates to:
  /// **'Mengevaluasi dan merenovasi ulang struktur bangunan Anda agar terhindar dari bahaya gempabumi.'**
  String get pSebelumG1B3;

  /// No description provided for @pSebelumG2.
  ///
  /// In id, this message translates to:
  /// **'Kenali lingkungan tempat Anda bekerja'**
  String get pSebelumG2;

  /// No description provided for @pSebelumG2B1.
  ///
  /// In id, this message translates to:
  /// **'Perhatikan letak pintu, lift serta tangga darurat; apabila terjadi gempabumi, sudah mengetahui tempat paling aman untuk berlindung;'**
  String get pSebelumG2B1;

  /// No description provided for @pSebelumG2B2.
  ///
  /// In id, this message translates to:
  /// **'Belajar melakukan P3K;'**
  String get pSebelumG2B2;

  /// No description provided for @pSebelumG2B3.
  ///
  /// In id, this message translates to:
  /// **'Belajar menggunakan alat pemadam kebakaran;'**
  String get pSebelumG2B3;

  /// No description provided for @pSebelumG2B4.
  ///
  /// In id, this message translates to:
  /// **'Catat nomor telepon penting yang dapat dihubungi pada saat terjadi gempabumi.'**
  String get pSebelumG2B4;

  /// No description provided for @pSebelumG3.
  ///
  /// In id, this message translates to:
  /// **'Persiapan rutin pada tempat Anda bekerja dan tinggal'**
  String get pSebelumG3;

  /// No description provided for @pSebelumG3B1.
  ///
  /// In id, this message translates to:
  /// **'Perabotan (lemari, cabinet, dll.) diatur menempel pada dinding (dipaku, diikat, dll.) untuk menghindari jatuh, roboh, bergeser pada saat terjadi gempabumi;'**
  String get pSebelumG3B1;

  /// No description provided for @pSebelumG3B2.
  ///
  /// In id, this message translates to:
  /// **'Simpan bahan yang mudah terbakar pada tempat yang tidak mudah pecah agar terhindar dari kebakaran;'**
  String get pSebelumG3B2;

  /// No description provided for @pSebelumG3B3.
  ///
  /// In id, this message translates to:
  /// **'Selalu mematikan air, gas dan listrik apabila tidak sedang digunakan.'**
  String get pSebelumG3B3;

  /// No description provided for @pSebelumG4.
  ///
  /// In id, this message translates to:
  /// **'Penyebab celaka yang paling banyak pada saat gempabumi adalah akibat kejatuhan material'**
  String get pSebelumG4;

  /// No description provided for @pSebelumG4B1.
  ///
  /// In id, this message translates to:
  /// **'Atur benda yang berat sedapat mungkin berada pada bagian bawah;'**
  String get pSebelumG4B1;

  /// No description provided for @pSebelumG4B2.
  ///
  /// In id, this message translates to:
  /// **'Cek kestabilan benda yang tergantung yang dapat jatuh pada saat gempabumi terjadi (misalnya lampu, dll.).'**
  String get pSebelumG4B2;

  /// No description provided for @pSebelumG5.
  ///
  /// In id, this message translates to:
  /// **'Alat yang harus ada di setiap tempat'**
  String get pSebelumG5;

  /// No description provided for @pSebelumG5B1.
  ///
  /// In id, this message translates to:
  /// **'Kotak P3K;'**
  String get pSebelumG5B1;

  /// No description provided for @pSebelumG5B2.
  ///
  /// In id, this message translates to:
  /// **'Senter/lampu baterai;'**
  String get pSebelumG5B2;

  /// No description provided for @pSebelumG5B3.
  ///
  /// In id, this message translates to:
  /// **'Radio;'**
  String get pSebelumG5B3;

  /// No description provided for @pSebelumG5B4.
  ///
  /// In id, this message translates to:
  /// **'Makanan suplemen dan air.'**
  String get pSebelumG5B4;

  /// No description provided for @pSaatG1.
  ///
  /// In id, this message translates to:
  /// **'Jika Anda berada di dalam bangunan'**
  String get pSaatG1;

  /// No description provided for @pSaatG1B1.
  ///
  /// In id, this message translates to:
  /// **'Lindungi kepala dan badan Anda dari reruntuhan bangunan (dengan bersembunyi di bawah meja, dll.);'**
  String get pSaatG1B1;

  /// No description provided for @pSaatG1B2.
  ///
  /// In id, this message translates to:
  /// **'Mencari tempat yang paling aman dari reruntuhan goncangan;'**
  String get pSaatG1B2;

  /// No description provided for @pSaatG1B3.
  ///
  /// In id, this message translates to:
  /// **'Berlari keluar apabila masih dapat dilakukan.'**
  String get pSaatG1B3;

  /// No description provided for @pSaatG2.
  ///
  /// In id, this message translates to:
  /// **'Jika berada di luar bangunan atau area terbuka'**
  String get pSaatG2;

  /// No description provided for @pSaatG2B1.
  ///
  /// In id, this message translates to:
  /// **'Menghindari bangunan yang ada di sekitar Anda (seperti gedung, tiang listrik, pohon, dll.);'**
  String get pSaatG2B1;

  /// No description provided for @pSaatG2B2.
  ///
  /// In id, this message translates to:
  /// **'Perhatikan tempat Anda berpijak, hindari apabila terjadi rekahan tanah.'**
  String get pSaatG2B2;

  /// No description provided for @pSaatG3.
  ///
  /// In id, this message translates to:
  /// **'Jika Anda sedang mengendarai mobil'**
  String get pSaatG3;

  /// No description provided for @pSaatG3B1.
  ///
  /// In id, this message translates to:
  /// **'Keluar, turun, dan menjauh dari mobil, hindari jika terjadi pergeseran atau kebakaran;'**
  String get pSaatG3B1;

  /// No description provided for @pSaatG3B2.
  ///
  /// In id, this message translates to:
  /// **'Perhatikan tempat Anda berpijak, hindari apabila terjadi rekahan tanah.'**
  String get pSaatG3B2;

  /// No description provided for @pSaatG4.
  ///
  /// In id, this message translates to:
  /// **'Jika Anda tinggal atau berada di pantai'**
  String get pSaatG4;

  /// No description provided for @pSaatG4B1.
  ///
  /// In id, this message translates to:
  /// **'Jauhi pantai untuk menghindari terjadinya tsunami.'**
  String get pSaatG4B1;

  /// No description provided for @pSaatG5.
  ///
  /// In id, this message translates to:
  /// **'Jika Anda tinggal di daerah pegunungan'**
  String get pSaatG5;

  /// No description provided for @pSaatG5B1.
  ///
  /// In id, this message translates to:
  /// **'Apabila terjadi gempa bumi hindari daerah yang mungkin terjadi longsoran.'**
  String get pSaatG5B1;

  /// No description provided for @pSetelahG1.
  ///
  /// In id, this message translates to:
  /// **'Jika Anda berada di dalam bangunan'**
  String get pSetelahG1;

  /// No description provided for @pSetelahG1B1.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari bangunan tersebut dengan tertib;'**
  String get pSetelahG1B1;

  /// No description provided for @pSetelahG1B2.
  ///
  /// In id, this message translates to:
  /// **'Jangan menggunakan tangga berjalan atau lift, gunakan tangga biasa;'**
  String get pSetelahG1B2;

  /// No description provided for @pSetelahG1B3.
  ///
  /// In id, this message translates to:
  /// **'Periksa apakah ada yang terluka, lakukan P3K;'**
  String get pSetelahG1B3;

  /// No description provided for @pSetelahG1B4.
  ///
  /// In id, this message translates to:
  /// **'Telepon/minta pertolongan apabila terjadi luka parah pada Anda atau sekitar Anda.'**
  String get pSetelahG1B4;

  /// No description provided for @pSetelahG2.
  ///
  /// In id, this message translates to:
  /// **'Periksa lingkungan sekitar Anda'**
  String get pSetelahG2;

  /// No description provided for @pSetelahG2B1.
  ///
  /// In id, this message translates to:
  /// **'Periksa apabila terjadi kebakaran;'**
  String get pSetelahG2B1;

  /// No description provided for @pSetelahG2B2.
  ///
  /// In id, this message translates to:
  /// **'Periksa apabila terjadi kebocoran gas;'**
  String get pSetelahG2B2;

  /// No description provided for @pSetelahG2B3.
  ///
  /// In id, this message translates to:
  /// **'Periksa apabila terjadi arus pendek;'**
  String get pSetelahG2B3;

  /// No description provided for @pSetelahG2B4.
  ///
  /// In id, this message translates to:
  /// **'Periksa aliran dan pipa air;'**
  String get pSetelahG2B4;

  /// No description provided for @pSetelahG2B5.
  ///
  /// In id, this message translates to:
  /// **'Periksa segala hal yang dapat membahayakan (mematikan listrik, tidak menyalakan api, dll.).'**
  String get pSetelahG2B5;

  /// No description provided for @pSetelahG3.
  ///
  /// In id, this message translates to:
  /// **'Jangan memasuki bangunan yang sudah terjadi gempa'**
  String get pSetelahG3;

  /// No description provided for @pSetelahG3B1.
  ///
  /// In id, this message translates to:
  /// **'Bangunan yang sudah terjadi gempa menjadi rawan mengalami keruntuhan.'**
  String get pSetelahG3B1;

  /// No description provided for @pSetelahG4.
  ///
  /// In id, this message translates to:
  /// **'Jangan berjalan di sekitar daerah gempa'**
  String get pSetelahG4;

  /// No description provided for @pSetelahG4B1.
  ///
  /// In id, this message translates to:
  /// **'Gempa susulan masih mungkin terjadi di sekitar daerah gempa.'**
  String get pSetelahG4B1;

  /// No description provided for @pSetelahG5.
  ///
  /// In id, this message translates to:
  /// **'Mendengarkan informasi'**
  String get pSetelahG5;

  /// No description provided for @pSetelahG5B1.
  ///
  /// In id, this message translates to:
  /// **'Dengarkan informasi mengenai gempabumi dari radio (apabila terjadi gempa susulan);'**
  String get pSetelahG5B1;

  /// No description provided for @pSetelahG5B2.
  ///
  /// In id, this message translates to:
  /// **'Jangan mudah terpancing oleh isu atau berita yang tidak jelas sumbernya.'**
  String get pSetelahG5B2;

  /// No description provided for @pSetelahG6.
  ///
  /// In id, this message translates to:
  /// **'Mengisi angket yang diberikan oleh instansi terkait'**
  String get pSetelahG6;

  /// No description provided for @pSetelahG6B1.
  ///
  /// In id, this message translates to:
  /// **'Pengisian angket tersebut dilakukan untuk mengetahui seberapa besar kerusakan yang terjadi di lokasi kejadian gempa.'**
  String get pSetelahG6B1;

  /// No description provided for @pSetelahG7.
  ///
  /// In id, this message translates to:
  /// **'Jangan panik dan jangan lupa selalu berdoa kepada Tuhan Yang Maha Esa'**
  String get pSetelahG7;

  /// No description provided for @pSetelahG7B1.
  ///
  /// In id, this message translates to:
  /// **'Berdoa kepada Tuhan Yang Maha Esa demi keamanan dan keselamatan kita semua.'**
  String get pSetelahG7B1;

  /// No description provided for @tasItem1.
  ///
  /// In id, this message translates to:
  /// **'Surat-surat penting (surat tanah, surat kendaraan, ijazah, akta kelahiran, dan lain-lain)'**
  String get tasItem1;

  /// No description provided for @tasItem2.
  ///
  /// In id, this message translates to:
  /// **'Sandang untuk tiga hari: pakaian dalam, celana panjang, jaket, selimut, handuk, jas hujan, dan lain-lain'**
  String get tasItem2;

  /// No description provided for @tasItem3.
  ///
  /// In id, this message translates to:
  /// **'Makanan ringan tahan lama (mi instan, biskuit, abon, cokelat, dan lain-lain)'**
  String get tasItem3;

  /// No description provided for @tasItem4.
  ///
  /// In id, this message translates to:
  /// **'Air minum (cukup untuk kurang lebih tiga hari)'**
  String get tasItem4;

  /// No description provided for @tasItem5.
  ///
  /// In id, this message translates to:
  /// **'Kotak P3K berisi obat-obatan pribadi dan obat-obatan umum lainnya'**
  String get tasItem5;

  /// No description provided for @tasItem6.
  ///
  /// In id, this message translates to:
  /// **'Radio/ponsel beserta baterai, pengisi daya, atau powerbank untuk memantau informasi bencana'**
  String get tasItem6;

  /// No description provided for @tasItem7.
  ///
  /// In id, this message translates to:
  /// **'Perlengkapan mandi (sabun mandi, sikat gigi, odol, sisir, cotton bud, dan lain-lain)'**
  String get tasItem7;

  /// No description provided for @tasItem8.
  ///
  /// In id, this message translates to:
  /// **'Masker (penyaring udara kotor/tercemar)'**
  String get tasItem8;

  /// No description provided for @tasItem9.
  ///
  /// In id, this message translates to:
  /// **'Peluit (alat bantu meminta pertolongan saat darurat)'**
  String get tasItem9;

  /// No description provided for @tasItem10.
  ///
  /// In id, this message translates to:
  /// **'Uang tunai secukupnya untuk perbekalan kurang lebih tiga hari'**
  String get tasItem10;

  /// No description provided for @tasItem11.
  ///
  /// In id, this message translates to:
  /// **'Alat penerangan: senter, lampu kepala (headlamp), korek api, lilin, dan lain-lain'**
  String get tasItem11;

  /// No description provided for @istilah_magnitudo_Nama.
  ///
  /// In id, this message translates to:
  /// **'Magnitudo'**
  String get istilah_magnitudo_Nama;

  /// No description provided for @istilah_magnitudo_Isi.
  ///
  /// In id, this message translates to:
  /// **'Kekuatan gempa dalam skala Richter.'**
  String get istilah_magnitudo_Isi;

  /// No description provided for @istilah_richter_Nama.
  ///
  /// In id, this message translates to:
  /// **'Skala Richter'**
  String get istilah_richter_Nama;

  /// No description provided for @istilah_richter_Isi.
  ///
  /// In id, this message translates to:
  /// **'Ukuran kekuatan gempabumi yang dihitung dari besarnya energi yang dilepaskan dari sumber gempa tersebut.'**
  String get istilah_richter_Isi;

  /// No description provided for @istilah_kedalaman_Nama.
  ///
  /// In id, this message translates to:
  /// **'Kedalaman'**
  String get istilah_kedalaman_Nama;

  /// No description provided for @istilah_kedalaman_Isi.
  ///
  /// In id, this message translates to:
  /// **'Kedalaman gempa dalam kilometer.'**
  String get istilah_kedalaman_Isi;

  /// No description provided for @istilah_mmi_Nama.
  ///
  /// In id, this message translates to:
  /// **'Skala MMI (Modified Mercalli Intensity)'**
  String get istilah_mmi_Nama;

  /// No description provided for @istilah_mmi_Isi.
  ///
  /// In id, this message translates to:
  /// **'Ukuran kekuatan gempa bumi berdasarkan kerusakan yang diakibatkan oleh gempa tersebut.'**
  String get istilah_mmi_Isi;

  /// No description provided for @istilah_waktu_Nama.
  ///
  /// In id, this message translates to:
  /// **'Waktu kejadian'**
  String get istilah_waktu_Nama;

  /// No description provided for @istilah_waktu_Isi.
  ///
  /// In id, this message translates to:
  /// **'Waktu terjadinya gempa dalam WIB.'**
  String get istilah_waktu_Isi;

  /// No description provided for @siagaSumber.
  ///
  /// In id, this message translates to:
  /// **'Sumber: {nama}'**
  String siagaSumber(String nama);

  /// No description provided for @siagaTerjemahan.
  ///
  /// In id, this message translates to:
  /// **'Teks panduan mengikuti sumber resmi di atas. Terjemahan bahasa Inggris dibuat oleh tim SiCuaca, bukan terjemahan resmi.'**
  String get siagaTerjemahan;

  /// No description provided for @siagaIstilahJudul.
  ///
  /// In id, this message translates to:
  /// **'Istilah gempa'**
  String get siagaIstilahJudul;

  /// No description provided for @tasSumberCatatan.
  ///
  /// In id, this message translates to:
  /// **'Daftar tas siaga bencana dari BNPB. Sesuaikan dengan kebutuhan keluarga Anda.'**
  String get tasSumberCatatan;

  /// No description provided for @tasProgres.
  ///
  /// In id, this message translates to:
  /// **'{n} dari {total} siap'**
  String tasProgres(String n, String total);

  /// No description provided for @tasProgresBeranda.
  ///
  /// In id, this message translates to:
  /// **'Tas siaga: {n} dari {total} siap'**
  String tasProgresBeranda(String n, String total);

  /// No description provided for @splashTagline.
  ///
  /// In id, this message translates to:
  /// **'Cuaca dan gempa dari data terbuka BMKG'**
  String get splashTagline;

  /// No description provided for @onboardingSiagaJudul.
  ///
  /// In id, this message translates to:
  /// **'Siap Siaga Gempa'**
  String get onboardingSiagaJudul;

  /// No description provided for @onboardingSiagaDeskripsi.
  ///
  /// In id, this message translates to:
  /// **'Pelajari langkah aman sebelum, saat, dan setelah gempa, lalu lengkapi tas siaga Anda. Isinya bersumber dari BMKG dan BNPB.'**
  String get onboardingSiagaDeskripsi;

  /// No description provided for @onboardingSumber.
  ///
  /// In id, this message translates to:
  /// **'Sumber data: BMKG. SiCuaca bukan aplikasi resmi BMKG.'**
  String get onboardingSumber;

  /// No description provided for @kacaCairJudul.
  ///
  /// In id, this message translates to:
  /// **'Efek kaca cair'**
  String get kacaCairJudul;

  /// No description provided for @kacaCairKeterangan.
  ///
  /// In id, this message translates to:
  /// **'Pembiasan kaca dan animasi tombol jeli. Matikan bila HP terasa berat; navbar dan tombol tetap ada dengan kaca sederhana.'**
  String get kacaCairKeterangan;

  /// No description provided for @lainnya.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get lainnya;

  /// No description provided for @layananJudul.
  ///
  /// In id, this message translates to:
  /// **'Layanan BMKG lainnya'**
  String get layananJudul;

  /// No description provided for @layananRingkas.
  ///
  /// In id, this message translates to:
  /// **'Cuaca maritim, radar, penerbangan, titik panas, iklim, siaran pers'**
  String get layananRingkas;

  /// No description provided for @layananTautanCatatan.
  ///
  /// In id, this message translates to:
  /// **'Layanan bertanda \"Halaman resmi\" dibuka di situs BMKG; isinya tidak disalin ke SiCuaca.'**
  String get layananTautanCatatan;

  /// No description provided for @layananBukaResmi.
  ///
  /// In id, this message translates to:
  /// **'Buka halaman resmi'**
  String get layananBukaResmi;

  /// No description provided for @layananGagalBuka.
  ///
  /// In id, this message translates to:
  /// **'Halaman resmi tidak bisa dibuka.'**
  String get layananGagalBuka;

  /// No description provided for @layananLabelTautan.
  ///
  /// In id, this message translates to:
  /// **'Halaman resmi'**
  String get layananLabelTautan;

  /// No description provided for @layananMaritimJudul.
  ///
  /// In id, this message translates to:
  /// **'Cuaca maritim'**
  String get layananMaritimJudul;

  /// No description provided for @layananMaritimKet.
  ///
  /// In id, this message translates to:
  /// **'Tinggi gelombang, angin, dan arus di perairan terdekat.'**
  String get layananMaritimKet;

  /// No description provided for @layananRadarJudul.
  ///
  /// In id, this message translates to:
  /// **'Radar cuaca'**
  String get layananRadarJudul;

  /// No description provided for @layananRadarKet.
  ///
  /// In id, this message translates to:
  /// **'Belum tersedia di SiCuaca karena data radar BMKG belum terbuka untuk aplikasi; lihat di halaman resmi.'**
  String get layananRadarKet;

  /// No description provided for @layananPenerbanganJudul.
  ///
  /// In id, this message translates to:
  /// **'Cuaca penerbangan'**
  String get layananPenerbanganJudul;

  /// No description provided for @layananPenerbanganKet.
  ///
  /// In id, this message translates to:
  /// **'Laporan METAR dan prakiraan TAF bandara.'**
  String get layananPenerbanganKet;

  /// No description provided for @layananTitikPanasJudul.
  ///
  /// In id, this message translates to:
  /// **'Titik panas'**
  String get layananTitikPanasJudul;

  /// No description provided for @layananTitikPanasKet.
  ///
  /// In id, this message translates to:
  /// **'Citra sebaran titik panas dari satelit.'**
  String get layananTitikPanasKet;

  /// No description provided for @layananIklimJudul.
  ///
  /// In id, this message translates to:
  /// **'Informasi iklim'**
  String get layananIklimJudul;

  /// No description provided for @layananIklimKet.
  ///
  /// In id, this message translates to:
  /// **'Analisis dan prediksi hujan, musim, serta El Niño/La Niña.'**
  String get layananIklimKet;

  /// No description provided for @layananSiaranPersJudul.
  ///
  /// In id, this message translates to:
  /// **'Siaran pers'**
  String get layananSiaranPersJudul;

  /// No description provided for @layananSiaranPersKet.
  ///
  /// In id, this message translates to:
  /// **'Siaran pers resmi BMKG.'**
  String get layananSiaranPersKet;

  /// No description provided for @maritimPerairanTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Perairan terdekat dari lokasi Anda, ±{jarak} km'**
  String maritimPerairanTerdekat(String jarak);

  /// No description provided for @maritimPerairanPilihan.
  ///
  /// In id, this message translates to:
  /// **'Perairan pilihan Anda'**
  String get maritimPerairanPilihan;

  /// No description provided for @maritimPilihPerairan.
  ///
  /// In id, this message translates to:
  /// **'Pilih perairan'**
  String get maritimPilihPerairan;

  /// No description provided for @maritimPakaiTerdekat.
  ///
  /// In id, this message translates to:
  /// **'Gunakan perairan terdekat'**
  String get maritimPakaiTerdekat;

  /// No description provided for @maritimCariPerairan.
  ///
  /// In id, this message translates to:
  /// **'Cari perairan atau provinsi'**
  String get maritimCariPerairan;

  /// No description provided for @maritimPerluPilih.
  ///
  /// In id, this message translates to:
  /// **'Izinkan lokasi untuk menemukan perairan terdekat, atau pilih perairan sendiri.'**
  String get maritimPerluPilih;

  /// No description provided for @maritimMemuat.
  ///
  /// In id, this message translates to:
  /// **'Memuat cuaca maritim…'**
  String get maritimMemuat;

  /// No description provided for @maritimGagal.
  ///
  /// In id, this message translates to:
  /// **'Cuaca maritim belum bisa dimuat.'**
  String get maritimGagal;

  /// No description provided for @maritimMemuatDaftar.
  ///
  /// In id, this message translates to:
  /// **'Memuat daftar perairan…'**
  String get maritimMemuatDaftar;

  /// No description provided for @maritimDaftarGagal.
  ///
  /// In id, this message translates to:
  /// **'Daftar perairan belum bisa dimuat.'**
  String get maritimDaftarGagal;

  /// No description provided for @maritimTidakAdaHasil.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada perairan yang cocok.'**
  String get maritimTidakAdaHasil;

  /// No description provided for @maritimSaatIni.
  ///
  /// In id, this message translates to:
  /// **'Saat ini'**
  String get maritimSaatIni;

  /// No description provided for @maritimGelombang.
  ///
  /// In id, this message translates to:
  /// **'Gelombang'**
  String get maritimGelombang;

  /// No description provided for @maritimMeter.
  ///
  /// In id, this message translates to:
  /// **'{nilai} m'**
  String maritimMeter(String nilai);

  /// No description provided for @maritimAngin.
  ///
  /// In id, this message translates to:
  /// **'Angin'**
  String get maritimAngin;

  /// No description provided for @maritimAnginNilai.
  ///
  /// In id, this message translates to:
  /// **'Dari {arah}, {kecepatan} knot (hembusan {hembusan})'**
  String maritimAnginNilai(String arah, String kecepatan, String hembusan);

  /// No description provided for @maritimArus.
  ///
  /// In id, this message translates to:
  /// **'Arus'**
  String get maritimArus;

  /// No description provided for @maritimArusNilai.
  ///
  /// In id, this message translates to:
  /// **'Ke {arah}, {kecepatan} knot'**
  String maritimArusNilai(String arah, String kecepatan);

  /// No description provided for @maritimCuaca.
  ///
  /// In id, this message translates to:
  /// **'Cuaca'**
  String get maritimCuaca;

  /// No description provided for @maritimBerlaku.
  ///
  /// In id, this message translates to:
  /// **'Berlaku pukul {jam}'**
  String maritimBerlaku(String jam);

  /// No description provided for @maritimDiterbitkan.
  ///
  /// In id, this message translates to:
  /// **'Diterbitkan BMKG {waktu}'**
  String maritimDiterbitkan(String waktu);

  /// No description provided for @maritimPrakiraanJam.
  ///
  /// In id, this message translates to:
  /// **'24 jam ke depan'**
  String get maritimPrakiraanJam;

  /// No description provided for @maritimPrakiraanHari.
  ///
  /// In id, this message translates to:
  /// **'Hari berikutnya (per 3 jam)'**
  String get maritimPrakiraanHari;

  /// No description provided for @maritimKategoriSemantik.
  ///
  /// In id, this message translates to:
  /// **'Gelombang {kategori}, {tinggi} meter'**
  String maritimKategoriSemantik(String kategori, String tinggi);

  /// No description provided for @maritimCatatanKategori.
  ///
  /// In id, this message translates to:
  /// **'Kategori gelombang adalah label dari BMKG.'**
  String get maritimCatatanKategori;

  /// No description provided for @gelombangTenang.
  ///
  /// In id, this message translates to:
  /// **'Tenang'**
  String get gelombangTenang;

  /// No description provided for @gelombangRendah.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get gelombangRendah;

  /// No description provided for @gelombangSedang.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get gelombangSedang;

  /// No description provided for @gelombangTinggi.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get gelombangTinggi;

  /// No description provided for @gelombangSangatTinggi.
  ///
  /// In id, this message translates to:
  /// **'Sangat tinggi'**
  String get gelombangSangatTinggi;

  /// No description provided for @gelombangEkstrem.
  ///
  /// In id, this message translates to:
  /// **'Ekstrem'**
  String get gelombangEkstrem;

  /// No description provided for @gelombangSangatEkstrem.
  ///
  /// In id, this message translates to:
  /// **'Sangat ekstrem'**
  String get gelombangSangatEkstrem;

  /// No description provided for @menuTautanCatatan.
  ///
  /// In id, this message translates to:
  /// **'↗ membuka halaman resmi BMKG.'**
  String get menuTautanCatatan;

  /// No description provided for @perJamJudul.
  ///
  /// In id, this message translates to:
  /// **'Per jam'**
  String get perJamJudul;

  /// No description provided for @sekarang.
  ///
  /// In id, this message translates to:
  /// **'Sekarang'**
  String get sekarang;

  /// No description provided for @jarakPandang.
  ///
  /// In id, this message translates to:
  /// **'Jarak pandang'**
  String get jarakPandang;

  /// No description provided for @titikEmbun.
  ///
  /// In id, this message translates to:
  /// **'Titik embun'**
  String get titikEmbun;

  /// No description provided for @langitJudul.
  ///
  /// In id, this message translates to:
  /// **'Matahari dan bulan'**
  String get langitJudul;

  /// No description provided for @matahari.
  ///
  /// In id, this message translates to:
  /// **'Matahari'**
  String get matahari;

  /// No description provided for @bulan.
  ///
  /// In id, this message translates to:
  /// **'Bulan'**
  String get bulan;

  /// No description provided for @terbit.
  ///
  /// In id, this message translates to:
  /// **'Terbit'**
  String get terbit;

  /// No description provided for @terbenam.
  ///
  /// In id, this message translates to:
  /// **'Terbenam'**
  String get terbenam;

  /// No description provided for @tidakAdaHariIni.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get tidakAdaHariIni;

  /// No description provided for @diBawahHorizon.
  ///
  /// In id, this message translates to:
  /// **'Di bawah cakrawala'**
  String get diBawahHorizon;

  /// No description provided for @uvJudul.
  ///
  /// In id, this message translates to:
  /// **'Indeks UV'**
  String get uvJudul;

  /// No description provided for @udaraUvJudul.
  ///
  /// In id, this message translates to:
  /// **'Kualitas udara dan UV'**
  String get udaraUvJudul;

  /// No description provided for @udaraUvTautanKet.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan UV dan US AQI untuk wilayah ini'**
  String get udaraUvTautanKet;

  /// No description provided for @udaraUvTanpaKoordinat.
  ///
  /// In id, this message translates to:
  /// **'Koordinat wilayah ini tidak tersedia, jadi UV dan kualitas udara tidak bisa dihitung.'**
  String get udaraUvTanpaKoordinat;

  /// No description provided for @udaraPrivasi.
  ///
  /// In id, this message translates to:
  /// **'Hanya koordinat titik pusat wilayah ini, dibulatkan ke 0,1 derajat, yang dikirim ke Open-Meteo untuk kualitas udara. Tidak ada identitas atau lokasi tepat perangkat.'**
  String get udaraPrivasi;

  /// No description provided for @uvRendah.
  ///
  /// In id, this message translates to:
  /// **'Rendah'**
  String get uvRendah;

  /// No description provided for @uvSedang.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get uvSedang;

  /// No description provided for @uvTinggi.
  ///
  /// In id, this message translates to:
  /// **'Tinggi'**
  String get uvTinggi;

  /// No description provided for @uvSangatTinggi.
  ///
  /// In id, this message translates to:
  /// **'Sangat tinggi'**
  String get uvSangatTinggi;

  /// No description provided for @uvEkstrem.
  ///
  /// In id, this message translates to:
  /// **'Ekstrem'**
  String get uvEkstrem;

  /// No description provided for @uvSaranRendah.
  ///
  /// In id, this message translates to:
  /// **'Aman beraktivitas di luar ruangan.'**
  String get uvSaranRendah;

  /// No description provided for @uvSaranSedang.
  ///
  /// In id, this message translates to:
  /// **'Pakai tabir surya bila lama di luar ruangan.'**
  String get uvSaranSedang;

  /// No description provided for @uvSaranTinggi.
  ///
  /// In id, this message translates to:
  /// **'Pakai tabir surya, topi, dan kacamata hitam.'**
  String get uvSaranTinggi;

  /// No description provided for @uvSaranSangatTinggi.
  ///
  /// In id, this message translates to:
  /// **'Kurangi paparan matahari pukul 10.00 sampai 16.00. Pakai tabir surya, topi, dan kacamata.'**
  String get uvSaranSangatTinggi;

  /// No description provided for @uvSaranEkstrem.
  ///
  /// In id, this message translates to:
  /// **'Hindari matahari langsung pukul 10.00 sampai 16.00. Lindungi kulit dan mata.'**
  String get uvSaranEkstrem;

  /// No description provided for @uvPerkiraan.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan {nilai}'**
  String uvPerkiraan(int nilai);

  /// No description provided for @uvMalam.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada sinar UV saat malam.'**
  String get uvMalam;

  /// No description provided for @uvPuncak.
  ///
  /// In id, this message translates to:
  /// **'Puncak hari ini: {kategori}, sekitar pukul {jam}'**
  String uvPuncak(String kategori, String jam);

  /// No description provided for @uvCatatan.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dihitung SiCuaca dari posisi matahari dan tutupan awan BMKG; kabut asap tidak diperhitungkan.'**
  String get uvCatatan;

  /// No description provided for @udaraJudul.
  ///
  /// In id, this message translates to:
  /// **'Kualitas udara'**
  String get udaraJudul;

  /// No description provided for @aqiNilai.
  ///
  /// In id, this message translates to:
  /// **'US AQI {nilai}'**
  String aqiNilai(int nilai);

  /// No description provided for @aqiBaik.
  ///
  /// In id, this message translates to:
  /// **'Baik'**
  String get aqiBaik;

  /// No description provided for @aqiSedang.
  ///
  /// In id, this message translates to:
  /// **'Sedang'**
  String get aqiSedang;

  /// No description provided for @aqiSensitif.
  ///
  /// In id, this message translates to:
  /// **'Tidak sehat bagi kelompok sensitif'**
  String get aqiSensitif;

  /// No description provided for @aqiTidakSehat.
  ///
  /// In id, this message translates to:
  /// **'Tidak sehat'**
  String get aqiTidakSehat;

  /// No description provided for @aqiSangatTidakSehat.
  ///
  /// In id, this message translates to:
  /// **'Sangat tidak sehat'**
  String get aqiSangatTidakSehat;

  /// No description provided for @aqiBerbahaya.
  ///
  /// In id, this message translates to:
  /// **'Berbahaya'**
  String get aqiBerbahaya;

  /// No description provided for @aqiSaranBaik.
  ///
  /// In id, this message translates to:
  /// **'Udara baik untuk beraktivitas di luar ruangan.'**
  String get aqiSaranBaik;

  /// No description provided for @aqiSaranSedang.
  ///
  /// In id, this message translates to:
  /// **'Cukup baik. Orang yang sangat sensitif perhatikan gejala.'**
  String get aqiSaranSedang;

  /// No description provided for @aqiSaranSensitif.
  ///
  /// In id, this message translates to:
  /// **'Anak, lansia, dan penderita asma kurangi aktivitas berat di luar ruangan.'**
  String get aqiSaranSensitif;

  /// No description provided for @aqiSaranTidakSehat.
  ///
  /// In id, this message translates to:
  /// **'Kurangi aktivitas berat di luar ruangan; pertimbangkan memakai masker.'**
  String get aqiSaranTidakSehat;

  /// No description provided for @aqiSaranSangatTidakSehat.
  ///
  /// In id, this message translates to:
  /// **'Hindari aktivitas di luar ruangan; pakai masker bila harus keluar.'**
  String get aqiSaranSangatTidakSehat;

  /// No description provided for @aqiSaranBerbahaya.
  ///
  /// In id, this message translates to:
  /// **'Tetap di dalam ruangan; pakai masker N95 bila harus keluar.'**
  String get aqiSaranBerbahaya;

  /// No description provided for @udaraPm25.
  ///
  /// In id, this message translates to:
  /// **'PM2,5 {nilai} µg/m³'**
  String udaraPm25(String nilai);

  /// No description provided for @udaraWaktuModel.
  ///
  /// In id, this message translates to:
  /// **'Data model pukul {jam}'**
  String udaraWaktuModel(String jam);

  /// No description provided for @udaraDataTersimpan.
  ///
  /// In id, this message translates to:
  /// **'Data tersimpan, belum diperbarui.'**
  String get udaraDataTersimpan;

  /// No description provided for @udaraMemuat.
  ///
  /// In id, this message translates to:
  /// **'Memuat kualitas udara...'**
  String get udaraMemuat;

  /// No description provided for @udaraGagal.
  ///
  /// In id, this message translates to:
  /// **'Kualitas udara tidak tersedia saat ini.'**
  String get udaraGagal;

  /// No description provided for @udaraSumber.
  ///
  /// In id, this message translates to:
  /// **'Sumber: Open-Meteo (CC BY 4.0), data CAMS/Copernicus. Perkiraan model beresolusi sekitar 45 km, bukan sensor; kategori dan saran disusun SiCuaca.'**
  String get udaraSumber;

  /// No description provided for @lamaSiang.
  ///
  /// In id, this message translates to:
  /// **'Lama siang'**
  String get lamaSiang;

  /// No description provided for @lamaSiangNilai.
  ///
  /// In id, this message translates to:
  /// **'{jam} j {menit} m'**
  String lamaSiangNilai(int jam, int menit);

  /// No description provided for @terangBulan.
  ///
  /// In id, this message translates to:
  /// **'{persen}% terang'**
  String terangBulan(int persen);

  /// No description provided for @faseBaru.
  ///
  /// In id, this message translates to:
  /// **'Bulan baru'**
  String get faseBaru;

  /// No description provided for @faseSabitAwal.
  ///
  /// In id, this message translates to:
  /// **'Sabit awal'**
  String get faseSabitAwal;

  /// No description provided for @fasePerempatPertama.
  ///
  /// In id, this message translates to:
  /// **'Perempat pertama'**
  String get fasePerempatPertama;

  /// No description provided for @faseCembungAwal.
  ///
  /// In id, this message translates to:
  /// **'Cembung awal'**
  String get faseCembungAwal;

  /// No description provided for @fasePurnama.
  ///
  /// In id, this message translates to:
  /// **'Purnama'**
  String get fasePurnama;

  /// No description provided for @faseCembungAkhir.
  ///
  /// In id, this message translates to:
  /// **'Cembung akhir'**
  String get faseCembungAkhir;

  /// No description provided for @fasePerempatAkhir.
  ///
  /// In id, this message translates to:
  /// **'Perempat akhir'**
  String get fasePerempatAkhir;

  /// No description provided for @faseSabitAkhir.
  ///
  /// In id, this message translates to:
  /// **'Sabit akhir'**
  String get faseSabitAkhir;

  /// No description provided for @langitCatatan.
  ///
  /// In id, this message translates to:
  /// **'Dihitung aplikasi dari lokasi dan tanggal, bukan data BMKG. Titik embun diturunkan dari suhu dan kelembapan. Foto bulan: NASA/LRO.'**
  String get langitCatatan;

  /// No description provided for @harianJudul.
  ///
  /// In id, this message translates to:
  /// **'Prakiraan harian'**
  String get harianJudul;

  /// No description provided for @harianSemantik.
  ///
  /// In id, this message translates to:
  /// **'{hari}, {kondisi}, tertinggi {tertinggi}, terendah {terendah}'**
  String harianSemantik(
    String hari,
    String kondisi,
    String tertinggi,
    String terendah,
  );
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
