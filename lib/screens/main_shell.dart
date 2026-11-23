import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../services/notifikasi_service.dart';
import '../widgets/app_chrome.dart';
import 'beranda_screen.dart';
import 'cuaca_screen.dart';
import 'gempa_screen.dart';
import 'peringatan_screen.dart';
import 'pengaturan_screen.dart';

/// Kerangka utama dengan bottom bar 5 tab.
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
    PeringatanScreen(),
    PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ValueListenableBuilder<int>(
      valueListenable: Navigasi.tabAktif,
      builder: (context, indeks, _) => Scaffold(
        body: IndexedStack(index: indeks, children: _halaman),
        bottomNavigationBar: _NavigasiBawah(
          indeks: indeks,
          label: [
            l.navBeranda,
            l.navCuaca,
            l.navGempa,
            l.navPeringatan,
            l.navPengaturan,
          ],
        ),
      ),
    );
  }
}

class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({required this.indeks, required this.label});
  final int indeks;
  final List<String> label;

  static const _ikon = [
    IkonApp.beranda,
    IkonApp.cuaca,
    IkonApp.gempa,
    IkonApp.peringatan,
    IkonApp.pengaturan,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dock = isDark ? const Color(0xFF101116) : const Color(0xFFFFFFFF);
    final outline = isDark ? const Color(0xFF3A3D49) : const Color(0xFFE0DCEA);
    final inactive = isDark ? const Color(0xFFC9CBD5) : const Color(0xFF625F70);
    const active = Color(0xFF4C3B9C);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: dock,
          borderRadius: BorderRadius.circular(36),
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
          children: List.generate(_ikon.length, (i) {
            final selected = indeks == i;
            return Expanded(
              child: Semantics(
                selected: selected,
                label: label[i],
                button: true,
                child: TekanLembut(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => Navigasi.bukaTab(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected ? active : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _ikon[i],
                          size: 24,
                          color: selected ? const Color(0xFFEDEAFF) : inactive,
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: Theme.of(context).textTheme.labelSmall!
                              .copyWith(
                                color: selected
                                    ? const Color(0xFFEDEAFF)
                                    : inactive,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                          child: Text(
                            label[i],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
