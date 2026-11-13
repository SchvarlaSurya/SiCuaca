import 'package:flutter/material.dart';

import 'beranda_screen.dart';
import 'placeholder_screens.dart';
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Cuaca',
          ),
          NavigationDestination(icon: Icon(Icons.waves), label: 'Gempa'),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_outlined),
            selectedIcon: Icon(Icons.warning_amber),
            label: 'Peringatan',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}
