import 'package:flutter/material.dart';
import '../widgets/langit_latar.dart';
import '../widgets/tombol_kaca.dart';
import 'ikon.dart';

/// Token tampilan SiCuaca, arah "Langit Kaca" (Material 3): latar langit
/// biru, kartu kaca bening, dan kaca cair untuk navbar/tombol.
///
/// Warna ditetapkan manual, tidak memakai warna dinamis dari wallpaper,
/// supaya warna semantik (magnitudo, gelombang) tidak berubah. Kontras teks
/// utama terhadap latar langit dan kartu kaca dicatat di komentar (WCAG).
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
  static const double radiusKartu = 24;
  static const double radiusTile = 18;

  // Putih di atasnya 8,2:1; di langit atas #9DCDF8 4,7:1.
  static const Color _primerTerang = Color(0xFF154F9E);

  /// Ujung atas latar langit (juga warna AppBar, agar menyambung).
  static const Color langitAtasTerang = Color(0xFF9DCDF8);
  static const Color langitTengahTerang = Color(0xFFC3E0FB);
  static const Color langitBawahTerang = Color(0xFFEDF5FD);
  static const Color langitAtasGelap = Color(0xFF10234A);
  static const Color langitTengahGelap = Color(0xFF0D1A36);
  static const Color langitBawahGelap = Color(0xFF0A1428);

  /// Banner berlatar biru tua (gempa, siaga) dengan teks putih. Kontras
  /// putih 10,9:1 di ujung gelap dan 6,1:1 di ujung terang; #EAF3FF (teks
  /// sekunder) 9,8:1 dan 5,4:1.
  static const Color bannerAtas = Color(0xFF123A7A);
  static const Color bannerBawah = Color(0xFF1F5FBF);
  static const Color bannerRedup = Color(0xFFEAF3FF);

  /// Isian dan tepi kaca untuk kartu/tile (tanpa blur, ringan).
  static Color kacaIsi(Brightness b) =>
      b == Brightness.dark ? const Color(0x661B2E55) : const Color(0xA6FFFFFF);
  static Color kacaTepi(Brightness b) =>
      b == Brightness.dark ? const Color(0x33FFFFFF) : const Color(0xCCFFFFFF);

  static final ColorScheme skemaTerang =
      ColorScheme.fromSeed(seedColor: _primerTerang).copyWith(
        primary: _primerTerang,
        onPrimary: Colors.white,
        primaryContainer: const Color(0xFFD8E9FF),
        onPrimaryContainer: const Color(0xFF0A2A55),
        // Banner offline: kuning lembut, bukan merah muda bawaan seed.
        tertiaryContainer: const Color(0xFFFFE7B3),
        onTertiaryContainer: const Color(0xFF261A00),
        surface: langitBawahTerang,
        onSurface: const Color(0xFF0F1E33), // 13,9:1 di #8CC4F6 = 8,9:1
        onSurfaceVariant: const Color(0xFF3D4D63), // 7,9:1; di #8CC4F6 5,1:1
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: const Color(0xFFF3F8FE),
        surfaceContainer: const Color(0xFFE8F1FC),
        surfaceContainerHigh: const Color(0xFFDDEAF9),
        surfaceContainerHighest: const Color(0xFFD2E3F6),
        outline: const Color(0xFF6B7A8E),
        outlineVariant: const Color(0xFFCFDDEE),
        surfaceTint: Colors.transparent,
      );

  static final ColorScheme skemaGelap =
      ColorScheme.fromSeed(
        seedColor: _primerTerang,
        brightness: Brightness.dark,
      ).copyWith(
        primary: const Color(0xFF9CCBFF),
        onPrimary: const Color(0xFF07264C),
        primaryContainer: const Color(0xFF1C3F72),
        onPrimaryContainer: const Color(0xFFD6E8FF),
        tertiaryContainer: const Color(0xFF4A3A10),
        onTertiaryContainer: const Color(0xFFFFE7B3),
        surface: langitBawahGelap,
        onSurface: const Color(0xFFE7EEF8), // 15,9:1
        onSurfaceVariant: const Color(0xFFB2C1D6), // 9,6:1
        surfaceContainerLowest: const Color(0xFF08101F),
        surfaceContainerLow: const Color(0xFF111D35),
        surfaceContainer: const Color(0xFF15233F),
        surfaceContainerHigh: const Color(0xFF1C2C4C),
        surfaceContainerHighest: const Color(0xFF243658),
        outline: const Color(0xFF8292A8),
        outlineVariant: const Color(0xFF2A3B5C),
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

  /// Transisi antar halaman: memudar sambil bergeser tipis (gaya Material 3),
  /// sama di semua platform. Dimatikan saat "kurangi gerakan".
  static const PageTransitionsTheme _transisiHalaman = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _TransisiHalaman(),
      TargetPlatform.iOS: _TransisiHalaman(),
      TargetPlatform.macOS: _TransisiHalaman(),
      TargetPlatform.windows: _TransisiHalaman(),
      TargetPlatform.linux: _TransisiHalaman(),
      TargetPlatform.fuchsia: _TransisiHalaman(),
    },
  );

  static ThemeData _build(ColorScheme skema) {
    final dasar = ThemeData(
      colorScheme: skema,
      fontFamily: hurufIsi,
      textTheme: _huruf,
      // Latar langit digambar per halaman (LangitLatar), jadi Scaffold bening.
      scaffoldBackgroundColor: Colors.transparent,
    );
    final huruf = dasar.textTheme;

    return dasar.copyWith(
      pageTransitionsTheme: _transisiHalaman,
      // Tombol kembali/tutup di semua AppBar: lingkaran kaca cair.
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (_) =>
            const LingkaranKaca(child: Icon(Icons.arrow_back_rounded)),
        closeButtonIconBuilder: (_) =>
            const LingkaranKaca(child: IkonDuo(IkonApp.tutup)),
      ),
      appBarTheme: AppBarTheme(
        // Top bar bening: hanya judul dan tombol di atas langit.
        backgroundColor: Colors.transparent,
        foregroundColor: skema.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        titleTextStyle: huruf.titleLarge?.copyWith(color: skema.onSurface),
      ),
      // Kartu kaca bening (tanpa blur): isian tembus pandang + tepi terang.
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: kacaIsi(skema.brightness),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusKartu),
          side: BorderSide(color: kacaTepi(skema.brightness)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: huruf.titleSmall,
        unselectedLabelStyle: huruf.titleSmall,
        labelColor: skema.primary,
        unselectedLabelColor: skema.onSurfaceVariant,
        dividerColor: Colors.transparent,
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

class _TransisiHalaman extends PageTransitionsBuilder {
  const _TransisiHalaman();

  static const _dasar = FadeForwardsPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Langit ikut halaman (juga di belakang top bar) dan ikut memudar.
    final halaman = LangitLatar(child: child);
    if (MediaQuery.of(context).disableAnimations) return halaman;
    return _dasar.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      halaman,
    );
  }
}
