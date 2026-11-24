import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/l10n.dart';
import 'core/navigasi.dart';
import 'core/theme.dart';
import 'providers/favorit_provider.dart';
import 'providers/gempa_provider.dart';
import 'providers/lokasi_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/pengaturan_provider.dart';
import 'providers/riwayat_gempa_provider.dart';
import 'providers/siaga_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/api_service.dart';
import 'services/bmkg_repository.dart';
import 'services/cache_service.dart';
import 'services/gps_service.dart';
import 'services/notifikasi_service.dart';
import 'services/preferences_service.dart';
import 'services/riwayat_gempa_repository.dart';
import 'services/riwayat_gempa_sqflite.dart';
import 'services/wilayah_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final teks = await rootBundle.loadString('assets/data/LICENSE-wilayah.txt');
    // Judul paket lisensi bukan teks antarmuka; nama sumbernya dipakai apa
    // adanya di kedua bahasa.
    yield LicenseEntryWithLineBreaks(['cahyadsn/wilayah'], teks);
    // Huruf yang di-bundle (SIL Open Font License 1.1).
    for (final (nama, berkas) in const [
      ('Inter', 'assets/fonts/OFL-Inter.txt'),
      ('Plus Jakarta Sans', 'assets/fonts/OFL-PlusJakartaSans.txt'),
      ('Phosphor Icons', 'assets/fonts/LICENSE-Phosphor.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        nama,
      ], await rootBundle.loadString(berkas));
    }
  });

  // Firebase + handler pesan latar belakang harus siap sebelum runApp.
  // Riwayat gempa disiapkan lebih dulu agar notifikasi yang membuka
  // aplikasi (diketuk saat tertutup) langsung tercatat.
  final riwayatGempa = RiwayatGempaRepository(buatPenyimpananRiwayat());
  final notifikasi = NotifikasiService()..riwayatGempa = riwayatGempa;
  await notifikasi.mulai();

  // Pilihan bahasa/tema dimuat sebelum frame pertama agar tidak berkedip.
  final preferences = PreferencesService();
  final pengaturan = PengaturanProvider(preferences);
  await pengaturan.muat();
  final sudahOnboarding = await preferences.sudahOnboarding();

  runApp(
    SiCuacaApp(
      notifikasiService: notifikasi,
      riwayatGempa: riwayatGempa,
      preferencesService: preferences,
      pengaturan: pengaturan,
      sudahOnboarding: sudahOnboarding,
    ),
  );
}

class SiCuacaApp extends StatelessWidget {
  /// Semua service bisa diganti versi palsu saat pengujian.
  const SiCuacaApp({
    super.key,
    this.apiService,
    this.gpsService,
    this.wilayahService,
    this.preferencesService,
    this.notifikasiService,
    this.cacheService,
    this.riwayatGempa,
    this.pengaturan,
    this.sudahOnboarding = true,
  });

  final ApiService? apiService;
  final GpsService? gpsService;
  final WilayahService? wilayahService;
  final PreferencesService? preferencesService;
  final NotifikasiService? notifikasiService;
  final CacheService? cacheService;
  final RiwayatGempaRepository? riwayatGempa;
  final PengaturanProvider? pengaturan;
  final bool sudahOnboarding;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService ?? ApiService()),
        Provider<GpsService>(create: (_) => gpsService ?? GpsService()),
        Provider<WilayahService>(
          create: (_) => (wilayahService ?? WilayahService())..siapkan(),
        ),
        Provider<PreferencesService>(
          create: (_) => preferencesService ?? PreferencesService(),
        ),
        Provider<NotifikasiService>(
          create: (_) => notifikasiService ?? NotifikasiService(),
        ),
        Provider<BmkgRepository>(
          create: (context) => BmkgRepository(
            context.read<ApiService>(),
            cacheService ?? CacheService(),
          ),
        ),
        ChangeNotifierProvider<PengaturanProvider>(
          create: (context) =>
              pengaturan ??
              (PengaturanProvider(context.read<PreferencesService>())..muat()),
        ),
        ChangeNotifierProvider<LokasiProvider>(
          create: (context) => LokasiProvider(
            context.read<GpsService>(),
            context.read<WilayahService>(),
          ),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<BmkgRepository>(),
            context.read<PreferencesService>(),
            context.read<LokasiProvider>(),
          )..mulai(),
        ),
        ChangeNotifierProvider<RiwayatGempaRepository>(
          create: (_) =>
              riwayatGempa ?? RiwayatGempaRepository(buatPenyimpananRiwayat()),
        ),
        ChangeNotifierProvider<GempaProvider>(
          create: (context) => GempaProvider(
            context.read<BmkgRepository>(),
            context.read<LokasiProvider>(),
            context.read<RiwayatGempaRepository>(),
            cacheService ?? CacheService(),
          )..mulai(),
        ),
        ChangeNotifierProvider<RiwayatGempaProvider>(
          create: (context) {
            final lokasi = context.read<LokasiProvider>();
            return RiwayatGempaProvider(
              context.read<RiwayatGempaRepository>(),
              posisi: () => lokasi.posisi,
              ubahPosisi: lokasi,
            )..muat();
          },
        ),
        ChangeNotifierProvider<SiagaProvider>(
          create: (context) =>
              SiagaProvider(context.read<PreferencesService>())..muat(),
        ),
        ChangeNotifierProvider<NotifikasiProvider>(
          create: (context) => NotifikasiProvider(
            context.read<NotifikasiService>(),
            context.read<PreferencesService>(),
          )..muat(),
        ),
        ChangeNotifierProvider<FavoritProvider>(
          create: (context) =>
              FavoritProvider(context.read<PreferencesService>())..muat(),
        ),
      ],
      child: _Aplikasi(sudahOnboarding: sudahOnboarding),
    );
  }
}

class _Aplikasi extends StatefulWidget {
  const _Aplikasi({required this.sudahOnboarding});

  final bool sudahOnboarding;

  @override
  State<_Aplikasi> createState() => _AplikasiState();
}

class _AplikasiState extends State<_Aplikasi> {
  late bool _sudahOnboarding;

  @override
  void initState() {
    super.initState();
    _sudahOnboarding = widget.sudahOnboarding;
  }

  void _selesaiOnboarding() {
    context.read<PreferencesService>().setSudahOnboarding(true);
    setState(() => _sudahOnboarding = true);
  }

  @override
  Widget build(BuildContext context) {
    final pengaturan = context.watch<PengaturanProvider>();
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appName,
      navigatorKey: Navigasi.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: pengaturan.tema.mode,
      locale: pengaturan.bahasa.locale,
      supportedLocales: bahasaDidukung,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // "Ikuti sistem": pakai bahasa perangkat bila didukung, selain itu
      // Bahasa Indonesia (default aplikasi).
      localeResolutionCallback: (locale, didukung) {
        for (final l in didukung) {
          if (l.languageCode == locale?.languageCode) return l;
        }
        return bahasaDidukung.first;
      },
      home: _sudahOnboarding
          ? const MainShell()
          : OnboardingScreen(onSelesai: _selesaiOnboarding),
    );
  }
}
