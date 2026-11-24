import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../models/prakiraan.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/pencarian_screen.dart';
import 'status_data.dart';
import 'pencet_lembut.dart';

/// Tampilan untuk status cuaca selain "berhasil": belum ada wilayah,
/// loading, atau error. Dipakai di Beranda dan tab Cuaca.
class StatusCuacaView extends StatelessWidget {
  const StatusCuacaView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cuaca = context.watch<WeatherProvider>();
    final mencariGps = context.watch<LokasiProvider>().sedangMencari;

    if (mencariGps) {
      return MemuatData(pesan: l.mencariLokasi, bentuk: BentukKerangka.kartu);
    }

    return switch (cuaca.status) {
      StatusCuaca.loading => MemuatData(
        pesan: l.memuatCuaca,
        bentuk: BentukKerangka.kartu,
      ),
      StatusCuaca.error => GagalMuat(
        pesan: l.pesanGalat(cuaca.galat),
        onCobaLagi: cuaca.muatUlang,
        aksiTambahan: PencetLembut(
          child: OutlinedButton(
            onPressed: () => bukaPencarian(context),
            child: Text(l.gantiWilayah),
          ),
        ),
      ),
      StatusCuaca.belumAdaWilayah ||
      StatusCuaca.berhasil => const _PilihWilayah(),
    };
  }
}

class _PilihWilayah extends StatelessWidget {
  const _PilihWilayah();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.pilihWilayahJudul, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          l.pilihWilayahKeterangan,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PencetLembut(
              child: FilledButton.icon(
                onPressed: context.read<WeatherProvider>().pakaiLokasiGps,
                icon: const IkonDuo(IkonApp.lokasiSaya),
                label: Text(l.gunakanLokasiSaya),
              ),
            ),
            PencetLembut(
              child: OutlinedButton.icon(
                onPressed: () => bukaPencarian(context),
                icon: const IkonDuo(IkonApp.cari),
                label: Text(l.cariWilayah),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// True bila prakiraan memang untuk [wilayah] dan berisi data. Bila tidak,
/// layar menampilkan [DataTidakTersedia], bukan data wilayah lain.
bool prakiraanCocok(Prakiraan prakiraan, Lokasi wilayah) {
  final kode = prakiraan.lokasi.adm4;
  return !prakiraan.kosong && (kode.isEmpty || kode == wilayah.adm4);
}

/// "Data tidak tersedia untuk lokasi ini" + tombol ganti wilayah.
class DataTidakTersedia extends StatelessWidget {
  const DataTidakTersedia({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IkonDuo(IkonApp.kosong, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.dataTidakTersedia,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PencetLembut(
          child: OutlinedButton.icon(
            onPressed: () => bukaPencarian(context),
            icon: const IkonDuo(IkonApp.cari),
            label: Text(l.gantiWilayah),
          ),
        ),
      ],
    );
  }
}
