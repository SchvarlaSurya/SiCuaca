import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/ambang_gempa.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/pengaturan_provider.dart';
import '../widgets/status_data.dart';
import '../widgets/app_chrome.dart';
import 'onboarding_screen.dart';
import 'urutan_beranda_screen.dart';

/// Pengaturan: tampilan (tema, bahasa), ambang notifikasi gempa, dan
/// informasi tentang aplikasi. Semua pilihan tersimpan di perangkat lewat
/// provider masing-masing.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pengaturan = context.watch<PengaturanProvider>();
    final notif = context.watch<NotifikasiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.navPengaturan),
            Text(
              l.subjudulPengaturan,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: EdgeInsets.only(
            bottom: 24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: MasukLembut(child: _PengaturanIntro()),
            ),
            _Bagian(
              judul: l.pengaturanTampilan,
              children: [
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
                SwitchListTile(
                  key: const ValueKey('pengaturan.kacaCair'),
                  secondary: const IkonDuo(IkonApp.tema),
                  title: Text(l.kacaCairJudul),
                  subtitle: Text(l.kacaCairKeterangan),
                  value: pengaturan.kacaCair,
                  onChanged: pengaturan.aturKacaCair,
                ),
                ListTile(
                  leading: const IkonDuo(IkonApp.urutan),
                  title: Text(l.urutanBerandaJudul),
                  subtitle: Text(l.urutanBerandaRingkas),
                  trailing: const IkonDuo(IkonApp.selengkapnya),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const UrutanBerandaScreen(),
                    ),
                  ),
                ),
              ],
            ),
            _Bagian(
              judul: l.notifJudul,
              children: [
                _Pilihan<AmbangGempa>(
                  ikon: notif.ambang == AmbangGempa.mati
                      ? IkonApp.notifMati
                      : IkonApp.notifAktif,
                  judul: l.notifJudul,
                  nilai: notif.ambang,
                  aktif: notif.tersedia && !notif.memproses,
                  keterangan: notif.tersedia ? null : l.notifBelumAktif,
                  pilihan: {
                    AmbangGempa.mati: l.notifMati,
                    AmbangGempa.m4: l.notifM4,
                    AmbangGempa.m5: l.notifM5,
                    AmbangGempa.m6: l.notifM6,
                  },
                  onPilih: notif.pilih,
                ),
              ],
            ),
            _Bagian(
              judul: l.tentangJudul,
              children: [
                ListTile(
                  leading: const IkonDuo(IkonApp.info),
                  title: Text(l.appName),
                  subtitle: Text(l.tentangSumber),
                ),
                ListTile(
                  leading: const IkonDuo(IkonApp.peta),
                  title: Text(l.lisensiDataWilayah),
                  subtitle: Text(l.tentangDataWilayah),
                ),
                ListTile(
                  leading: const IkonDuo(IkonApp.info),
                  title: Text(l.panduanAplikasi),
                  subtitle: Text(l.panduanAplikasiKeterangan),
                  trailing: const IkonDuo(IkonApp.selengkapnya),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OnboardingScreen(
                        onSelesai: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: const IkonDuo(IkonApp.lisensi),
                  title: Text(l.lisensiSumberTerbuka),
                  trailing: const IkonDuo(IkonApp.selengkapnya),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l.appName,
                  ),
                ),
                const _Versi(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PengaturanIntro extends StatelessWidget {
  const _PengaturanIntro();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: scheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IkonDuo(IkonApp.setelan, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(context.l10n.pengaturanIntro)),
        ],
      ),
    );
  }
}

/// Judul bagian + kartu berisi baris pengaturan, dipisah garis.
class _Bagian extends StatelessWidget {
  const _Bagian({required this.judul, required this.children});

  final String judul;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JudulBagian(judul),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const Divider(indent: 56),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
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
    this.aktif = true,
    this.keterangan,
  });

  final IconData ikon;
  final String judul;
  final T nilai;
  final Map<T, String> pilihan;
  final Future<void> Function(T) onPilih;
  final bool aktif;

  /// Pengganti subjudul (mis. alasan pengaturan tidak bisa diubah).
  final String? keterangan;

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
      leading: IkonDuo(ikon),
      title: Text(judul),
      subtitle: Text(keterangan ?? pilihan[nilai] ?? ''),
      enabled: aktif,
      onTap: () => _buka(context),
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
          leading: const IkonDuo(IkonApp.versi),
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
