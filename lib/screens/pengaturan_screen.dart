import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/navigasi.dart';
import '../core/theme.dart';
import '../models/ambang_gempa.dart';
import '../providers/notifikasi_provider.dart';
import '../providers/pengaturan_provider.dart';
import '../widgets/app_chrome.dart';
import '../widgets/kartu_kaca.dart';
import '../widgets/status_data.dart';
import 'onboarding_screen.dart';
import 'urutan_beranda_screen.dart';

/// Pengaturan dalam daftar berkelompok: satu kartu kaca per bagian, isinya
/// baris rapat (ikon, judul, nilai di kanan) yang dipisah garis tipis.
///
/// Bagian: preferensi (tema, bahasa), peringatan (notifikasi gempa), tampilan
/// (efek kaca cair, urutan Beranda), dan tentang. Teks panjang tentang sumber
/// data bukan baris yang bisa diketuk, jadi ditaruh sebagai catatan di bawah
/// kartu Tentang. Semua pilihan tersimpan di perangkat lewat provider masing-
/// masing.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final pengaturan = context.watch<PengaturanProvider>();
    final notif = context.watch<NotifikasiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.navPengaturan),
            Text(l.subjudulPengaturan, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
              child: Text(
                l.pengaturanIntro,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _Bagian(
              judul: l.pengaturanPreferensi,
              children: [
                _BarisPilihan<PilihanTema>(
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
                _BarisPilihan<PilihanBahasa>(
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
              ],
            ),
            _Bagian(
              judul: l.pengaturanPeringatan,
              children: [
                _BarisPilihan<AmbangGempa>(
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
              judul: l.pengaturanTampilan,
              children: [
                SwitchListTile(
                  key: const ValueKey('pengaturan.kacaCair'),
                  contentPadding: _paddingBaris,
                  secondary: const _KotakIkon(IkonApp.tema),
                  title: Text(l.kacaCairJudul),
                  subtitle: Text(l.kacaCairKeterangan),
                  value: pengaturan.kacaCair,
                  onChanged: pengaturan.aturKacaCair,
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.urutan),
                  title: Text(l.urutanBerandaJudul),
                  subtitle: Text(l.urutanBerandaRingkas),
                  trailing: const _Panah(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const UrutanBerandaScreen(),
                    ),
                  ),
                ),
              ],
            ),
            _Bagian(
              judul: l.tentangJudul,
              children: [
                ListTile(
                  key: const ValueKey('pengaturan.layanan'),
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.layanan),
                  title: Text(l.layananJudul),
                  subtitle: Text(l.layananRingkas),
                  trailing: const _Panah(),
                  onTap: Navigasi.bukaLayanan,
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.info),
                  title: Text(l.panduanAplikasi),
                  subtitle: Text(l.panduanAplikasiKeterangan),
                  trailing: const _Panah(),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => OnboardingScreen(
                        onSelesai: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.lisensi),
                  title: Text(l.lisensiSumberTerbuka),
                  trailing: const _Panah(),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: l.appName,
                  ),
                ),
                const _BarisVersi(),
              ],
            ),
            // Informasi sumber data: teks panjang, bukan baris yang bisa
            // diketuk, jadi dijadikan catatan di bawah kartu.
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.appName, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    l.tentangSumber,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l.lisensiDataWilayah, style: theme.textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    l.tentangDataWilayah,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _paddingBaris = EdgeInsets.symmetric(horizontal: 14, vertical: 2);

/// Ikon dalam kotak bulat bertint, ciri tiap baris.
class _KotakIkon extends StatelessWidget {
  const _KotakIkon(this.ikon);

  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: .75),
        borderRadius: BorderRadius.circular(11),
      ),
      child: IkonDuo(ikon, size: 20, color: scheme.onPrimaryContainer),
    );
  }
}

class _Panah extends StatelessWidget {
  const _Panah();

  @override
  Widget build(BuildContext context) => IkonDuo(
    IkonApp.selengkapnya,
    size: 20,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Judul bagian + satu kartu kaca berisi baris-baris yang dipisah garis tipis.
/// Isinya dibungkus Material transparan supaya efek ketuk tergambar di atas
/// kaca (bukan di bawahnya).
class _Bagian extends StatelessWidget {
  const _Bagian({required this.judul, required this.children});

  final String judul;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final garis = AppTheme.kacaTepi(Theme.of(context).brightness);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          JudulBagian(judul),
          KartuKaca(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    for (var i = 0; i < children.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 64,
                          endIndent: 14,
                          color: garis,
                        ),
                      children[i],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu pengaturan dengan pilihan tetap (dialog radio): nilai terpilih di
/// kanan, panah menandakan bisa diketuk.
class _BarisPilihan<T> extends StatelessWidget {
  const _BarisPilihan({
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

  /// Subjudul (mis. alasan pengaturan tidak bisa diubah).
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
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: _paddingBaris,
      leading: _KotakIkon(ikon),
      title: Text(judul),
      subtitle: keterangan == null ? null : Text(keterangan!),
      trailing: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * .38,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                pilihan[nilai] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const _Panah(),
          ],
        ),
      ),
      enabled: aktif,
      onTap: () => _buka(context),
    );
  }
}

class _BarisVersi extends StatelessWidget {
  const _BarisVersi();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        return ListTile(
          contentPadding: _paddingBaris,
          leading: const _KotakIkon(IkonApp.versi),
          title: Text(l.tentangVersi),
          trailing: Text(
            info == null
                ? '-'
                : l.versiAplikasi(info.version, info.buildNumber),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
