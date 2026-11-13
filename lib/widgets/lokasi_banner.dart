import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n.dart';
import '../providers/lokasi_provider.dart';
import '../screens/pencarian_screen.dart';

/// Pesan bila deteksi lokasi gagal, beserta jalan keluarnya.
/// Tidak tampil apa-apa bila tidak ada masalah.
class LokasiBanner extends StatelessWidget {
  const LokasiBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final lokasi = context.watch<LokasiProvider>();
    final pesan = context.l10n.pesanLokasi(lokasi.status);
    if (pesan == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final perluPengaturan =
        lokasi.status == StatusLokasi.ditolakPermanen ||
        lokasi.status == StatusLokasi.layananMati;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_off, color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pesan,
                    style: TextStyle(color: scheme.onSecondaryContainer),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: lokasi.reset,
                  icon: const Icon(Icons.close),
                  color: scheme.onSecondaryContainer,
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                if (perluPengaturan)
                  TextButton(
                    onPressed: lokasi.bukaPengaturan,
                    child: Text(
                      lokasi.status == StatusLokasi.layananMati
                          ? context.l10n.bukaPengaturanLokasi
                          : context.l10n.bukaPengaturanAplikasi,
                    ),
                  ),
                TextButton(
                  onPressed: () => bukaPencarian(context),
                  child: Text(context.l10n.cariWilayah),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
