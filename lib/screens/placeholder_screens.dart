import 'package:flutter/material.dart';

import '../widgets/placeholder_view.dart';

class CuacaScreen extends StatelessWidget {
  const CuacaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuaca')),
      body: const PlaceholderView(
        icon: Icons.wb_sunny_outlined,
        judul: 'Prakiraan Cuaca',
        keterangan: 'Prakiraan cuaca per wilayah hingga tiga hari ke depan.',
      ),
    );
  }
}

class GempaScreen extends StatelessWidget {
  const GempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gempa')),
      body: const PlaceholderView(
        icon: Icons.waves,
        judul: 'Info Gempa Bumi',
        keterangan: 'Gempa terbaru, gempa dirasakan, dan peta guncangan.',
      ),
    );
  }
}

class PeringatanScreen extends StatelessWidget {
  const PeringatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peringatan')),
      body: const PlaceholderView(
        icon: Icons.warning_amber_outlined,
        judul: 'Peringatan Dini',
        keterangan: 'Peringatan dini cuaca ekstrem untuk wilayah Anda.',
      ),
    );
  }
}
