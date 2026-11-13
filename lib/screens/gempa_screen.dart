import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/gempa_item.dart';
import '../widgets/gempa_terbaru_card.dart';
import '../widgets/status_gempa.dart';
import '../widgets/sumber_bmkg.dart';

/// Tab Gempa: Terbaru, M 5.0+, Dirasakan.
class GempaScreen extends StatelessWidget {
  const GempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Str.navGempa),
          bottom: const TabBar(
            tabs: [
              Tab(text: Str.gempaTabTerbaru),
              Tab(text: Str.gempaTabTerkini),
              Tab(text: Str.gempaTabDirasakan),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_TabTerbaru(), _TabTerkini(), _TabDirasakan()],
        ),
      ),
    );
  }
}

class _TabTerbaru extends StatelessWidget {
  const _TabTerbaru();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    return RefreshIndicator(
      onRefresh: provider.muatTerbaru,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const _Keterangan(Str.gempaTerbaruKeterangan),
          const SizedBox(height: 12),
          if (!provider.adaPosisi) ...[
            const AjakLokasi(),
            const SizedBox(height: 12),
          ],
          const GempaTerbaruCard(),
        ],
      ),
    );
  }
}

class _TabTerkini extends StatelessWidget {
  const _TabTerkini();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    return _DaftarGempa(
      keadaan: provider.terkini,
      keterangan: Str.gempaTerkiniKeterangan,
      onMuatUlang: provider.muatTerkini,
    );
  }
}

class _TabDirasakan extends StatelessWidget {
  const _TabDirasakan();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GempaProvider>();
    return _DaftarGempa(
      keadaan: provider.dirasakan,
      keterangan: Str.gempaDirasakanKeterangan,
      onMuatUlang: provider.muatDirasakan,
    );
  }
}

class _DaftarGempa extends StatelessWidget {
  const _DaftarGempa({
    required this.keadaan,
    required this.keterangan,
    required this.onMuatUlang,
  });

  final KeadaanGempa<List<Gempa>> keadaan;
  final String keterangan;
  final Future<void> Function() onMuatUlang;

  @override
  Widget build(BuildContext context) {
    final adaPosisi = context.select<GempaProvider, bool>((p) => p.adaPosisi);
    final daftar = keadaan.data ?? const <Gempa>[];

    final kepala = <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: _Keterangan(keterangan),
      ),
      if (!adaPosisi)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AjakLokasi(),
        ),
    ];

    final List<Widget> isi = switch (keadaan.status) {
      StatusMuat.loading => [const MemuatGempa()],
      StatusMuat.error => [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GagalGempa(
            pesan: keadaan.pesan ?? Str.errTakTerduga,
            onCobaLagi: onMuatUlang,
          ),
        ),
      ],
      StatusMuat.berhasil when daftar.isEmpty => [const KosongGempa()],
      StatusMuat.berhasil => [
        for (var i = 0; i < daftar.length; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 84, endIndent: 16),
          GempaItem(gempa: daftar[i]),
        ],
      ],
    };

    return RefreshIndicator(
      onRefresh: onMuatUlang,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ...kepala,
          ...isi,
          const Padding(padding: EdgeInsets.all(16), child: SumberBmkg()),
        ],
      ),
    );
  }
}

class _Keterangan extends StatelessWidget {
  const _Keterangan(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      teks,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
