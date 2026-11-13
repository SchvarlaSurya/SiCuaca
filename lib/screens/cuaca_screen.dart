import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../providers/weather_provider.dart';
import '../widgets/aksi_wilayah.dart';
import '../widgets/hero_cuaca.dart';
import '../widgets/ikon_cuaca.dart';
import '../widgets/lokasi_banner.dart';
import '../widgets/status_cuaca_view.dart';
import '../widgets/status_data.dart';
import '../widgets/tombol_favorit.dart';

/// Prakiraan cuaca: kartu hero (jam terdekat), lalu prakiraan per 3 jam
/// dengan satu tab per tanggal. Semuanya satu daftar gulir, sehingga tarik
/// untuk memuat ulang bekerja di mana saja.
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
        title: Text(context.l10n.navCuaca),
        actions: [
          if (berhasil) TombolFavorit(lokasi: wilayah),
          const AksiWilayah(),
        ],
      ),
      body: berhasil
          ? _Prakiraan(
              prakiraan: prakiraan,
              wilayah: wilayah,
              diperbarui: cuaca.diperbarui,
              dariCache: cuaca.dariCache,
              onMuatUlang: cuaca.muatUlang,
            )
          : RefreshIndicator(
              onRefresh: cuaca.muatUlang,
              // Kartu status di tengah layar agar tidak tampak kosong.
              child: LayoutBuilder(
                builder: (context, batas) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (batas.maxHeight - 32).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LokasiBanner(),
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: StatusCuacaView(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _Prakiraan extends StatelessWidget {
  const _Prakiraan({
    required this.prakiraan,
    required this.wilayah,
    required this.diperbarui,
    required this.dariCache,
    required this.onMuatUlang,
  });

  final Prakiraan prakiraan;
  final Lokasi wilayah;
  final DateTime? diperbarui;
  final bool dariCache;
  final Future<void> Function() onMuatUlang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final terdekat = prakiraan.entriTerdekat(DateTime.now());

    final kepala = <Widget>[
      if (dariCache) ...[
        BannerOffline(diperbarui: diperbarui),
        const SizedBox(height: 8),
      ],
      const LokasiBanner(),
    ];

    if (terdekat == null || !prakiraanCocok(prakiraan, wilayah)) {
      return RefreshIndicator(
        onRefresh: onMuatUlang,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            ...kepala,
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: DataTidakTersedia(),
              ),
            ),
          ],
        ),
      );
    }

    final selisih = prakiraan.selisihZona ?? Duration.zero;
    final hariIni = DateTime.now().toUtc().add(selisih);
    final zona = Format.zona(prakiraan.selisihZona);

    return DefaultTabController(
      // Kunci baru saat data berganti, agar jumlah tab ikut diperbarui.
      key: ObjectKey(prakiraan),
      length: prakiraan.hari.length,
      child: Builder(
        builder: (context) {
          final tab = DefaultTabController.of(context);
          return RefreshIndicator(
            onRefresh: onMuatUlang,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                ...kepala,
                HeroCuaca(
                  wilayah: wilayah,
                  entri: terdekat,
                  selisihZona: prakiraan.selisihZona,
                ),
                const SizedBox(height: 8),
                KisiTile(children: tileCuaca(context, terdekat)),
                const SizedBox(height: 16),
                JudulBagian(l.prakiraanPer3Jam),
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final h in prakiraan.hari)
                      Tab(
                        text: Format.labelHari(l, h.first.waktuLokal, hariIni),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: tab,
                  builder: (context, _) {
                    final hari = prakiraan.hari[tab.index];
                    return Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < hari.length; i++) ...[
                            if (i > 0) const Divider(indent: 16, endIndent: 16),
                            _BarisEntri(entri: hari[i]),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  '${l.waktuSetempat}'
                  '${zona.isEmpty ? '' : ' ($zona)'} · '
                  '${l.sumberBmkg}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                LabelDiperbarui(waktu: diperbarui),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BarisEntri extends StatelessWidget {
  const _BarisEntri({required this.entri});

  final EntriPrakiraan entri;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final skala = MediaQuery.textScalerOf(context).scale(16) / 16;
    final deskripsi = l.deskripsiCuaca(entri);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 52 * skala,
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
                  deskripsi.isEmpty ? Format.tandaKosong : deskripsi,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 12,
                  children: [
                    _Info(
                      ikon: IkonApp.kelembapan,
                      teks: Format.persen(entri.kelembapan),
                      gaya: redup,
                    ),
                    _Info(
                      ikon: IkonApp.angin,
                      teks: Format.angin(
                        l,
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
