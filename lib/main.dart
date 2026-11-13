import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/strings.dart';
import 'core/theme.dart';
import 'providers/favorit_provider.dart';
import 'providers/lokasi_provider.dart';
import 'providers/uji_koneksi_provider.dart';
import 'providers/weather_provider.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';
import 'services/gps_service.dart';
import 'services/preferences_service.dart';
import 'services/wilayah_service.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final teks = await rootBundle.loadString('assets/data/LICENSE-wilayah.txt');
    yield LicenseEntryWithLineBreaks([Str.lisensiDataWilayah], teks);
  });
  runApp(const SiCuacaApp());
}

class SiCuacaApp extends StatelessWidget {
  /// Semua service bisa diganti versi palsu saat pengujian.
  const SiCuacaApp({
    super.key,
    this.apiService,
    this.gpsService,
    this.wilayahService,
    this.preferencesService,
  });

  final ApiService? apiService;
  final GpsService? gpsService;
  final WilayahService? wilayahService;
  final PreferencesService? preferencesService;

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
        ChangeNotifierProvider<UjiKoneksiProvider>(
          create: (context) =>
              UjiKoneksiProvider(context.read<ApiService>())..ujiKoneksi(),
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
        ChangeNotifierProvider<FavoritProvider>(
          create: (context) =>
              FavoritProvider(context.read<PreferencesService>())..muat(),
        ),
      ],
      child: MaterialApp(
        title: Str.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
