import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
import '../widgets/app_chrome.dart';
import 'perbandingan_cuaca_screen.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.navCuaca),
            Text(
              context.l10n.subjudulCuaca,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.bandingkanFavorit,
            icon: const Icon(IkonApp.bandingkan),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PerbandinganCuacaScreen(),
              ),
            ),
          ),
          if (berhasil) TombolFavorit(lokasi: wilayah),
          if (berhasil)
            IconButton(
              tooltip: context.l10n.bagikanCuaca,
              icon: const Icon(IkonApp.bagikan),
              onPressed: () => _bukaKartuCuaca(
                context,
                wilayah,
                prakiraan.entriTerdekat(DateTime.now()),
                cuaca.diperbarui,
                cuaca.dariCache,
              ),
            ),
          const AksiWilayah(),
        ],
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: berhasil
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
      ),
    );
  }
}

void _bukaKartuCuaca(
  BuildContext context,
  Lokasi lokasi,
  EntriPrakiraan? entri,
  DateTime? diperbarui,
  bool dariCache,
) {
  if (entri == null) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => KartuCuacaScreen(
        lokasi: lokasi,
        entri: entri,
        diperbarui: diperbarui,
        dariCache: dariCache,
      ),
    ),
  );
}

class KartuCuacaScreen extends StatelessWidget {
  KartuCuacaScreen({
    super.key,
    required this.lokasi,
    required this.entri,
    this.diperbarui,
    required this.dariCache,
  });
  final Lokasi lokasi;
  final EntriPrakiraan entri;
  final DateTime? diperbarui;
  final bool dariCache;
  final GlobalKey _kunciKartu = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final teks = l.ringkasanCuaca(
      lokasi.labelLengkap,
      l.deskripsiCuaca(entri),
      Format.suhu(entri.suhu),
      dariCache ? '${l.modeOffline} ' : '',
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.kartuCuaca)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RepaintBoundary(
            key: _kunciKartu,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF302080), Color(0xFF6B56DC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SiCuaca · ${lokasi.labelLengkap}',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      Format.suhu(entri.suhu),
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(color: Colors.white),
                    ),
                    Text(
                      l.deskripsiCuaca(entri),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: const Color(0xFFE5E0FF)),
                    ),
                    const SizedBox(height: 24),
                    if (dariCache)
                      Text(
                        l.modeOffline,
                        style: const TextStyle(color: Color(0xFFE5E0FF)),
                      ),
                    if (diperbarui != null)
                      Text(
                        l.diperbarui(Format.waktuLengkap(l, diperbarui)),
                        style: const TextStyle(color: Color(0xFFE5E0FF)),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      '${l.sumberBmkg}. ${l.bukanResmi}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE5E0FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(IkonApp.bagikan),
            label: Text(l.bagikanKartuCuaca),
            onPressed: () => _bagikan(context, teks),
          ),
          TextButton.icon(
            icon: const Icon(IkonApp.salin),
            label: Text(l.salinRingkasanTeks),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: teks));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.ringkasanCuacaDisalin)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _bagikan(BuildContext context, String teks) async {
    try {
      final boundary =
          _kunciKartu.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Kartu belum siap dirender');
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Gambar kartu tidak dapat dibuat');
      final file = XFile.fromData(
        bytes.buffer.asUint8List(),
        mimeType: 'image/png',
        name: 'sicuaca-cuaca.png',
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [file],
          text: teks,
          fileNameOverrides: const ['sicuaca-cuaca.png'],
        ),
      );
    } catch (_) {
      await SharePlus.instance.share(ShareParams(text: teks));
    }
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
                MasukLembut(
                  child: HeroCuaca(
                    wilayah: wilayah,
                    entri: terdekat,
                    selisihZona: prakiraan.selisihZona,
                  ),
                ),
                const SizedBox(height: 8),
                MasukLembut(
                  delay: const Duration(milliseconds: 70),
                  child: KisiTile(children: tileCuaca(context, terdekat)),
                ),
                const SizedBox(height: 16),
                MasukLembut(
                  delay: const Duration(milliseconds: 120),
                  child: JudulBagian(l.prakiraanPer3Jam),
                ),
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
                    return MasukLembut(
                      delay: const Duration(milliseconds: 160),
                      child: Card(
                        child: Column(
                          children: [
                            for (var i = 0; i < hari.length; i++) ...[
                              if (i > 0)
                                const Divider(indent: 16, endIndent: 16),
                              _BarisEntri(entri: hari[i]),
                            ],
                          ],
                        ),
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
