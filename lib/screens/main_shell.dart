import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../services/notifikasi_service.dart';
import 'beranda_screen.dart';
import 'cuaca_screen.dart';
import 'gempa_screen.dart';
import 'peringatan_screen.dart';
import 'tentang_screen.dart';

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
  int _indeks = 0;

  @override
  void initState() {
    super.initState();
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
    TentangScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _indeks, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (i) => setState(() => _indeks = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.l10n.navBeranda,
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon: const Icon(Icons.wb_sunny),
            label: context.l10n.navCuaca,
          ),
          NavigationDestination(
            icon: const Icon(Icons.waves),
            label: context.l10n.navGempa,
          ),
          NavigationDestination(
            icon: const Icon(Icons.warning_amber_outlined),
            selectedIcon: const Icon(Icons.warning_amber),
            label: context.l10n.navPeringatan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outline),
            selectedIcon: const Icon(Icons.info),
            label: context.l10n.navTentang,
          ),
        ],
      ),
    );
  }
}
