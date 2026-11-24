import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../core/warna_semantik.dart';
import '../models/prakiraan.dart';
import '../providers/gempa_provider.dart';
import '../providers/weather_provider.dart';
import '../services/notifikasi_service.dart';
import '../widgets/app_chrome.dart';
import '../widgets/ikon_cuaca.dart';
import 'beranda_screen.dart';
import 'cuaca_screen.dart';
import 'gempa_screen.dart';
import 'pengaturan_screen.dart';

/// Kerangka utama dengan bottom bar 4 tab. Tab Cuaca dan Gempa menampilkan
/// data langsung (suhu sekarang dan magnitudo gempa terbaru) di tempat
/// ikonnya.
///
/// Memakai [IndexedStack] supaya semua tab tetap hidup di memori, jadi state
/// (posisi scroll, data yang sudah dimuat) tidak hilang saat berpindah tab.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    Navigasi.tabAktif.value = TabUtama.beranda;
    // Navigator sudah ada setelah frame pertama; ketukan notifikasi yang
    // terjadi sebelumnya (aplikasi diluncurkan dari notifikasi) dibuka saat
    // pembuka dipasang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotifikasiService>().pembuka.pasang(
        Navigasi.bukaDetailGempa,
      );
    });
  }

  static const List<Widget> _halaman = [
    BerandaScreen(),
    CuacaScreen(),
    GempaScreen(),
    PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Navigasi.tabAktif,
      builder: (context, indeks, _) => Scaffold(
        body: IndexedStack(index: indeks, children: _halaman),
        bottomNavigationBar: _NavigasiBawah(indeks: indeks),
      ),
    );
  }
}

class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({required this.indeks});

  final int indeks;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dock = isDark ? const Color(0xFF101116) : const Color(0xFFFFFFFF);
    final outline = isDark ? const Color(0xFF3A3D49) : const Color(0xFFE0DCEA);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: dock,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: outline, width: 1.25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .22),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            _Tab(
              kunci: 'beranda',
              indeks: TabUtama.beranda,
              aktif: indeks == TabUtama.beranda,
              label: l.navBeranda,
              isi: (warna, aktif) => _IkonTab(IkonApp.beranda, warna, aktif),
            ),
            _Tab(
              kunci: 'cuaca',
              indeks: TabUtama.cuaca,
              aktif: indeks == TabUtama.cuaca,
              label: l.navCuaca,
              nilai: _nilaiCuaca(context),
              isi: (warna, aktif) => _IsiCuaca(warna: warna, aktif: aktif),
            ),
            _Tab(
              kunci: 'gempa',
              indeks: TabUtama.gempa,
              aktif: indeks == TabUtama.gempa,
              label: l.navGempa,
              nilai: _nilaiGempa(context),
              isi: (warna, aktif) => _IsiGempa(warna: warna, aktif: aktif),
            ),
            _Tab(
              kunci: 'pengaturan',
              indeks: TabUtama.pengaturan,
              aktif: indeks == TabUtama.pengaturan,
              label: l.navPengaturan,
              isi: (warna, aktif) => _IkonTab(IkonApp.pengaturan, warna, aktif),
            ),
          ],
        ),
      ),
    );
  }

  /// Teks untuk pembaca layar, mis. "28°C, Hujan Ringan".
  static String? _nilaiCuaca(BuildContext context) {
    final entri = _entriSekarang(context);
    if (entri == null) return null;
    return '${Format.suhu(entri.suhu)}, ${context.l10n.deskripsiCuaca(entri)}';
  }

  static String? _nilaiGempa(BuildContext context) {
    final gempa = context.watch<GempaProvider>().terbaru.data;
    if (gempa == null) return null;
    final l = context.l10n;
    return l.magnitudoSemantik(
      gempa.magnitudo,
      TingkatMagnitudo.dari(gempa.magnitudoAngka).label(l),
    );
  }
}

EntriPrakiraan? _entriSekarang(BuildContext context) {
  final cuaca = context.watch<WeatherProvider>();
  if (cuaca.status != StatusCuaca.berhasil) return null;
  return cuaca.prakiraan?.entriTerdekat(DateTime.now());
}

/// Satu tab: garis penanda di atas, isi (ikon atau data), lalu label.
class _Tab extends StatelessWidget {
  const _Tab({
    required this.kunci,
    required this.indeks,
    required this.aktif,
    required this.label,
    required this.isi,
    this.nilai,
  });

  final String kunci;
  final int indeks;
  final bool aktif;
  final String label;

  /// Nilai data untuk pembaca layar (suhu, magnitudo).
  final String? nilai;
  final Widget Function(Color warna, bool aktif) isi;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final warnaAktif = isDark ? const Color(0xFFC9C1FF) : scheme.primary;
    final warnaPasif = isDark
        ? const Color(0xFFC9CBD5)
        : const Color(0xFF625F70);
    final warna = aktif ? warnaAktif : warnaPasif;
    final tanpaGerak = MediaQuery.of(context).disableAnimations;

    return Expanded(
      child: Semantics(
        key: ValueKey('nav.$kunci'),
        selected: aktif,
        button: true,
        label: label,
        value: nilai,
        child: ExcludeSemantics(
          child: TekanLembut(
            borderRadius: BorderRadius.circular(22),
            onTap: () => Navigasi.bukaTab(indeks),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: tanpaGerak
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    width: aktif ? 22 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      color: warnaAktif,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(height: 26, child: Center(child: isi(warna, aktif))),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: warna,
                      fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IkonTab extends StatelessWidget {
  const _IkonTab(this.ikon, this.warna, this.aktif);

  final IconData ikon;
  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    return IkonDuo(
      ikon,
      size: 24,
      color: warna,
      // Tab aktif: isian duotone lebih pekat.
      duotoneSecondaryOpacity: aktif ? 0.45 : 0.18,
    );
  }
}

/// Ikon kondisi + suhu sekarang, mis. ☁ 28°. Tanpa data: ikon cuaca biasa.
class _IsiCuaca extends StatelessWidget {
  const _IsiCuaca({required this.warna, required this.aktif});

  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final entri = _entriSekarang(context);
    if (entri == null) return _IkonTab(IkonApp.cuaca, warna, aktif);
    final suhu = entri.suhu;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IkonCuaca(
          deskripsi: entri.deskripsi,
          malam: entri.malam,
          size: 20,
          warna: warna,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            suhu == null ? Format.tandaKosong : '${suhu.round()}°',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: warna,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip magnitudo gempa terbaru dengan warna tingkatnya. Tanpa data: ikon.
class _IsiGempa extends StatelessWidget {
  const _IsiGempa({required this.warna, required this.aktif});

  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final gempa = context.watch<GempaProvider>().terbaru.data;
    if (gempa == null) return _IkonTab(IkonApp.gempa, warna, aktif);
    final tingkat = TingkatMagnitudo.dari(gempa.magnitudoAngka);
    final angka = gempa.magnitudo.isNotEmpty
        ? gempa.magnitudo
        : (gempa.magnitudoAngka?.toStringAsFixed(1) ?? Format.tandaKosong);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tingkat.latar,
        borderRadius: BorderRadius.circular(8),
        border: aktif ? Border.all(color: warna, width: 1.5) : null,
      ),
      child: Text(
        'M$angka',
        maxLines: 1,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: tingkat.depan,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
