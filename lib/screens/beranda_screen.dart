import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/navigasi.dart';
import '../models/ambang_gempa.dart';
import '../providers/gempa_provider.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/aksi_wilayah.dart';
import '../widgets/cuaca_saat_ini_card.dart';
import '../widgets/gempa_terbaru_card.dart';
import '../widgets/lokasi_banner.dart';
import '../widgets/status_data.dart';
import '../widgets/app_chrome.dart';

/// Beranda: tiga bagian berjudul (cuaca, gempa, peringatan), masing-masing
/// dengan tautan "Selengkapnya" ke tabnya. Informasi utama: suhu.
class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cuaca = context.watch<WeatherProvider>();
    final gempa = context.watch<GempaProvider>();

    // Banner offline bila salah satu bagian menampilkan data tersimpan.
    final waktuCache = [
      if (cuaca.status == StatusCuaca.berhasil && cuaca.dariCache)
        cuaca.diperbarui,
      if (gempa.terbaru.dariCache) gempa.terbaru.diperbarui,
    ].whereType<DateTime>().toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.appName),
            Text(
              l.subjudulBeranda,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: const [AksiWilayah()],
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: RefreshIndicator(
          onRefresh: () =>
              Future.wait([cuaca.muatUlang(), gempa.muatTerbaru()]),
          // Isi Beranda pendek (tiga bagian), jadi semuanya dibangun sekaligus.
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (waktuCache.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  BannerOffline(diperbarui: waktuCache.first),
                ],
                const SizedBox(height: 8),
                const LokasiBanner(),
                MasukLembut(
                  child: JudulBagian(
                    l.cuacaSaatIni,
                    onSelengkapnya: () => Navigasi.bukaTab(TabUtama.cuaca),
                  ),
                ),
                const MasukLembut(
                  delay: Duration(milliseconds: 70),
                  child: CuacaSaatIniCard(),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 4),
                const SizedBox(height: 8),
                MasukLembut(
                  child: JudulBagian(
                    l.gempaTerbaruJudul,
                    onSelengkapnya: () => Navigasi.bukaTab(TabUtama.gempa),
                  ),
                ),
                const MasukLembut(
                  delay: Duration(milliseconds: 120),
                  child: GempaTerbaruCard(),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 4),
                const SizedBox(height: 8),
                MasukLembut(
                  child: JudulBagian(
                    l.navPeringatan,
                    onSelengkapnya: Navigasi.bukaPeringatan,
                  ),
                ),
                const MasukLembut(
                  delay: Duration(milliseconds: 160),
                  child: _RingkasPeringatan(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status notifikasi gempa saat ini (pengaturan yang sudah ada).
class _RingkasPeringatan extends StatelessWidget {
  const _RingkasPeringatan();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final ambang = context.select<NotifikasiProvider, AmbangGempa>(
      (n) => n.ambang,
    );
    final status = switch (ambang) {
      AmbangGempa.mati => l.notifMati,
      AmbangGempa.m4 => l.notifM4,
      AmbangGempa.m5 => l.notifM5,
      AmbangGempa.m6 => l.notifM6,
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: IkonDuo(
          ambang == AmbangGempa.mati ? IkonApp.notifMati : IkonApp.notifAktif,
        ),
        title: Text(l.notifJudul),
        subtitle: Text(status),
        trailing: const IkonDuo(IkonApp.selengkapnya),
        onTap: Navigasi.bukaPeringatan,
      ),
    );
  }
}
