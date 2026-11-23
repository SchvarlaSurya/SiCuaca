import 'package:flutter/material.dart';

/// Token tampilan SiCuaca (arah "Dashboard Nusantara", Material 3).
///
/// Warna ditetapkan manual, tidak memakai warna dinamis dari wallpaper,
/// supaya warna semantik (magnitudo, kartu cuaca) tidak berubah.
///
/// Skala huruf 5 ukuran, 2 keluarga (di-bundle di assets/fonts):
/// - display 64 Plus Jakarta Sans 700 : satu angka utama per layar
/// - judul   22 Plus Jakarta Sans 700 : judul AppBar, angka di daftar
/// - subjudul 16/14 Plus Jakarta Sans 600 : judul bagian, nama tempat
/// - isi     14 Inter 400
/// - label   12 Inter 600 / keterangan 12 Inter 400
class AppTheme {
  const AppTheme._();

  static const String hurufJudul = 'PlusJakartaSans';
  static const String hurufIsi = 'Inter';

  /// Sudut membulat: kartu utama (hero) dan kartu/tile biasa.
  static const double radiusHero = 30;
  static const double radiusKartu = 22;
  static const double radiusTile = 18;

  static const Color _primerTerang = Color(0xFF5B4BDB);

  static final ColorScheme skemaTerang =
      ColorScheme.fromSeed(seedColor: _primerTerang).copyWith(
        primary: _primerTerang,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFE9E5FF),
        onPrimaryContainer: const Color(0xFF211456),
        // Banner offline: kuning lembut, bukan merah muda bawaan seed.
        tertiaryContainer: const Color(0xFFFFE7B3),
        onTertiaryContainer: const Color(0xFF261A00),
        surface: const Color(0xFFF8F7FF),
        onSurface: const Color(0xFF1D1B27),
        onSurfaceVariant: const Color(0xFF625F70),
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF2F0FA),
        surfaceContainer: const Color(0xFFEDEAF7),
        surfaceContainerHigh: const Color(0xFFE7E3F1),
        surfaceContainerHighest: const Color(0xFFE2DEEC), // primary 4,57:1
        outline: const Color(0xFF7A7589),
        outlineVariant: const Color(0xFFE0DDEA),
        surfaceTint: Colors.transparent,
      );

  static final ColorScheme skemaGelap =
      ColorScheme.fromSeed(
        seedColor: _primerTerang,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFFC9C1FF),
        onPrimary: const Color(0xFF2C1E76),
        primaryContainer: const Color(0xFF40328E),
        onPrimaryContainer: const Color(0xFFE8E3FF),
        tertiaryContainer: const Color(0xFF4A3A10),
        onTertiaryContainer: const Color(0xFFFFE7B3),
        surface: const Color(0xFF111418),
        onSurface: const Color(0xFFE1E2E8),
        onSurfaceVariant: const Color(0xFFC1C7CF),
        surfaceContainerLowest: const Color(0xFF0C0F12),
        surfaceContainerLow: const Color(0xFF191C20),
        surfaceContainer: const Color(0xFF1D2024),
        surfaceContainerHigh: const Color(0xFF272A2F),
        surfaceContainerHighest: const Color(0xFF32353A),
        outline: const Color(0xFF8B9199),
        outlineVariant: const Color(0xFF3A4048),
        surfaceTint: Colors.transparent,
      );

  static ThemeData get light => _build(skemaTerang);
  static ThemeData get dark => _build(skemaGelap);

  static TextStyle _judul(double ukuran, FontWeight tebal, double tinggi) =>
      TextStyle(
        fontFamily: hurufJudul,
        fontSize: ukuran,
        fontWeight: tebal,
        height: tinggi,
        letterSpacing: 0,
      );

  static TextStyle _isi(double ukuran, FontWeight tebal, double tinggi) =>
      TextStyle(
        fontFamily: hurufIsi,
        fontSize: ukuran,
        fontWeight: tebal,
        height: tinggi,
        letterSpacing: 0,
      );

  static final TextTheme _huruf = () {
    final display = _judul(64, FontWeight.w700, 1.05);
    final judul = _judul(22, FontWeight.w700, 1.25);
    final subjudul = _judul(16, FontWeight.w600, 1.3);
    final subjudulKecil = _judul(14, FontWeight.w600, 1.3);
    final isi = _isi(14, FontWeight.w400, 1.45);
    final label = _isi(12, FontWeight.w600, 1.35);
    final keterangan = _isi(12, FontWeight.w400, 1.35);
    return TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: display,
      headlineLarge: judul,
      headlineMedium: judul,
      headlineSmall: judul,
      titleLarge: judul,
      titleMedium: subjudul,
      titleSmall: subjudulKecil,
      bodyLarge: isi,
      bodyMedium: isi,
      bodySmall: keterangan,
      labelLarge: _isi(14, FontWeight.w600, 1.3),
      labelMedium: label,
      labelSmall: label,
    );
  }();

  static ThemeData _build(ColorScheme skema) {
    final dasar = ThemeData(
      colorScheme: skema,
      fontFamily: hurufIsi,
      textTheme: _huruf,
      scaffoldBackgroundColor: skema.surface,
    );
    final huruf = dasar.textTheme;

    return dasar.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: skema.surface,
        foregroundColor: skema.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: huruf.titleLarge?.copyWith(color: skema.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: skema.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusKartu),
          side: BorderSide(color: skema.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: skema.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        indicatorColor: skema.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? skema.onPrimaryContainer
                : skema.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => huruf.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected)
                ? skema.onSurface
                : skema.onSurfaceVariant,
          ),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: huruf.titleSmall,
        unselectedLabelStyle: huruf.titleSmall,
        labelColor: skema.primary,
        unselectedLabelColor: skema.onSurfaceVariant,
        dividerColor: skema.outlineVariant,
      ),
      dividerTheme: DividerThemeData(
        color: skema.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: skema.onSurfaceVariant,
        titleTextStyle: huruf.bodyLarge?.copyWith(color: skema.onSurface),
        subtitleTextStyle: huruf.bodySmall?.copyWith(
          color: skema.onSurfaceVariant,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}
