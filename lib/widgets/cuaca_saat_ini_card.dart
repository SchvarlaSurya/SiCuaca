import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/strings.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../providers/weather_provider.dart';
import 'ikon_cuaca.dart';
import 'status_cuaca_view.dart';
import 'sumber_bmkg.dart';
import 'tombol_favorit.dart';

/// Kartu Beranda: cuaca pada jam prakiraan terdekat dengan sekarang.
class CuacaSaatIniCard extends StatelessWidget {
  const CuacaSaatIniCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cuaca = context.watch<WeatherProvider>();
    final prakiraan = cuaca.prakiraan;
    final wilayah = cuaca.wilayah;
    final entri = prakiraan?.entriTerdekat(DateTime.now());

    final tampilData =
        cuaca.status == StatusCuaca.berhasil &&
        prakiraan != null &&
        wilayah != null &&
        entri != null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: tampilData
            ? _Isi(wilayah: wilayah, prakiraan: prakiraan, entri: entri)
            : const StatusCuacaView(),
      ),
    );
  }
}

class _Isi extends StatelessWidget {
  const _Isi({
    required this.wilayah,
    required this.prakiraan,
    required this.entri,
  });

  final Lokasi wilayah;
  final Prakiraan prakiraan;
  final EntriPrakiraan entri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Str.cuacaSaatIni, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 2),
                  Text(wilayah.desa, style: theme.textTheme.titleLarge),
                  Text(wilayah.labelInduk, style: redup),
                ],
              ),
            ),
            TombolFavorit(lokasi: wilayah),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IkonCuaca(deskripsi: entri.deskripsi, malam: entri.malam, size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Format.suhu(entri.suhu),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entri.deskripsi.isEmpty ? Str.tandaKosong : entri.deskripsi,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Detail(
          ikon: Icons.water_drop_outlined,
          label: Str.kelembapan,
          nilai: Format.persen(entri.kelembapan),
        ),
        const SizedBox(height: 8),
        _Detail(
          ikon: Icons.air,
          label: Str.angin,
          nilai: Format.angin(entri.kecepatanAngin, entri.arahAngin),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                Str.pukul(
                  Format.jam(entri.waktuLokal),
                  Format.zona(prakiraan.selisihZona),
                ),
                style: redup,
              ),
            ),
            const SumberBmkg(),
          ],
        ),
      ],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.ikon, required this.label, required this.nilai});

  final IconData ikon;
  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(ikon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
