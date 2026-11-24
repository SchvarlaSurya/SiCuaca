import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import 'app_chrome.dart';
import 'pencet_lembut.dart';

/// Widget status bersama untuk semua layar data: memuat (kerangka),
/// gagal, kosong, dan banner offline.

/// Bentuk kerangka saat memuat.
enum BentukKerangka {
  /// Kartu utama: judul, angka besar, dua tile.
  kartu,

  /// Daftar: beberapa baris dengan kotak di kiri.
  daftar,

  /// Satu baris ringkas.
  baris,
}

/// Kerangka abu-abu statis (tanpa animasi, aman untuk "kurangi gerakan")
/// dengan [pesan] sebagai keterangan dan label aksesibilitas.
class MemuatData extends StatelessWidget {
  const MemuatData({
    super.key,
    required this.pesan,
    this.bentuk = BentukKerangka.baris,
  });

  final String pesan;
  final BentukKerangka bentuk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blok = switch (bentuk) {
      BentukKerangka.kartu => const _KerangkaKartu(),
      BentukKerangka.daftar => const _KerangkaDaftar(),
      BentukKerangka.baris => const _KerangkaBaris(),
    };
    return Semantics(
      liveRegion: true,
      label: pesan,
      child: ExcludeSemantics(
        child: MasukLembut(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              blok,
              const SizedBox(height: 12),
              Text(
                pesan,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blok extends StatelessWidget {
  const _Blok({this.lebar, required this.tinggi, this.radius = 8});

  final double? lebar;
  final double tinggi;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lebar,
      height: tinggi,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _KerangkaKartu extends StatelessWidget {
  const _KerangkaKartu();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Blok(lebar: 140, tinggi: 18),
        SizedBox(height: 8),
        _Blok(lebar: 200, tinggi: 12),
        SizedBox(height: 16),
        _Blok(lebar: 120, tinggi: 64, radius: 12),
        SizedBox(height: 12),
        _Blok(lebar: 160, tinggi: 16),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _Blok(tinggi: 56, radius: AppTheme.radiusTile)),
            SizedBox(width: 8),
            Expanded(child: _Blok(tinggi: 56, radius: AppTheme.radiusTile)),
          ],
        ),
      ],
    );
  }
}

class _KerangkaBaris extends StatelessWidget {
  const _KerangkaBaris();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _Blok(lebar: 64, tinggi: 56, radius: 12),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Blok(tinggi: 14),
              SizedBox(height: 8),
              _Blok(lebar: 140, tinggi: 12),
              SizedBox(height: 8),
              _Blok(lebar: 90, tinggi: 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _KerangkaDaftar extends StatelessWidget {
  const _KerangkaDaftar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
      ),
      child: Column(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            const _KerangkaBaris(),
          ],
        ],
      ),
    );
  }
}

/// Keadaan gagal: ikon, pesan, tombol "Coba lagi", dan aksi tambahan.
class GagalMuat extends StatelessWidget {
  const GagalMuat({
    super.key,
    required this.pesan,
    required this.onCobaLagi,
    this.aksiTambahan,
    this.ikon = IkonApp.offline,
  });

  final String pesan;
  final VoidCallback onCobaLagi;
  final Widget? aksiTambahan;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: IkonDuo(ikon, color: scheme.onErrorContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(pesan, style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PencetLembut(
              child: FilledButton.icon(
                onPressed: onCobaLagi,
                icon: const IkonDuo(IkonApp.muatUlang),
                label: Text(context.l10n.cobaLagi),
              ),
            ),
            ?aksiTambahan,
          ],
        ),
      ],
    );
  }
}

class KosongData extends StatelessWidget {
  const KosongData({super.key, required this.pesan, this.rataTengah = true});

  final String pesan;
  final bool rataTengah;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final warna = theme.colorScheme.onSurfaceVariant;
    final teks = Text(
      pesan,
      textAlign: rataTengah ? TextAlign.center : TextAlign.start,
      style: theme.textTheme.bodyMedium?.copyWith(color: warna),
    );
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
      ),
      child: rataTengah
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IkonDuo(IkonApp.kosong, color: warna, size: 32),
                const SizedBox(height: 8),
                teks,
              ],
            )
          : teks,
    );
  }
}

/// Banner "Mode offline" + "Data terakhir diperbarui (waktu)".
class BannerOffline extends StatelessWidget {
  const BannerOffline({super.key, required this.diperbarui});

  final DateTime? diperbarui;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final waktu = diperbarui;
    final warna = scheme.onTertiaryContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusTile),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IkonDuo(IkonApp.offline, size: 20, color: warna),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.modeOffline,
                  style: theme.textTheme.labelLarge?.copyWith(color: warna),
                ),
                if (waktu != null)
                  Text(
                    l.dataTerakhir(Format.waktuSingkat(l, waktu)),
                    style: theme.textTheme.bodySmall?.copyWith(color: warna),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label kecil "Diperbarui: (waktu)".
class LabelDiperbarui extends StatelessWidget {
  const LabelDiperbarui({super.key, required this.waktu});

  final DateTime? waktu;

  @override
  Widget build(BuildContext context) {
    final w = waktu;
    if (w == null) return const SizedBox.shrink();
    final l = context.l10n;
    final theme = Theme.of(context);
    return Text(
      l.diperbarui(Format.waktuSingkat(l, w)),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Judul bagian dengan tautan "Selengkapnya" opsional.
class JudulBagian extends StatelessWidget {
  const JudulBagian(this.teks, {super.key, this.onSelengkapnya});

  final String teks;
  final VoidCallback? onSelengkapnya;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aksi = onSelengkapnya;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(teks, style: theme.textTheme.titleMedium),
            ),
          ),
          if (aksi != null)
            TextButton(
              onPressed: aksi,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.only(left: 12, right: 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.selengkapnya),
                  const IkonDuo(IkonApp.selengkapnya, size: 20),
                ],
              ),
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// Tile metrik kecil: ikon, label, nilai.
class TileInfo extends StatelessWidget {
  const TileInfo({
    super.key,
    required this.ikon,
    required this.label,
    required this.nilai,
  });

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusTile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IkonDuo(ikon, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nilai.isEmpty ? Format.tandaKosong : nilai,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// Kisi tile 2 kolom. Turun jadi 1 kolom bila lebar tiap tile tidak
/// cukup untuk skala huruf saat ini (mis. layar 360 dp + huruf 1,3×).
class KisiTile extends StatelessWidget {
  const KisiTile({super.key, required this.children});

  final List<Widget> children;

  /// Lebar minimum satu tile pada skala huruf 1,0.
  static const double lebarMinimum = 150;
  static const double jarak = 8;

  static int kolom(double lebar, double skalaHuruf) =>
      lebar >= 2 * lebarMinimum * skalaHuruf + jarak ? 2 : 1;

  @override
  Widget build(BuildContext context) {
    final skala = MediaQuery.textScalerOf(context).scale(14) / 14;
    return LayoutBuilder(
      builder: (context, batas) {
        final n = kolom(batas.maxWidth, skala);
        final baris = <Widget>[];
        for (var i = 0; i < children.length; i += n) {
          final isi = children.sublist(i, (i + n).clamp(0, children.length));
          baris.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < n; j++) ...[
                    if (j > 0) const SizedBox(width: jarak),
                    Expanded(child: j < isi.length ? isi[j] : const SizedBox()),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < baris.length; i++) ...[
              if (i > 0) const SizedBox(height: jarak),
              baris[i],
            ],
          ],
        );
      },
    );
  }
}
