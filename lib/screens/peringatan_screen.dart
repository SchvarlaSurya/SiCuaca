import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../models/ambang_gempa.dart';
import '../providers/notifikasi_provider.dart';
import '../widgets/status_data.dart';
import '../widgets/app_chrome.dart';

/// Tab Peringatan: pengaturan ambang notifikasi gempa.
class PeringatanScreen extends StatelessWidget {
  const PeringatanScreen({super.key});

  static (String, String) _label(AppLocalizations l, AmbangGempa a) =>
      switch (a) {
        AmbangGempa.mati => (l.notifMati, l.notifMatiKeterangan),
        AmbangGempa.m4 => (l.notifM4, l.notifM4Keterangan),
        AmbangGempa.m5 => (l.notifM5, l.notifM5Keterangan),
        AmbangGempa.m6 => (l.notifM6, l.notifM6Keterangan),
      };

  static String _pesan(AppLocalizations l, PesanNotifikasi p) => switch (p) {
    PesanNotifikasi.belumAktif => l.notifBelumAktif,
    PesanNotifikasi.izinDitolak => l.notifIzinDitolak,
    PesanNotifikasi.gagalLangganan => l.notifGagalLangganan,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final notif = context.watch<NotifikasiProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final bisaDiubah = notif.tersedia && !notif.memproses;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.navPeringatan),
            Text(
              'Atur notifikasi yang kamu perlukan',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: MasukLembut(child: _PeringatanIntro()),
            ),
            MasukLembut(
              delay: const Duration(milliseconds: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: JudulBagian(l.notifJudul)),
                    if (notif.memproses)
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(l.notifKeterangan, style: redup),
            ),
            if (!notif.tersedia)
              _Kotak(pesan: l.notifBelumAktif, ikon: IkonApp.info),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: RadioGroup<AmbangGempa>(
                  groupValue: notif.ambang,
                  onChanged: (a) {
                    if (a != null) notif.pilih(a);
                  },
                  child: Column(
                    children: [
                      for (final a in AmbangGempa.values) ...[
                        if (a != AmbangGempa.values.first)
                          const Divider(indent: 16, endIndent: 16),
                        RadioListTile<AmbangGempa>(
                          value: a,
                          enabled: bisaDiubah,
                          title: Text(_label(l, a).$1),
                          subtitle: Text(_label(l, a).$2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (notif.pesan != null && notif.tersedia)
              _Kotak(
                pesan: _pesan(l, notif.pesan!),
                ikon: IkonApp.notifMati,
                galat: true,
                aksi: notif.izinDitolak
                    ? TextButton(
                        onPressed: notif.bukaPengaturan,
                        child: Text(l.bukaPengaturanAplikasi),
                      )
                    : null,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                [l.notifSumber, if (l.inggris) l.notifBahasaCatatan].join(' '),
                style: redup,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
            ListTile(
              leading: const Icon(IkonApp.peringatanDini),
              title: Text(l.peringatanDiniSegera),
              subtitle: Text(l.peringatanKeterangan),
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeringatanIntro extends StatelessWidget {
  const _PeringatanIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_rounded),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pilih ambang magnitudo agar pemberitahuan yang diterima tetap relevan untukmu.',
            ),
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
        borderRadius: BorderRadius.circular(AppTheme.radiusTile),
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
