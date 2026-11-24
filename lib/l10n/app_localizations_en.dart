// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SiCuaca';

  @override
  String get sumberBmkg => 'Source: BMKG';

  @override
  String get cobaLagi => 'Try again';

  @override
  String get navBeranda => 'Home';

  @override
  String get navCuaca => 'Weather';

  @override
  String get navGempa => 'Earthquakes';

  @override
  String get navPeringatan => 'Alerts';

  @override
  String get navTentang => 'About';

  @override
  String get errTidakAdaInternet =>
      'No internet connection. Check your network and try again.';

  @override
  String get errTimeout =>
      'The BMKG server took too long to respond. Try again in a moment.';

  @override
  String errStatusHttp(String kode) {
    return 'The BMKG server returned HTTP status $kode.';
  }

  @override
  String get errDataTidakAda => 'Data is not available for this location.';

  @override
  String get errFormat => 'The data format from BMKG was not recognised.';

  @override
  String get errTakTerduga => 'Something went wrong while loading data.';

  @override
  String get modeOffline => 'Offline mode: showing saved data.';

  @override
  String diperbarui(String waktu) {
    return 'Updated: $waktu';
  }

  @override
  String get berandaJudul => 'Home';

  @override
  String get berandaKeterangan =>
      'Weather forecasts and earthquake information for Indonesia.';

  @override
  String get gempaTabTerbaru => 'Latest';

  @override
  String get gempaTabTerkini => 'M 5.0+';

  @override
  String get gempaTabDirasakan => 'Felt';

  @override
  String get gempaTerbaruJudul => 'Latest earthquake';

  @override
  String get gempaTerbaruKeterangan =>
      'The most recent earthquake recorded by BMKG.';

  @override
  String get gempaTerkiniKeterangan =>
      'The last 15 earthquakes of magnitude 5.0 or more.';

  @override
  String get gempaDirasakanKeterangan =>
      'The last 15 earthquakes felt by people.';

  @override
  String get memuatGempa => 'Loading earthquake data…';

  @override
  String get gempaKosong => 'No earthquake data yet.';

  @override
  String get gempaDetailJudul => 'Earthquake details';

  @override
  String get magnitudo => 'Magnitude';

  @override
  String get kedalaman => 'Depth';

  @override
  String get waktuKejadian => 'Time';

  @override
  String get koordinat => 'Coordinates';

  @override
  String get pusatGempa => 'Epicentre';

  @override
  String get potensi => 'Potential';

  @override
  String get dirasakanDi => 'Felt in';

  @override
  String get jarakDariAnda => 'Distance from you';

  @override
  String get shakemapJudul => 'Shake map';

  @override
  String get shakemapTidakTersedia =>
      'No shake map is available for this earthquake.';

  @override
  String get jarakAjak =>
      'Turn on location to see how far each earthquake is from you.';

  @override
  String jarakKm(String km) {
    return '± $km km from you';
  }

  @override
  String kedalamanSingkat(String nilai) {
    return 'Depth $nilai';
  }

  @override
  String get baruSaja => 'Just now';

  @override
  String menitLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String jamLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String hariLalu(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get cuacaSaatIni => 'Current weather';

  @override
  String get memuatCuaca => 'Loading weather forecast…';

  @override
  String get kelembapan => 'Humidity';

  @override
  String get angin => 'Wind';

  @override
  String get waktuSetempat => 'Local time';

  @override
  String get tidakAdaPrakiraan => 'No forecast data yet.';

  @override
  String pukul(String waktu) {
    return 'At $waktu';
  }

  @override
  String kecepatanAngin(String kecepatan, String arah) {
    return '$kecepatan km/h from the $arah';
  }

  @override
  String kecepatanAnginSaja(String kecepatan) {
    return '$kecepatan km/h';
  }

  @override
  String get hariIni => 'Today';

  @override
  String get besok => 'Tomorrow';

  @override
  String get arahN => 'north';

  @override
  String get arahNE => 'northeast';

  @override
  String get arahE => 'east';

  @override
  String get arahSE => 'southeast';

  @override
  String get arahS => 'south';

  @override
  String get arahSW => 'southwest';

  @override
  String get arahW => 'west';

  @override
  String get arahNW => 'northwest';

  @override
  String get pilihWilayahJudul => 'Choose an area';

  @override
  String get pilihWilayahKeterangan =>
      'Allow location access or search for a village to see the weather forecast.';

  @override
  String get gunakanLokasiSaya => 'Use my location';

  @override
  String get cariWilayah => 'Search area';

  @override
  String get gantiWilayah => 'Change area';

  @override
  String get mencariLokasi => 'Finding your location…';

  @override
  String get cariHint => 'Search village or district';

  @override
  String get cariMinimal => 'Type at least 3 letters.';

  @override
  String get cariTidakAdaHasil => 'No area found.';

  @override
  String get memuatDataWilayah => 'Loading area data…';

  @override
  String get gagalMemuatDataWilayah =>
      'Area data could not be loaded. Reinstall the app if this keeps happening.';

  @override
  String get favorit => 'Favourites';

  @override
  String get belumAdaFavorit =>
      'No favourite areas yet. Tap the star icon to save one.';

  @override
  String get tambahFavorit => 'Add to favourites';

  @override
  String get hapusFavorit => 'Remove from favourites';

  @override
  String get gpsLayananMati =>
      'Location services (GPS) are off. Turn them on and try again, or search for an area manually.';

  @override
  String get gpsDitolak =>
      'Location permission was denied. You can still search for an area manually.';

  @override
  String get gpsDitolakPermanen =>
      'Location permission is permanently denied. Enable it in app settings, or search for an area manually.';

  @override
  String get gpsGagal =>
      'Your location could not be determined. Please choose an area manually.';

  @override
  String get gpsDiluarWilayah =>
      'Your location does not match any village in Indonesia. Please choose an area manually.';

  @override
  String get bukaPengaturanAplikasi => 'Open app settings';

  @override
  String get bukaPengaturanLokasi => 'Open location settings';

  @override
  String get channelGempaNama => 'Earthquakes';

  @override
  String get channelGempaDeskripsi =>
      'New earthquake alerts above the magnitude you chose.';

  @override
  String get notifJudul => 'Earthquake notifications';

  @override
  String get notifKeterangan =>
      'Notify me about earthquakes with a magnitude of at least:';

  @override
  String get notifMati => 'Off';

  @override
  String get notifMatiKeterangan => 'Don\'t receive earthquake notifications';

  @override
  String get notifM4 => 'M 4.0 and above';

  @override
  String get notifM5 => 'M 5.0 and above';

  @override
  String get notifM6 => 'M 6.0 and above';

  @override
  String get notifM4Keterangan => 'Includes small earthquakes that are felt';

  @override
  String get notifM5Keterangan => 'Moderate to strong earthquakes';

  @override
  String get notifM6Keterangan => 'Strong earthquakes only';

  @override
  String get notifBelumAktif =>
      'Notifications are not available on this device: Firebase is not configured or the platform is not supported.';

  @override
  String get notifIzinDitolak =>
      'Notification permission was denied. Enable it in app settings so earthquake alerts can appear.';

  @override
  String get notifGagalLangganan =>
      'Notification settings could not be saved. Check your internet connection and try again.';

  @override
  String get notifSumber =>
      'Notifications are sent by the SiCuaca server based on the latest earthquake data. Source: BMKG';

  @override
  String get notifBahasaCatatan =>
      'Notification text is sent by the server in Indonesian.';

  @override
  String get peringatanDiniSegera => 'Severe weather warnings: coming soon';

  @override
  String get peringatanKeterangan =>
      'Early warnings for extreme weather in your area.';

  @override
  String get tentangKeterangan =>
      'Weather forecast and earthquake information app for Indonesia.';

  @override
  String get tentangSumber =>
      'Data source: BMKG (Indonesian Agency for Meteorology, Climatology, and Geophysics). SiCuaca is not an official BMKG app.';

  @override
  String get tentangDataWilayah =>
      'Area codes and coordinates: cahyadsn/wilayah and cahyadsn/wilayah_boundaries (MIT licence), following Ministry of Home Affairs Decree No 300.2.2-2430 of 2025.';

  @override
  String get tentangPengaturan => 'Settings';

  @override
  String get tentangKredit => 'Credits and data sources';

  @override
  String get tentangBahasa => 'Language';

  @override
  String get tentangTema => 'Theme';

  @override
  String get tentangVersi => 'App version';

  @override
  String versiAplikasi(String versi, String build) {
    return '$versi (build $build)';
  }

  @override
  String get ikutiSistem => 'System default';

  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';

  @override
  String get bahasaInggris => 'English';

  @override
  String get temaTerang => 'Light';

  @override
  String get temaGelap => 'Dark';

  @override
  String get lisensiSumberTerbuka => 'Open source licences';

  @override
  String get lisensiDataWilayah => 'Area data (cahyadsn)';

  @override
  String get selengkapnya => 'See more';

  @override
  String dataTerakhir(String waktu) {
    return 'Data last updated $waktu';
  }

  @override
  String get prakiraanPer3Jam => '3-hourly forecast';

  @override
  String get magKecil => 'Minor';

  @override
  String get magRingan => 'Light';

  @override
  String get magSedang => 'Moderate';

  @override
  String get magKuat => 'Strong';

  @override
  String get magBesar => 'Major';

  @override
  String get magTakDiketahui => 'Unknown';

  @override
  String magnitudoSemantik(String nilai, String tingkat) {
    return 'Magnitude $nilai, $tingkat';
  }

  @override
  String get navPengaturan => 'Settings';

  @override
  String get pengaturanTampilan => 'Display';

  @override
  String get tentangJudul => 'About SiCuaca';

  @override
  String get dataTidakTersedia => 'Data is not available for this location.';

  @override
  String get pilihDariDaftar => 'Browse regions';

  @override
  String get pilihDariDaftarKeterangan =>
      'Province, regency/city, district, then village';

  @override
  String get pilihProvinsi => 'Choose province';

  @override
  String get pilihKabKota => 'Choose regency/city';

  @override
  String get pilihKecamatan => 'Choose district';

  @override
  String get pilihDesa => 'Choose village';

  @override
  String get saringDaftar => 'Filter list';

  @override
  String get semuaWilayah => 'Indonesia';

  @override
  String get riwayatJudul => 'Earthquake History';

  @override
  String get riwayatKosong =>
      'No earthquake history yet. Load earthquake data first.';

  @override
  String riwayatJumlah(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events shown',
      one: '1 event shown',
    );
    return '$_temp0';
  }

  @override
  String get riwayatTidakCocok => 'No data matches the filter.';

  @override
  String get semuaMagnitudo => 'All magnitudes';

  @override
  String get dalam100Km => 'Within 100 km';

  @override
  String get statTerbesar => 'Largest';

  @override
  String get statTerdekat => 'Nearest';

  @override
  String get statTotal => 'Total';

  @override
  String get siagaJudul => 'Earthquake Preparedness';

  @override
  String get siagaSebelum => 'Before an earthquake';

  @override
  String get siagaSaat => 'During an earthquake';

  @override
  String get siagaSetelah => 'After an earthquake';

  @override
  String tasSiagaJudul(String selesai, String total) {
    return 'Emergency bag checklist ($selesai/$total)';
  }

  @override
  String get siagaCatatan =>
      'This guide is for education. Follow official instructions from the government and BMKG during an emergency.';

  @override
  String get salinRingkasan => 'Copy summary';

  @override
  String get ringkasanDisalin => 'Summary copied to the clipboard.';

  @override
  String ringkasanGempa(
    String magnitudo,
    String wilayah,
    String waktu,
    String kedalaman,
  ) {
    return 'M $magnitudo earthquake at $wilayah, $waktu. Depth $kedalaman. Source: BMKG.';
  }

  @override
  String get bagikan => 'Share';

  @override
  String get bagikanCuaca => 'Share weather info';

  @override
  String get bagikanGempa => 'Share earthquake info';

  @override
  String get onboardingLewati => 'Skip';

  @override
  String get onboardingLanjut => 'Next';

  @override
  String get onboardingMulai => 'Get started';

  @override
  String get onboardingCuacaJudul => 'Accurate Weather Forecast';

  @override
  String get onboardingCuacaDeskripsi =>
      'Track current weather and 3-hourly forecasts for every village and district in Indonesia directly from BMKG.';

  @override
  String get onboardingGempaJudul => 'Earthquake Info & Alerts';

  @override
  String get onboardingGempaDeskripsi =>
      'Stay updated on recent earthquakes, magnitude, distance from you, and get automatic alerts when earthquakes strike.';

  @override
  String get onboardingWilayahJudul => 'Easy Region Search';

  @override
  String get onboardingWilayahDeskripsi =>
      'Use GPS to instantly detect your location or browse over 80,000 villages across Indonesia.';

  @override
  String get panduanAplikasi => 'App introduction';

  @override
  String get panduanAplikasiKeterangan =>
      'Revisit the introductory feature slides';

  @override
  String bagikanCuacaJudul(String lokasi) {
    return '🌤️ Weather in $lokasi';
  }

  @override
  String get bagikanGempaJudul => '⚠️ Earthquake info';

  @override
  String get bagikanSumber => 'Source: BMKG · via SiCuaca';

  @override
  String get subjudulBeranda => 'Weather and earthquakes for today';

  @override
  String get subjudulCuaca => 'Local forecast from BMKG';

  @override
  String get subjudulGempa => 'Latest seismic information';

  @override
  String get subjudulPeringatan => 'Set up the notifications you need';

  @override
  String get subjudulPengaturan => 'Customise your SiCuaca experience';

  @override
  String get bandingkanFavorit => 'Compare favourites';

  @override
  String get bandingkanJudul => 'Compare weather';

  @override
  String bandingkanKeterangan(String n) {
    return 'Comparing $n of up to 3 favourite regions.';
  }

  @override
  String get kartuCuaca => 'Weather card';

  @override
  String get bukanResmi => 'SiCuaca is not an official BMKG app.';

  @override
  String ringkasanCuaca(
    String lokasi,
    String kondisi,
    String suhu,
    String catatan,
  ) {
    return 'Weather in $lokasi: $kondisi, $suhu. ${catatan}Source: BMKG. SiCuaca is not an official BMKG app.';
  }

  @override
  String get bagikanKartuCuaca => 'Share weather card';

  @override
  String get salinRingkasanTeks => 'Copy text summary';

  @override
  String get ringkasanCuacaDisalin => 'Weather summary copied';

  @override
  String get gempaSiagaJudul => 'Stay alert, stay calm';

  @override
  String get gempaSiagaKeterangan =>
      'Follow official information and prepare safe steps.';

  @override
  String get pengaturanIntro =>
      'Display, language, and notification choices are stored on this device.';

  @override
  String get peringatanIntro =>
      'Choose a magnitude threshold so the alerts you get stay relevant to you.';

  @override
  String get jejakAktivitas => 'Activity trail';

  @override
  String get cariWilayahGempa => 'Search earthquake region';

  @override
  String get hapusPencarian => 'Clear search';

  @override
  String get rentangGrafik => 'Chart range';

  @override
  String get grafikPerHari => 'Daily chart';

  @override
  String get grafikPerMinggu => 'Weekly chart';

  @override
  String get saringMagnitudo => 'Filter by magnitude';

  @override
  String minimalMagnitudo(String nilai) {
    return 'At least M$nilai';
  }

  @override
  String get gempaDalam100Km => 'Earthquakes within 100 km';

  @override
  String get gempaPerHari => 'Earthquakes per day';

  @override
  String get gempaPerMinggu => 'Earthquakes per week';

  @override
  String get grafikCatatan =>
      'Based on the history stored on this device. This is not the total of all BMKG events.';

  @override
  String mingguKe(String n) {
    return 'Week $n';
  }

  @override
  String jumlahKejadian(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n events',
      one: '1 event',
    );
    return '$_temp0';
  }

  @override
  String totalGrafik(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Total on chart: $n events',
      one: 'Total on chart: 1 event',
    );
    return '$_temp0';
  }

  @override
  String get siagaHeroJudul => 'Preparedness starts before an earthquake.';

  @override
  String get siagaHeroKeterangan =>
      'Learn the safe steps and complete your emergency bag bit by bit.';

  @override
  String get grafikSuhuJudul => 'Next 24 hours';

  @override
  String grafikSuhuSemantik(
    String sekarang,
    String tertinggi,
    String terendah,
  ) {
    return 'Temperature for the next 24 hours: now $sekarang degrees, high $tertinggi, low $terendah';
  }

  @override
  String sapaPagi(String lokasi) {
    return 'Good morning, $lokasi';
  }

  @override
  String sapaSiang(String lokasi) {
    return 'Good afternoon, $lokasi';
  }

  @override
  String sapaSore(String lokasi) {
    return 'Good evening, $lokasi';
  }

  @override
  String sapaMalam(String lokasi) {
    return 'Good night, $lokasi';
  }

  @override
  String get riwayatNotifJudul => 'Notification history';

  @override
  String get riwayatNotifKeterangan => 'Earthquakes that notified this device.';

  @override
  String get riwayatNotifKosong =>
      'No earthquake notifications received yet. Pick a magnitude threshold in Alerts to receive them.';

  @override
  String diterimaWaktu(String waktu) {
    return 'Received $waktu';
  }

  @override
  String get hapusRiwayat => 'Clear history';

  @override
  String get hapusRiwayatKonfirmasi =>
      'Delete all notification history on this device? This cannot be undone.';

  @override
  String get aksiBatal => 'Cancel';

  @override
  String get aksiHapus => 'Delete';

  @override
  String get urutanBerandaJudul => 'Home order';

  @override
  String get urutanBerandaKeterangan =>
      'Drag or use the arrow buttons to change the order of the Home sections.';

  @override
  String get urutanBerandaRingkas => 'Arrange Weather, Earthquakes, and Alerts';

  @override
  String get setelUlangUrutan => 'Reset order';

  @override
  String naikkanBagian(String nama) {
    return 'Move $nama up';
  }

  @override
  String turunkanBagian(String nama) {
    return 'Move $nama down';
  }

  @override
  String get riwayatBiasLabel => 'From data stored on this device';

  @override
  String riwayatRentangData(String mulai, String akhir) {
    return 'Stored data: $mulai – $akhir';
  }

  @override
  String get riwayatBiasCatatan =>
      'BMKG only provides a short list of recent earthquakes, so this history only holds earthquakes this device has loaded or received. The numbers are not complete statistics of earthquakes in Indonesia.';

  @override
  String riwayatDariTotal(String n, String total) {
    return '$n of $total stored records';
  }

  @override
  String get statJumlahGempa => 'Earthquakes';

  @override
  String get statLokasiTidakAda => 'Location unavailable';

  @override
  String get statLabelBias => 'Statistics from data stored on this device';

  @override
  String get riwayatGagalMuat =>
      'The earthquake history could not be read from device storage. Try again.';

  @override
  String get riwayatKosongCatatan =>
      'History fills automatically when BMKG earthquake data is loaded or an earthquake notification is received.';

  @override
  String get filterJudul => 'Filter history';

  @override
  String get filterTanggal => 'Date range';

  @override
  String get filterSemuaTanggal => 'All dates';

  @override
  String filterHariTerakhir(String n) {
    return 'Last $n days';
  }

  @override
  String get filterPilihTanggal => 'Pick dates';

  @override
  String get filterPilihTanggalBantuan => 'Pick the date range of the events';

  @override
  String get filterMagnitudo => 'Minimum magnitude';

  @override
  String get filterJarak => 'Maximum distance from you';

  @override
  String get filterSemuaJarak => 'Any distance';

  @override
  String filterJarakKm(String km) {
    return '$km km';
  }

  @override
  String get filterJarakNonaktif =>
      'The distance filter is unavailable because your location is not known. Turn on location to use it.';

  @override
  String get filterTerapkan => 'Apply';

  @override
  String get filterSetelUlang => 'Reset';

  @override
  String filterAktifJumlah(String n) {
    return 'Active filters: $n';
  }

  @override
  String get pSebelumG1 => 'Key points';

  @override
  String get pSebelumG1B1 => 'Learn what an earthquake is;';

  @override
  String get pSebelumG1B2 =>
      'Make sure the structure and location of your home are safe from earthquake hazards (landslides, liquefaction, etc.);';

  @override
  String get pSebelumG1B3 =>
      'Evaluate and renovate your building structure to protect it from earthquake hazards.';

  @override
  String get pSebelumG2 => 'Know your workplace';

  @override
  String get pSebelumG2B1 =>
      'Note the location of doors, lifts, and emergency stairs, and know the safest place to take shelter if an earthquake occurs;';

  @override
  String get pSebelumG2B2 => 'Learn first aid;';

  @override
  String get pSebelumG2B3 => 'Learn to use a fire extinguisher;';

  @override
  String get pSebelumG2B4 =>
      'Write down important phone numbers to call when an earthquake occurs.';

  @override
  String get pSebelumG3 => 'Routine preparation at work and at home';

  @override
  String get pSebelumG3B1 =>
      'Fix furniture (cupboards, cabinets, etc.) to the wall (nailed, tied, etc.) so it does not fall, topple, or shift during an earthquake;';

  @override
  String get pSebelumG3B2 =>
      'Store flammable materials in containers that do not break easily to avoid fires;';

  @override
  String get pSebelumG3B3 =>
      'Always turn off water, gas, and electricity when not in use.';

  @override
  String get pSebelumG4 =>
      'Most injuries in an earthquake are caused by falling objects';

  @override
  String get pSebelumG4B1 => 'Keep heavy objects as low as possible;';

  @override
  String get pSebelumG4B2 =>
      'Check that hanging objects that could fall during an earthquake (for example lamps) are secure.';

  @override
  String get pSebelumG5 => 'Items every place should have';

  @override
  String get pSebelumG5B1 => 'First aid kit;';

  @override
  String get pSebelumG5B2 => 'Torch/battery lamp;';

  @override
  String get pSebelumG5B3 => 'Radio;';

  @override
  String get pSebelumG5B4 => 'Food supplements and water.';

  @override
  String get pSaatG1 => 'If you are inside a building';

  @override
  String get pSaatG1B1 =>
      'Protect your head and body from falling debris (for example by taking cover under a table);';

  @override
  String get pSaatG1B2 =>
      'Find the place that is safest from debris and shaking;';

  @override
  String get pSaatG1B3 => 'Run outside if you still can.';

  @override
  String get pSaatG2 => 'If you are outside or in an open area';

  @override
  String get pSaatG2B1 =>
      'Stay away from nearby structures (such as buildings, power poles, trees);';

  @override
  String get pSaatG2B2 =>
      'Watch where you step and avoid places where the ground cracks.';

  @override
  String get pSaatG3 => 'If you are driving a car';

  @override
  String get pSaatG3B1 =>
      'Get out and move away from the car, in case it shifts or catches fire;';

  @override
  String get pSaatG3B2 =>
      'Watch where you step and avoid places where the ground cracks.';

  @override
  String get pSaatG4 => 'If you live or are at the coast';

  @override
  String get pSaatG4B1 => 'Move away from the coast to avoid a tsunami.';

  @override
  String get pSaatG5 => 'If you live in a mountainous area';

  @override
  String get pSaatG5B1 =>
      'If an earthquake occurs, avoid areas where landslides may happen.';

  @override
  String get pSetelahG1 => 'If you are inside a building';

  @override
  String get pSetelahG1B1 => 'Leave the building calmly;';

  @override
  String get pSetelahG1B2 =>
      'Do not use escalators or lifts; use the regular stairs;';

  @override
  String get pSetelahG1B3 =>
      'Check whether anyone is injured and give first aid;';

  @override
  String get pSetelahG1B4 =>
      'Call for help if you or people around you are seriously injured.';

  @override
  String get pSetelahG2 => 'Check your surroundings';

  @override
  String get pSetelahG2B1 => 'Check for fires;';

  @override
  String get pSetelahG2B2 => 'Check for gas leaks;';

  @override
  String get pSetelahG2B3 => 'Check for short circuits;';

  @override
  String get pSetelahG2B4 => 'Check water flow and pipes;';

  @override
  String get pSetelahG2B5 =>
      'Check for anything else that could be dangerous (switch off electricity, do not light flames, etc.).';

  @override
  String get pSetelahG3 => 'Do not enter a building that has been hit';

  @override
  String get pSetelahG3B1 =>
      'A building that has been hit by an earthquake is prone to collapse.';

  @override
  String get pSetelahG4 => 'Do not walk around the affected area';

  @override
  String get pSetelahG4B1 =>
      'Aftershocks may still occur around the affected area.';

  @override
  String get pSetelahG5 => 'Listen for information';

  @override
  String get pSetelahG5B1 =>
      'Listen to earthquake information on the radio (in case of aftershocks);';

  @override
  String get pSetelahG5B2 =>
      'Do not be easily swayed by rumours or news from unclear sources.';

  @override
  String get pSetelahG6 => 'Fill in the survey from the relevant agency';

  @override
  String get pSetelahG6B1 =>
      'The survey is used to find out how much damage occurred at the earthquake location.';

  @override
  String get pSetelahG7 => 'Do not panic, and remember to pray';

  @override
  String get pSetelahG7B1 =>
      'Pray to God Almighty for the safety and security of us all.';

  @override
  String get tasItem1 =>
      'Important documents (land certificate, vehicle papers, diplomas, birth certificate, etc.)';

  @override
  String get tasItem2 =>
      'Clothing for three days: underwear, long trousers, jacket, blanket, towel, raincoat, etc.';

  @override
  String get tasItem3 =>
      'Long-lasting snacks (instant noodles, biscuits, shredded meat, chocolate, etc.)';

  @override
  String get tasItem4 => 'Drinking water (enough for about three days)';

  @override
  String get tasItem5 =>
      'First aid kit with personal medicine and other common medicines';

  @override
  String get tasItem6 =>
      'Radio/phone with batteries, charger, or power bank to follow disaster information';

  @override
  String get tasItem7 =>
      'Toiletries (soap, toothbrush, toothpaste, comb, cotton buds, etc.)';

  @override
  String get tasItem8 => 'Face mask (filters dirty/polluted air)';

  @override
  String get tasItem9 => 'Whistle (to call for help in an emergency)';

  @override
  String get tasItem10 => 'Enough cash for supplies for about three days';

  @override
  String get tasItem11 => 'Lighting: torch, headlamp, matches, candles, etc.';

  @override
  String get istilah_magnitudo_Nama => 'Magnitude';

  @override
  String get istilah_magnitudo_Isi =>
      'The strength of an earthquake on the Richter scale.';

  @override
  String get istilah_richter_Nama => 'Richter scale';

  @override
  String get istilah_richter_Isi =>
      'A measure of earthquake strength calculated from the energy released at the earthquake source.';

  @override
  String get istilah_kedalaman_Nama => 'Depth';

  @override
  String get istilah_kedalaman_Isi =>
      'The depth of the earthquake in kilometres.';

  @override
  String get istilah_mmi_Nama => 'MMI scale (Modified Mercalli Intensity)';

  @override
  String get istilah_mmi_Isi =>
      'A measure of earthquake strength based on the damage the earthquake causes.';

  @override
  String get istilah_waktu_Nama => 'Origin time';

  @override
  String get istilah_waktu_Isi => 'The time the earthquake occurred, in WIB.';

  @override
  String siagaSumber(String nama) {
    return 'Source: $nama';
  }

  @override
  String get siagaTerjemahan =>
      'The guidance text follows the official sources above. The English version is a translation by the SiCuaca team, not an official translation.';

  @override
  String get siagaIstilahJudul => 'Earthquake terms';

  @override
  String get tasSumberCatatan =>
      'Emergency bag list from BNPB. Adjust it to your family\'s needs.';

  @override
  String tasProgres(String n, String total) {
    return '$n of $total ready';
  }

  @override
  String tasProgresBeranda(String n, String total) {
    return 'Emergency bag: $n of $total ready';
  }

  @override
  String get splashTagline => 'Weather and earthquakes from BMKG open data';

  @override
  String get onboardingSiagaJudul => 'Earthquake Preparedness';

  @override
  String get onboardingSiagaDeskripsi =>
      'Learn safe steps before, during, and after an earthquake, then build your emergency bag. Content comes from BMKG and BNPB.';

  @override
  String get onboardingSumber =>
      'Data source: BMKG. SiCuaca is not an official BMKG app.';

  @override
  String get kacaCairJudul => 'Liquid glass effect';

  @override
  String get kacaCairKeterangan =>
      'Glass refraction and splitting button animation. Turn off if your phone feels slow; the navbar and buttons stay, with simple glass.';

  @override
  String get lainnya => 'More';
}
