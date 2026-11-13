import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/pencarian_screen.dart';
import 'status_data.dart';

/// Tampilan untuk status cuaca selain "berhasil": belum ada wilayah,
/// loading, atau error. Dipakai di Beranda dan tab Cuaca.
class StatusCuacaView extends StatelessWidget {
  const StatusCuacaView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cuaca = context.watch<WeatherProvider>();
    final mencariGps = context.watch<LokasiProvider>().sedangMencari;

    if (mencariGps) return MemuatData(pesan: l.mencariLokasi);

    return switch (cuaca.status) {
      StatusCuaca.loading => MemuatData(pesan: l.memuatCuaca),
      StatusCuaca.error => GagalMuat(
        pesan: l.pesanGalat(cuaca.galat),
        onCobaLagi: cuaca.muatUlang,
        aksiTambahan: OutlinedButton(
          onPressed: () => bukaPencarian(context),
          child: Text(l.gantiWilayah),
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
            FilledButton.icon(
              onPressed: context.read<WeatherProvider>().pakaiLokasiGps,
              icon: const Icon(Icons.my_location),
              label: Text(l.gunakanLokasiSaya),
            ),
            OutlinedButton.icon(
              onPressed: () => bukaPencarian(context),
              icon: const Icon(Icons.search),
              label: Text(l.cariWilayah),
            ),
          ],
        ),
      ],
    );
  }
}
