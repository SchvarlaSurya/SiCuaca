import 'package:flutter/material.dart';

import '../core/strings.dart';
import '../widgets/placeholder_view.dart';

class GempaScreen extends StatelessWidget {
  const GempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Str.navGempa)),
      body: const PlaceholderView(
        icon: Icons.waves,
        judul: Str.gempaJudul,
        keterangan: Str.gempaKeterangan,
      ),
    );
  }
}

class PeringatanScreen extends StatelessWidget {
  const PeringatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(Str.navPeringatan)),
      body: const PlaceholderView(
        icon: Icons.warning_amber_outlined,
        judul: Str.peringatanJudul,
        keterangan: Str.peringatanKeterangan,
      ),
    );
  }
}
