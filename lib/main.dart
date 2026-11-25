import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:provider/provider.dart';

import 'core/l10n.dart';
import 'core/navigasi.dart';
import 'core/theme.dart';
import 'providers/favorit_provider.dart';
import 'providers/gempa_provider.dart';
import 'providers/lokasi_provider.dart';
import 'providers/maritim_provider.dart';
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
import 'services/maritim_repository.dart';
import 'services/notifikasi_service.dart';
import 'services/preferences_service.dart';
import 'services/riwayat_gempa_repository.dart';
import 'services/riwayat_gempa_sqflite.dart';
import 'services/wilayah_service.dart';
import 'widgets/aset_bulan.dart';
import 'widgets/splash_gerbang.dart';

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
      // Foto dan relief bulan (NASA SVS CGI Moon Kit, data LRO).
      ('NASA SVS CGI Moon Kit', 'assets/bulan/KREDIT-NASA.txt'),
    ]) {
      yield LicenseEntryWithLineBreaks([
        nama,
      ], await rootBundle.loadString(berkas));
    }
  });

  // Riwayat gempa disiapkan lebih dulu agar notifikasi yang membuka
  // aplikasi (diketuk saat tertutup) langsung tercatat. Firebase dan
  // notifikasi diinisialisasi di latar belakang, TIDAK ditunggu: itu
  // pekerjaan terberat saat mulai, dan menunggunya menahan frame pertama.
  // Notifikasi yang membuka aplikasi disimpan dulu lalu diproses saat
  // navigator siap, jadi tidak ada yang hilang. mulai() tidak melempar error.
  final riwayatGempa = RiwayatGempaRepository(buatPenyimpananRiwayat());
  final notifikasi = NotifikasiService()..riwayatGempa = riwayatGempa;
  unawaited(notifikasi.mulai());

  // Pilihan bahasa/tema dimuat sebelum frame pertama agar tidak berkedip.
  final preferences = PreferencesService();
  final pengaturan = PengaturanProvider(preferences);
  await pengaturan.muat();
  final sudahOnboarding = await preferences.sudahOnboarding();

  // Kaca cair: shader dimuat selagi splash tampil (aplikasi di bawahnya baru
  // dipasang setelah selesai, jadi tidak ada kedip). Dilewati bila pengguna
  // mematikan efek kaca cair (hemat memori dan waktu mulai); bila dinyalakan
  // lagi, shader dimuat saat pertama dipakai.
  final siapKaca = pengaturan.kacaCair
      ? LiquidGlassWidgets.initialize().catchError(
          (Object e) => debugPrint('Muat shader kaca gagal: $e'),
        )
      : Future<void>.value();

  runApp(
    LiquidGlassWidgets.wrap(
      brightnessResolver: Theme.maybeBrightnessOf,
      child: SiCuacaApp(
        notifikasiService: notifikasi,
        riwayatGempa: riwayatGempa,
        preferencesService: preferences,
        pengaturan: pengaturan,
        sudahOnboarding: sudahOnboarding,
        tampilkanSplash: true,
        siapkan: siapKaca,
      ),
    ),
  );

  // Foto bulan dimuat sesudah splash selesai supaya tidak berebut dengan
  // animasi pembuka; kartu bulan memakai gambar cadangan bila belum siap.
  unawaited(Future<void>.delayed(const Duration(seconds: 3), AsetBulan.muat));
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
    this.tampilkanSplash = false,
    this.siapkan,
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

  /// Splash dalam aplikasi; hanya dinyalakan dari [main] (tes mematikannya).
  final bool tampilkanSplash;

  /// Pekerjaan awal yang ditunggu splash sebelum aplikasi dipasang.
  final Future<void>? siapkan;

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
        Provider<MaritimRepository>(
          create: (context) => MaritimRepository(
            context.read<ApiService>(),
            cacheService ?? CacheService(),
          ),
        ),
        ChangeNotifierProvider<MaritimProvider>(
          create: (context) {
            final lokasi = context.read<LokasiProvider>();
            return MaritimProvider(
              context.read<MaritimRepository>(),
              context.read<PreferencesService>(),
              posisi: () => lokasi.posisi,
              ubahPosisi: lokasi,
            );
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
      child: _Aplikasi(
        sudahOnboarding: sudahOnboarding,
        tampilkanSplash: tampilkanSplash,
        siapkan: siapkan,
      ),
    );
  }
}

class _Aplikasi extends StatefulWidget {
  const _Aplikasi({
    required this.sudahOnboarding,
    required this.tampilkanSplash,
    this.siapkan,
  });

  final bool sudahOnboarding;
  final bool tampilkanSplash;
  final Future<void>? siapkan;

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
      // Efek kaca cair bisa dimatikan di Pengaturan: kaca sederhana tanpa
      // shader (GlassQuality.minimal). Pembungkusnya selalu ada supaya
      // berganti mode tidak membangun ulang seluruh aplikasi.
      builder: (context, anak) => GlassTheme(
        data: pengaturan.kacaCair
            ? const GlassThemeData()
            : const GlassThemeData.minimal(),
        child: anak!,
      ),
      home: SplashGerbang(
        aktif: widget.tampilkanSplash,
        siapkan: widget.siapkan,
        child: _sudahOnboarding
            ? const MainShell()
            : OnboardingScreen(onSelesai: _selesaiOnboarding),
      ),
    );
  }
}
