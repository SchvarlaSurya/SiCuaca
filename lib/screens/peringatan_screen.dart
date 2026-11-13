import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/strings.dart';
import '../models/ambang_gempa.dart';
import '../providers/notifikasi_provider.dart';

/// Tab Peringatan: pengaturan ambang notifikasi gempa.
class PeringatanScreen extends StatelessWidget {
  const PeringatanScreen({super.key});

  static const Map<AmbangGempa, (String, String)> _label = {
    AmbangGempa.mati: (Str.notifMati, Str.notifMatiKeterangan),
    AmbangGempa.m4: (Str.notifM4, Str.notifM4Keterangan),
    AmbangGempa.m5: (Str.notifM5, Str.notifM5Keterangan),
    AmbangGempa.m6: (Str.notifM6, Str.notifM6Keterangan),
  };

  @override
  Widget build(BuildContext context) {
    final notif = context.watch<NotifikasiProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final bisaDiubah = notif.tersedia && !notif.memproses;

    return Scaffold(
      appBar: AppBar(title: const Text(Str.navPeringatan)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Str.notifJudul,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (notif.memproses)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(Str.notifKeterangan, style: redup),
          ),
          if (!notif.tersedia)
            const _Kotak(pesan: Str.notifBelumAktif, ikon: Icons.info_outline),
          RadioGroup<AmbangGempa>(
            groupValue: notif.ambang,
            onChanged: (a) {
              if (a != null) notif.pilih(a);
            },
            child: Column(
              children: [
                for (final a in AmbangGempa.values)
                  RadioListTile<AmbangGempa>(
                    value: a,
                    enabled: bisaDiubah,
                    title: Text(_label[a]!.$1),
                    subtitle: Text(_label[a]!.$2),
                  ),
              ],
            ),
          ),
          if (notif.pesan != null && notif.tersedia)
            _Kotak(
              pesan: notif.pesan!,
              ikon: Icons.notifications_off_outlined,
              galat: true,
              aksi: notif.izinDitolak
                  ? TextButton(
                      onPressed: notif.bukaPengaturan,
                      child: const Text(Str.bukaPengaturanAplikasi),
                    )
                  : null,
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(Str.notifSumber, style: redup),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text(Str.peringatanDiniSegera),
            subtitle: const Text(Str.peringatanKeterangan),
            enabled: false,
          ),
        ],
      ),
    );
  }
}

class _Kotak extends StatelessWidget {
  const _Kotak({
    required this.pesan,
    required this.ikon,
    this.galat = false,
    this.aksi,
  });

  final String pesan;
  final IconData ikon;
  final bool galat;
  final Widget? aksi;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final latar = galat ? scheme.errorContainer : scheme.secondaryContainer;
    final teks = galat ? scheme.onErrorContainer : scheme.onSecondaryContainer;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ikon, color: teks),
              const SizedBox(width: 10),
              Expanded(
                child: Text(pesan, style: TextStyle(color: teks)),
              ),
            ],
          ),
          aksi ?? const SizedBox(height: 8),
        ],
      ),
    );
  }
}
