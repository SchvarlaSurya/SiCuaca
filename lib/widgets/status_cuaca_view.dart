import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';
import '../screens/pencarian_screen.dart';

/// Tampilan untuk status cuaca selain "berhasil": belum ada wilayah,
/// loading, atau error. Dipakai di Beranda dan tab Cuaca.
class StatusCuacaView extends StatelessWidget {
  const StatusCuacaView({super.key});

  @override
  Widget build(BuildContext context) {
    final cuaca = context.watch<WeatherProvider>();
    final mencariGps = context.watch<LokasiProvider>().sedangMencari;

    if (mencariGps) return const _Memuat(teks: Str.mencariLokasi);

    return switch (cuaca.status) {
      StatusCuaca.loading => const _Memuat(teks: Str.memuatCuaca),
      StatusCuaca.error => _Error(
        pesan: cuaca.pesanError ?? Str.errTakTerduga,
        onCobaLagi: cuaca.muatUlang,
      ),
      StatusCuaca.belumAdaWilayah ||
      StatusCuaca.berhasil => const _PilihWilayah(),
    };
  }
}

class _Memuat extends StatelessWidget {
  const _Memuat({required this.teks});

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 12),
          Flexible(child: Text(teks)),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.cloud_off, color: scheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pesan,
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onCobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text(Str.cobaLagi),
            ),
            OutlinedButton(
              onPressed: () => bukaPencarian(context),
              child: const Text(Str.gantiWilayah),
            ),
          ],
        ),
      ],
    );
  }
}

class _PilihWilayah extends StatelessWidget {
  const _PilihWilayah();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Str.pilihWilayahJudul, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          Str.pilihWilayahKeterangan,
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
              label: const Text(Str.gunakanLokasiSaya),
            ),
            OutlinedButton.icon(
              onPressed: () => bukaPencarian(context),
              icon: const Icon(Icons.search),
              label: const Text(Str.cariWilayah),
            ),
          ],
        ),
      ],
    );
  }
}
