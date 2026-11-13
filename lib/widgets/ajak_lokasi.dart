import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../providers/lokasi_provider.dart';
import '../providers/weather_provider.dart';

/// Ajakan mengaktifkan lokasi agar jarak gempa bisa dihitung. Bila deteksi
/// lokasi gagal, pesan kegagalannya yang ditampilkan.
class AjakLokasi extends StatelessWidget {
  const AjakLokasi({super.key});

  @override
  Widget build(BuildContext context) {
    final lokasi = context.watch<LokasiProvider>();
    final scheme = Theme.of(context).colorScheme;
    final perluPengaturan =
        lokasi.status == StatusLokasi.ditolakPermanen ||
        lokasi.status == StatusLokasi.layananMati;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_searching,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lokasi.pesan ?? Str.jarakAjak,
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: lokasi.sedangMencari
                    ? null
                    : context.read<WeatherProvider>().pakaiLokasiGps,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text(Str.gunakanLokasiSaya),
              ),
              if (perluPengaturan)
                TextButton(
                  onPressed: lokasi.bukaPengaturan,
                  child: Text(
                    lokasi.status == StatusLokasi.layananMati
                        ? Str.bukaPengaturanLokasi
                        : Str.bukaPengaturanAplikasi,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
