import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../models/gempa.dart';
import '../providers/gempa_provider.dart';
import 'riwayat_gempa_screen.dart';
import 'siaga_gempa_screen.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/gempa_item.dart';
import '../widgets/gempa_terbaru_card.dart';
import '../widgets/status_data.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/app_chrome.dart';

/// Tab Gempa: Terbaru, M 5.0+, Dirasakan.
class GempaScreen extends StatelessWidget {
  const GempaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.navGempa),
              Text(
                'Informasi seismik terkini',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Siaga gempa',
              icon: const Icon(Icons.health_and_safety_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SiagaGempaScreen(),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Riwayat gempa',
              icon: const Icon(Icons.history),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RiwayatGempaScreen(),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.gempaTabTerbaru),
              Tab(text: context.l10n.gempaTabTerkini),
              Tab(text: context.l10n.gempaTabDirasakan),
            ],
          ),
        ),
        body: const LatarAtmosfer(
          gelap: false,
          child: TabBarView(
            children: [_TabTerbaru(), _TabTerkini(), _TabDirasakan()],
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const MasukLembut(child: _GempaIntro()),
          const SizedBox(height: 16),
          JudulBagian(context.l10n.gempaTerbaruJudul),
          _Keterangan(context.l10n.gempaTerbaruKeterangan),
          if (provider.terbaru.dariCache) ...[
            const SizedBox(height: 12),
            BannerOffline(diperbarui: provider.terbaru.diperbarui),
          ],
          const SizedBox(height: 12),
          if (!provider.adaPosisi) ...[
            const AjakLokasi(),
            const SizedBox(height: 12),
          ],
          const MasukLembut(
            delay: Duration(milliseconds: 80),
            child: GempaTerbaruCard(utama: true),
          ),
        ],
      ),
    );
  }
}

class _GempaIntro extends StatelessWidget {
  const _GempaIntro();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF31227F), Color(0xFF6856D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: .22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.waves_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tetap siaga, tetap tenang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pantau informasi resmi dan siapkan langkah aman.',
                  style: TextStyle(color: Color(0xFFDCD7FF), fontSize: 12),
                ),
              ],
            ),
          ),
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
      keterangan: context.l10n.gempaTerkiniKeterangan,
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
      keterangan: context.l10n.gempaDirasakanKeterangan,
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
      const SizedBox(height: 8),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: _Keterangan(keterangan),
      ),
      if (keadaan.dariCache)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: BannerOffline(diperbarui: keadaan.diperbarui),
        ),
      if (!adaPosisi)
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: AjakLokasi(),
        ),
    ];

    final List<Widget> isi = switch (keadaan.status) {
      StatusMuat.loading => [
        Padding(
          padding: const EdgeInsets.all(16),
          child: MemuatData(
            pesan: context.l10n.memuatGempa,
            bentuk: BentukKerangka.daftar,
          ),
        ),
      ],
      StatusMuat.error => [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GagalMuat(
            pesan: context.l10n.pesanGalat(keadaan.galat),
            onCobaLagi: onMuatUlang,
          ),
        ),
      ],
      StatusMuat.berhasil when daftar.isEmpty => [
        KosongData(pesan: context.l10n.gempaKosong),
      ],
      StatusMuat.berhasil => [
        for (var i = 0; i < daftar.length; i++) ...[
          if (i > 0) const Divider(indent: 92, endIndent: 16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SumberBmkg(),
                LabelDiperbarui(waktu: keadaan.diperbarui),
              ],
            ),
          ),
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
