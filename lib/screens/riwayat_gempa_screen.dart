import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/gempa_item.dart';
import '../widgets/sumber_bmkg.dart';

/// Riwayat gempa yang pernah dimuat, termasuk saat aplikasi sedang offline.
class RiwayatGempaScreen extends StatelessWidget {
  const RiwayatGempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    final daftar = provider.riwayat;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Gempa')),
      body: daftar.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada riwayat gempa. Muat data gempa terlebih dahulu.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _IsiRiwayat(daftar: daftar),
    );
  }
}

class _IsiRiwayat extends StatefulWidget {
  const _IsiRiwayat({required this.daftar});
  final List<Gempa> daftar;

  @override
  State<_IsiRiwayat> createState() => _IsiRiwayatState();
}

class _IsiRiwayatState extends State<_IsiRiwayat> {
  double? _minimum;
  bool _hanyaDekat = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GempaProvider>();
    final hasil = widget.daftar.where((gempa) {
      final mag = gempa.magnitudoAngka;
      if (_minimum != null && (mag == null || mag < _minimum!)) return false;
      if (_hanyaDekat &&
          provider.jarakKm(gempa) != null &&
          provider.jarakKm(gempa)! > 100)
        return false;
      return true;
    }).toList();
    final terbesar = hasil
        .map((e) => e.magnitudoAngka)
        .whereType<double>()
        .fold<double?>(null, (a, b) => a == null || b > a ? b : a);
    final terdekat = hasil
        .map(provider.jarakKm)
        .whereType<double>()
        .fold<double?>(null, (a, b) => a == null || b < a ? b : a);
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(child: Text('${hasil.length} kejadian ditampilkan')),
              PopupMenuButton<double?>(
                tooltip: 'Filter magnitudo',
                icon: const Icon(Icons.filter_list),
                onSelected: (value) => setState(() => _minimum = value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: null, child: Text('Semua magnitudo')),
                  PopupMenuItem(value: 4, child: Text('Minimal M4.0')),
                  PopupMenuItem(value: 5, child: Text('Minimal M5.0')),
                  PopupMenuItem(value: 6, child: Text('Minimal M6.0')),
                ],
              ),
              IconButton(
                tooltip: 'Gempa dalam 100 km',
                icon: Icon(
                  _hanyaDekat ? Icons.near_me : Icons.near_me_outlined,
                ),
                onPressed: () => setState(() => _hanyaDekat = !_hanyaDekat),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _Statistik(
                label: 'Terbesar',
                value: terbesar == null
                    ? '-'
                    : 'M${terbesar.toStringAsFixed(1)}',
              ),
              const SizedBox(width: 8),
              _Statistik(
                label: 'Terdekat',
                value: terdekat == null
                    ? '-'
                    : '${terdekat.toStringAsFixed(0)} km',
              ),
              const SizedBox(width: 8),
              _Statistik(label: 'Total', value: '${hasil.length}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < hasil.length; i++) ...[
          if (i > 0) const Divider(indent: 92, endIndent: 16),
          GempaItem(gempa: hasil[i]),
        ],
        if (hasil.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Tidak ada data yang cocok dengan filter.',
              textAlign: TextAlign.center,
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SumberBmkg(),
        ),
      ],
    );
  }
}

class _Statistik extends StatelessWidget {
  const _Statistik({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            children: [
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
