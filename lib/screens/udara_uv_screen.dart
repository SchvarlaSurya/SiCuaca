import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../models/prakiraan.dart';
import '../providers/kualitas_udara_provider.dart';
import '../widgets/app_chrome.dart';
import '../widgets/kartu_uv_udara.dart';

/// Halaman Udara dan UV, terpisah dari layar Cuaca: indeks UV (perkiraan
/// SiCuaca dari posisi matahari dan tutupan awan BMKG) dan kualitas udara
/// (Open-Meteo, model CAMS). Tiap kartu memuat label sumbernya sendiri, dan
/// halaman menyebut data apa yang dikirim ke layanan luar.
class UdaraUvScreen extends StatelessWidget {
  const UdaraUvScreen({super.key, required this.prakiraan, this.jam});

  final Prakiraan prakiraan;

  /// Waktu sekarang (UTC); bisa diganti saat pengujian.
  final DateTime Function()? jam;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final lokasi = prakiraan.lokasi;
    final lat = lokasi.lat;
    final lon = lokasi.lon;
    final selisih = prakiraan.selisihZona ?? Duration.zero;
    final sekarangUtc = (jam ?? () => DateTime.now().toUtc())();
    final terdekat = prakiraan.entriTerdekat(sekarangUtc);

    return Scaffold(
      appBar: AppBar(title: Text(l.udaraUvJudul)),
      body: LatarAtmosfer(
        gelap: false,
        child: RefreshIndicator(
          onRefresh: () async {
            if (lat != null && lon != null) {
              await context.read<KualitasUdaraProvider>().muat(
                lat,
                lon,
                paksa: true,
              );
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              if (lokasi.labelLengkap.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    lokasi.labelLengkap,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (lat == null || lon == null || terdekat == null)
                Text(l.udaraUvTanpaKoordinat, style: theme.textTheme.bodyMedium)
              else ...[
                MasukLembut(
                  child: KartuUv(
                    lat: lat,
                    lon: lon,
                    prakiraan: prakiraan,
                    terdekat: terdekat,
                    hariSetempat: sekarangUtc.add(selisih),
                    selisih: selisih,
                  ),
                ),
                const SizedBox(height: 12),
                MasukLembut(
                  delay: const Duration(milliseconds: 60),
                  child: KartuUdara(lat: lat, lon: lon),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                l.udaraPrivasi,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.bukanResmi,
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
