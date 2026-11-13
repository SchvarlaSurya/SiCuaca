import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../providers/gempa_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/aksi_wilayah.dart';
import '../widgets/cuaca_saat_ini_card.dart';
import '../widgets/gempa_terbaru_card.dart';
import '../widgets/lokasi_banner.dart';
import '../widgets/status_data.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cuaca = context.watch<WeatherProvider>();
    final gempa = context.watch<GempaProvider>();

    // Banner offline bila salah satu kartu menampilkan data tersimpan.
    final waktuCache = [
      if (cuaca.status == StatusCuaca.berhasil && cuaca.dariCache)
        cuaca.diperbarui,
      if (gempa.terbaru.dariCache) gempa.terbaru.diperbarui,
    ].whereType<DateTime>().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: Text(l.appName), actions: const [AksiWilayah()]),
      body: RefreshIndicator(
        onRefresh: () => Future.wait([cuaca.muatUlang(), gempa.muatTerbaru()]),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.berandaJudul, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              l.berandaKeterangan,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (waktuCache.isNotEmpty) ...[
              BannerOffline(diperbarui: waktuCache.first),
              const SizedBox(height: 12),
            ],
            const LokasiBanner(),
            const CuacaSaatIniCard(),
            const SizedBox(height: 16),
            const GempaTerbaruCard(),
          ],
        ),
      ),
    );
  }
}
