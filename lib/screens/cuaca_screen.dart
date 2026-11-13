import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/l10n.dart';
import '../models/prakiraan.dart';
import '../providers/weather_provider.dart';
import '../widgets/aksi_wilayah.dart';
import '../widgets/ikon_cuaca.dart';
import '../widgets/lokasi_banner.dart';
import '../widgets/status_cuaca_view.dart';
import '../widgets/status_data.dart';
import '../widgets/tombol_favorit.dart';

/// Prakiraan per hari (satu tab per tanggal), entri tiap 3 jam.
class CuacaScreen extends StatelessWidget {
  const CuacaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cuaca = context.watch<WeatherProvider>();
    final prakiraan = cuaca.prakiraan;
    final wilayah = cuaca.wilayah;
    final berhasil =
        cuaca.status == StatusCuaca.berhasil &&
        prakiraan != null &&
        wilayah != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(berhasil ? wilayah.desa : context.l10n.navCuaca),
        actions: [
          if (berhasil) TombolFavorit(lokasi: wilayah),
          const AksiWilayah(),
        ],
      ),
      body: berhasil
          ? _Prakiraan(
              prakiraan: prakiraan,
              subjudul: wilayah.labelInduk,
              diperbarui: cuaca.diperbarui,
              dariCache: cuaca.dariCache,
              onMuatUlang: cuaca.muatUlang,
            )
          : RefreshIndicator(
              onRefresh: cuaca.muatUlang,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: const [LokasiBanner(), StatusCuacaView()],
              ),
            ),
    );
  }
}

class _Prakiraan extends StatelessWidget {
  const _Prakiraan({
    required this.prakiraan,
    required this.subjudul,
    required this.diperbarui,
    required this.dariCache,
    required this.onMuatUlang,
  });

  final Prakiraan prakiraan;
  final String subjudul;
  final DateTime? diperbarui;
  final bool dariCache;
  final Future<void> Function() onMuatUlang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    if (prakiraan.kosong) {
      return Center(child: KosongData(pesan: l.tidakAdaPrakiraan));
    }

    final selisih = prakiraan.selisihZona ?? Duration.zero;
    final hariIni = DateTime.now().toUtc().add(selisih);
    final zona = Format.zona(prakiraan.selisihZona);

    return DefaultTabController(
      // Kunci baru saat data berganti, agar jumlah tab ikut diperbarui.
      key: ObjectKey(prakiraan),
      length: prakiraan.hari.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              subjudul,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (dariCache)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BannerOffline(diperbarui: diperbarui),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: LokasiBanner(),
          ),
          TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final h in prakiraan.hari)
                Tab(text: Format.labelHari(l, h.first.waktuLokal, hariIni)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final h in prakiraan.hari)
                  RefreshIndicator(
                    onRefresh: onMuatUlang,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: h.length + 1,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, i) => i < h.length
                          ? _BarisEntri(entri: h[i])
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${l.waktuSetempat}'
                                    '${zona.isEmpty ? '' : ' ($zona)'} · '
                                    '${l.sumberBmkg}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  LabelDiperbarui(waktu: diperbarui),
                                ],
                              ),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisEntri extends StatelessWidget {
  const _BarisEntri({required this.entri});

  final EntriPrakiraan entri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              Format.jam(entri.waktuLokal),
              style: theme.textTheme.titleSmall,
            ),
          ),
          IkonCuaca(deskripsi: entri.deskripsi, malam: entri.malam, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.deskripsiCuaca(entri).isEmpty
                      ? Format.tandaKosong
                      : context.l10n.deskripsiCuaca(entri),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 12,
                  children: [
                    _Info(
                      ikon: Icons.water_drop_outlined,
                      teks: Format.persen(entri.kelembapan),
                      gaya: redup,
                    ),
                    _Info(
                      ikon: Icons.air,
                      teks: Format.angin(
                        context.l10n,
                        entri.kecepatanAngin,
                        entri.arahAngin,
                      ),
                      gaya: redup,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(Format.suhu(entri.suhu), style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.ikon, required this.teks, this.gaya});

  final IconData ikon;
  final String teks;
  final TextStyle? gaya;

  @override
  Widget build(BuildContext context) {
    // Flexible: teks panjang (mis. arah angin, huruf besar) turun baris,
    // tidak meluap.
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, size: 14, color: gaya?.color),
        const SizedBox(width: 3),
        Flexible(child: Text(teks, style: gaya)),
      ],
    );
  }
}
