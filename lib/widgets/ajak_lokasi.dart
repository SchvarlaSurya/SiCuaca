import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IkonDuo(IkonApp.lokasiCari, color: scheme.onSecondaryContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.pesanLokasi(lokasi.status) ??
                      context.l10n.jarakAjak,
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
                icon: const IkonDuo(IkonApp.lokasiSaya, size: 18),
                label: Text(context.l10n.gunakanLokasiSaya),
              ),
              if (perluPengaturan)
                TextButton(
                  onPressed: lokasi.bukaPengaturan,
                  child: Text(
                    lokasi.status == StatusLokasi.layananMati
                        ? context.l10n.bukaPengaturanLokasi
                        : context.l10n.bukaPengaturanAplikasi,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
