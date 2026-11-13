import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/navigasi.dart';
import 'core/strings.dart';
import 'core/theme.dart';
import 'providers/favorit_provider.dart';
import 'providers/gempa_provider.dart';
import 'providers/lokasi_provider.dart';
import 'providers/notifikasi_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';
import 'services/gps_service.dart';
import 'services/notifikasi_service.dart';
import 'services/preferences_service.dart';
import 'services/wilayah_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final teks = await rootBundle.loadString('assets/data/LICENSE-wilayah.txt');
    yield LicenseEntryWithLineBreaks([Str.lisensiDataWilayah], teks);
  });

  // Firebase + handler pesan latar belakang harus siap sebelum runApp.
  final notifikasi = NotifikasiService();
  await notifikasi.mulai();

  runApp(SiCuacaApp(notifikasiService: notifikasi));
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
  });

  final ApiService? apiService;
  final GpsService? gpsService;
  final WilayahService? wilayahService;
  final PreferencesService? preferencesService;
  final NotifikasiService? notifikasiService;

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
        ChangeNotifierProvider<LokasiProvider>(
          create: (context) => LokasiProvider(
            context.read<GpsService>(),
            context.read<WilayahService>(),
          ),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (context) => WeatherProvider(
            context.read<ApiService>(),
            context.read<PreferencesService>(),
            context.read<LokasiProvider>(),
          )..mulai(),
        ),
        ChangeNotifierProvider<GempaProvider>(
          create: (context) => GempaProvider(
            context.read<ApiService>(),
            context.read<LokasiProvider>(),
          )..mulai(),
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
      child: MaterialApp(
        title: Str.appName,
        navigatorKey: Navigasi.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
