import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/gempa_item.dart';
import '../widgets/status_data.dart';
import '../widgets/sumber_bmkg.dart';

/// Riwayat gempa yang pernah dimuat, termasuk saat aplikasi sedang offline.
class RiwayatGempaScreen extends StatelessWidget {
  const RiwayatGempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    final daftar = provider.riwayat;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.riwayatJudul)),
      body: daftar.isEmpty
          ? Center(child: KosongData(pesan: context.l10n.riwayatKosong))
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
  /// Batas bawah magnitudo; null = semua.
  double? _minimum;
  bool _hanyaDekat = false;

  static const double _radiusDekatKm = 100;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<GempaProvider>();
    final hasil = widget.daftar.where((gempa) {
      final mag = gempa.magnitudoAngka;
      final minimum = _minimum;
      if (minimum != null && (mag == null || mag < minimum)) return false;
      final jarak = provider.jarakKm(gempa);
      if (_hanyaDekat && jarak != null && jarak > _radiusDekatKm) {
        return false;
      }
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

    final pilihanMagnitudo = <double?, String>{
      null: l.semuaMagnitudo,
      4: l.notifM4,
      5: l.notifM5,
      6: l.notifM6,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in pilihanMagnitudo.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: _minimum == e.key,
                onSelected: (_) => setState(() => _minimum = e.key),
              ),
            // Tanpa posisi GPS jarak tidak bisa dihitung, jadi saringan
            // jarak dinonaktifkan.
            FilterChip(
              avatar: const Icon(IkonApp.jarak, size: 18),
              label: Text(l.dalam100Km),
              selected: _hanyaDekat,
              onSelected: provider.adaPosisi
                  ? (v) => setState(() => _hanyaDekat = v)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        KisiTile(
          children: [
            TileInfo(
              ikon: IkonApp.gempa,
              label: l.statTerbesar,
              nilai: terbesar == null
                  ? Format.tandaKosong
                  : 'M ${Format.desimal(l, terbesar)}',
            ),
            TileInfo(
              ikon: IkonApp.jarak,
              label: l.statTerdekat,
              nilai: terdekat == null
                  ? Format.tandaKosong
                  : '${Format.jarak(l, terdekat)} km',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l.riwayatJumlah(hasil.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (hasil.isEmpty)
          KosongData(pesan: l.riwayatTidakCocok)
        else
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < hasil.length; i++) ...[
                  if (i > 0) const Divider(indent: 92, endIndent: 16),
                  GempaItem(gempa: hasil[i]),
                ],
              ],
            ),
          ),
        const SizedBox(height: 12),
        const SumberBmkg(),
      ],
    );
  }
}
