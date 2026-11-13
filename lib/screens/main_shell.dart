import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../services/notifikasi_service.dart';
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
        bottomNavigationBar: NavigationBar(
          selectedIndex: indeks,
          onDestinationSelected: Navigasi.bukaTab,
          destinations: [
            NavigationDestination(
              icon: const Icon(IkonApp.beranda),
              label: l.navBeranda,
            ),
            NavigationDestination(
              icon: const Icon(IkonApp.cuaca),
              label: l.navCuaca,
            ),
            NavigationDestination(
              icon: const Icon(IkonApp.gempa),
              label: l.navGempa,
            ),
            NavigationDestination(
              icon: const Icon(IkonApp.peringatan),
              label: l.navPeringatan,
            ),
            NavigationDestination(
              icon: const Icon(IkonApp.pengaturan),
              label: l.navPengaturan,
            ),
          ],
        ),
      ),
    );
  }
}
