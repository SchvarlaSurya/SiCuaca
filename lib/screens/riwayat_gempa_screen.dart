import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/gempa_item.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/app_chrome.dart';

/// Riwayat gempa yang pernah dimuat, termasuk saat aplikasi sedang offline.
class RiwayatGempaScreen extends StatelessWidget {
  const RiwayatGempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    final daftar = provider.riwayat;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.riwayatJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: daftar.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    context.l10n.riwayatKosong,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : _IsiRiwayat(daftar: daftar),
      ),
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.read<GempaProvider>();
    final hasil = widget.daftar.where((gempa) {
      if (_query.isNotEmpty &&
          !gempa.wilayah.toLowerCase().contains(_query.trim().toLowerCase())) {
        return false;
      }
      final mag = gempa.magnitudoAngka;
      if (_minimum != null && (mag == null || mag < _minimum!)) return false;
      if (_hanyaDekat &&
          provider.jarakKm(gempa) != null &&
          provider.jarakKm(gempa)! > 100) {
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
    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: MasukLembut(
            child: Text(
              l.jejakAktivitas,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        MasukLembut(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(IkonApp.cari),
                hintText: l.cariWilayahGempa,
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.hapusPencarian,
                        icon: const Icon(IkonApp.hapus),
                        onPressed: () => setState(() => _query = ''),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),
        MasukLembut(
          delay: const Duration(milliseconds: 80),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text(l.riwayatJumlah(hasil.length))),
                PopupMenuButton<String>(
                  tooltip: l.rentangGrafik,
                  icon: const Icon(IkonApp.grafik),
                  onSelected: (value) =>
                      _bukaGrafik(context, widget.daftar, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'hari', child: Text(l.grafikPerHari)),
                    PopupMenuItem(
                      value: 'minggu',
                      child: Text(l.grafikPerMinggu),
                    ),
                  ],
                ),
                PopupMenuButton<double?>(
                  tooltip: l.saringMagnitudo,
                  icon: const Icon(IkonApp.saring),
                  onSelected: (value) => setState(() => _minimum = value),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: null, child: Text(l.semuaMagnitudo)),
                    for (final m in const [4.0, 5.0, 6.0])
                      PopupMenuItem(
                        value: m,
                        child: Text(l.minimalMagnitudo(m.toStringAsFixed(1))),
                      ),
                  ],
                ),
                IconButton(
                  tooltip: l.gempaDalam100Km,
                  isSelected: _hanyaDekat,
                  icon: Icon(
                    IkonApp.jarak,
                    color: _hanyaDekat
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  onPressed: () => setState(() => _hanyaDekat = !_hanyaDekat),
                ),
              ],
            ),
          ),
        ),
        MasukLembut(
          delay: const Duration(milliseconds: 140),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _Statistik(
                  label: l.statTerbesar,
                  value: terbesar == null
                      ? Format.tandaKosong
                      : 'M${Format.desimal(l, terbesar)}',
                ),
                const SizedBox(width: 8),
                _Statistik(
                  label: l.statTerdekat,
                  value: terdekat == null
                      ? Format.tandaKosong
                      : '${Format.jarak(l, terdekat)} km',
                ),
                const SizedBox(width: 8),
                _Statistik(label: l.statTotal, value: '${hasil.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < hasil.length; i++) ...[
          if (i > 0) const Divider(indent: 92, endIndent: 16),
          GempaItem(gempa: hasil[i]),
        ],
        if (hasil.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.riwayatTidakCocok, textAlign: TextAlign.center),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SumberBmkg(),
        ),
      ],
    );
  }
}

void _bukaGrafik(BuildContext context, List<Gempa> daftar, String mode) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) =>
          GrafikGempaScreen(daftar: daftar, mingguan: mode == 'minggu'),
    ),
  );
}

class GrafikGempaScreen extends StatelessWidget {
  const GrafikGempaScreen({
    super.key,
    required this.daftar,
    required this.mingguan,
  });
  final List<Gempa> daftar;
  final bool mingguan;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final now = DateTime.now();
    final bins = List<int>.filled(mingguan ? 5 : 7, 0);
    for (final gempa in daftar) {
      final waktu = gempa.waktuUtc?.toLocal();
      if (waktu == null) continue;
      final days = DateTime(
        now.year,
        now.month,
        now.day,
      ).difference(DateTime(waktu.year, waktu.month, waktu.day)).inDays;
      if (days < 0) continue;
      if (mingguan) {
        final index = days ~/ 7;
        if (index < bins.length) bins[bins.length - 1 - index]++;
      } else if (days < bins.length) {
        bins[bins.length - 1 - days]++;
      }
    }
    final maxValue = bins.fold<int>(0, (a, b) => a > b ? a : b);
    return Scaffold(
      appBar: AppBar(title: Text(mingguan ? l.gempaPerMinggu : l.gempaPerHari)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.grafikCatatan),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < bins.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 62,
                            child: Text(
                              mingguan
                                  ? l.mingguKe('${bins.length - i}')
                                  : DateFormat('dd/MM', l.localeName).format(
                                      DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                      ).subtract(
                                        Duration(days: bins.length - 1 - i),
                                      ),
                                    ),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          Expanded(
                            child: Semantics(
                              label: l.jumlahKejadian(bins[i]),
                              child: LinearProgressIndicator(
                                value: maxValue == 0 ? 0 : bins[i] / maxValue,
                                minHeight: 18,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 36,
                            child: Text('${bins[i]}', textAlign: TextAlign.end),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(l.totalGrafik(bins.fold<int>(0, (a, b) => a + b))),
                ],
              ),
            ),
          ),
        ],
      ),
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
