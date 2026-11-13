import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../providers/pengaturan_provider.dart';
import '../widgets/status_data.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pengaturan = context.watch<PengaturanProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.navTentang)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.appName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  l.tentangKeterangan,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _Judul(l.tentangPengaturan),
          _Pilihan<PilihanBahasa>(
            ikon: IkonApp.bahasa,
            judul: l.tentangBahasa,
            nilai: pengaturan.bahasa,
            pilihan: {
              PilihanBahasa.sistem: l.ikutiSistem,
              PilihanBahasa.indonesia: l.bahasaIndonesia,
              PilihanBahasa.inggris: l.bahasaInggris,
            },
            onPilih: pengaturan.pilihBahasa,
          ),
          _Pilihan<PilihanTema>(
            ikon: IkonApp.tema,
            judul: l.tentangTema,
            nilai: pengaturan.tema,
            pilihan: {
              PilihanTema.sistem: l.ikutiSistem,
              PilihanTema.terang: l.temaTerang,
              PilihanTema.gelap: l.temaGelap,
            },
            onPilih: pengaturan.pilihTema,
          ),
          _Judul(l.tentangKredit),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _BarisInfo(ikon: IkonApp.info, teks: l.tentangSumber),
                    const SizedBox(height: 12),
                    _BarisInfo(ikon: IkonApp.peta, teks: l.tentangDataWilayah),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(IkonApp.lisensi),
            title: Text(l.lisensiSumberTerbuka),
            onTap: () =>
                showLicensePage(context: context, applicationName: l.appName),
          ),
          const _Versi(),
        ],
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  const _Judul(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: JudulBagian(teks),
    );
  }
}

/// Satu pengaturan dengan pilihan tetap (dialog radio).
class _Pilihan<T> extends StatelessWidget {
  const _Pilihan({
    required this.ikon,
    required this.judul,
    required this.nilai,
    required this.pilihan,
    required this.onPilih,
  });

  final IconData ikon;
  final String judul;
  final T nilai;
  final Map<T, String> pilihan;
  final Future<void> Function(T) onPilih;

  Future<void> _buka(BuildContext context) async {
    final hasil = await showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(judul),
        children: [
          RadioGroup<T>(
            groupValue: nilai,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final e in pilihan.entries)
                  RadioListTile<T>(value: e.key, title: Text(e.value)),
              ],
            ),
          ),
        ],
      ),
    );
    if (hasil != null) await onPilih(hasil);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(ikon),
      title: Text(judul),
      subtitle: Text(pilihan[nilai] ?? ''),
      onTap: () => _buka(context),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.ikon, required this.teks});

  final IconData ikon;
  final String teks;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ikon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(teks)),
      ],
    );
  }
}

class _Versi extends StatelessWidget {
  const _Versi();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        return ListTile(
          leading: const Icon(IkonApp.versi),
          title: Text(l.tentangVersi),
          subtitle: Text(
            info == null
                ? '-'
                : l.versiAplikasi(info.version, info.buildNumber),
          ),
        );
      },
    );
  }
}
