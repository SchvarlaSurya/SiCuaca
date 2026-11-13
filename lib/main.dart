import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/uji_koneksi_provider.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SiCuacaApp());
}

class SiCuacaApp extends StatelessWidget {
  /// [apiService] bisa diganti versi palsu saat pengujian.
  const SiCuacaApp({super.key, this.apiService});

  final ApiService? apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService ?? ApiService()),
        ChangeNotifierProvider<UjiKoneksiProvider>(
          create: (context) =>
              UjiKoneksiProvider(context.read<ApiService>())..ujiKoneksi(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const MainShell(),
      ),
    );
  }
}
