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
import '../widgets/tombol_kaca.dart';
import 'onboarding_screen.dart';
import 'urutan_beranda_screen.dart';

// Warna ikon tiap pengaturan (tint latar dibuat dari warna yang sama).
const _jingga = Color(0xFFF59E0B);
const _indigo = Color(0xFF6366F1);
const _merah = Color(0xFFE5484D);
const _biru = Color(0xFF2F7BDB);
const _ungu = Color(0xFF7C5CE0);
const _teal = Color(0xFF14A58A);
const _hijau = Color(0xFF22A559);
const _kuning = Color(0xFFE0A100);
const _abu = Color(0xFF64748B);

/// Pengaturan. Susunan: kartu pengantar, "Preferensi aplikasi" (ubin Tema dan
/// Bahasa berdampingan), kartu "Peringatan cepat" (notifikasi gempa),
/// "Tampilan & tata letak" (efek kaca cair, urutan Beranda), dan "Tentang
/// SiCuaca". Semua pilihan tersimpan di perangkat lewat provider masing-
/// masing.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  void _bukaPanduan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            OnboardingScreen(onSelesai: () => Navigator.of(context).pop()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final pengaturan = context.watch<PengaturanProvider>();
    final notif = context.watch<NotifikasiProvider>();

    final pilihanTema = {
      PilihanTema.sistem: l.ikutiSistem,
      PilihanTema.terang: l.temaTerang,
      PilihanTema.gelap: l.temaGelap,
    };
    final pilihanBahasa = {
      PilihanBahasa.sistem: l.ikutiSistem,
      PilihanBahasa.indonesia: l.bahasaIndonesia,
      PilihanBahasa.inggris: l.bahasaInggris,
    };
    final pilihanNotif = {
      AmbangGempa.mati: l.notifMati,
      AmbangGempa.m4: l.notifM4,
      AmbangGempa.m5: l.notifM5,
      AmbangGempa.m6: l.notifM6,
    };

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.navPengaturan),
            Text(l.subjudulPengaturan, style: theme.textTheme.bodySmall),
          ],
        ),
        actions: [
          GrupTombolKaca(
            children: [
              TombolKaca(
                tooltip: l.siagaJudul,
                icon: const IkonDuo(IkonApp.segitigaPeringatan),
                onPressed: Navigasi.bukaSiaga,
              ),
              TombolKaca(
                tooltip: l.panduanAplikasi,
                icon: const IkonDuo(IkonApp.bantuan),
                onPressed: () => _bukaPanduan(context),
              ),
            ],
          ),
        ],
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
            MasukLembut(child: _KartuPengantar(teks: l.pengaturanIntro)),
            _JudulKecil(l.pengaturanPreferensi, lencana: l.pengaturanLokal),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _UbinPilihan<PilihanTema>(
                      ikon: IkonApp.tema,
                      warna: _jingga,
                      judul: l.tentangTema,
                      nilai: pengaturan.tema,
                      pilihan: pilihanTema,
                      aktifBila: pengaturan.tema != PilihanTema.sistem,
                      onPilih: pengaturan.pilihTema,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UbinPilihan<PilihanBahasa>(
                      ikon: IkonApp.bahasa,
                      warna: _indigo,
                      judul: l.tentangBahasa,
                      nilai: pengaturan.bahasa,
                      pilihan: pilihanBahasa,
                      aktifBila: pengaturan.bahasa != PilihanBahasa.sistem,
                      onPilih: pengaturan.pilihBahasa,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _KartuPeringatanCepat(
              judul: l.notifJudul,
              nilai: notif.ambang,
              pilihan: pilihanNotif,
              aktif: notif.tersedia && !notif.memproses,
              keterangan: notif.tersedia ? null : l.notifBelumAktif,
              onPilih: notif.pilih,
            ),
            _JudulKecil(l.pengaturanTampilan),
            _Kelompok(
              children: [
                SwitchListTile(
                  key: const ValueKey('pengaturan.kacaCair'),
                  contentPadding: _paddingBaris,
                  secondary: const _KotakIkon(IkonApp.labu, _biru),
                  title: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l.kacaCairJudul),
                      _LencanaKecil(l.kacaCairLencana, _indigo),
                    ],
                  ),
                  subtitle: Text(l.kacaCairKeterangan),
                  value: pengaturan.kacaCair,
                  onChanged: pengaturan.aturKacaCair,
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.urutan, _ungu),
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
            _JudulKecil(l.tentangJudul),
            _Kelompok(
              children: [
                ListTile(
                  key: const ValueKey('pengaturan.layanan'),
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.globe, _teal),
                  title: Text(l.layananJudul),
                  subtitle: Text(l.layananRingkas),
                  trailing: const _Panah(),
                  onTap: Navigasi.bukaLayanan,
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.info, _biru),
                  title: Text(l.appName),
                  subtitle: Text.rich(_sumberData(context, l)),
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.pinWilayah, _hijau),
                  title: Text(l.lisensiDataWilayah),
                  subtitle: Text.rich(_dataWilayah(context, l)),
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.buku, _ungu),
                  title: Text(l.panduanAplikasi),
                  subtitle: Text(l.panduanAplikasiKeterangan),
                  trailing: const _Panah(),
                  onTap: () => _bukaPanduan(context),
                ),
                ListTile(
                  contentPadding: _paddingBaris,
                  leading: const _KotakIkon(IkonApp.kode, _kuning),
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
          ],
        ),
      ),
    );
  }

  /// "Sumber data: BMKG (...). SiCuaca bukan aplikasi resmi BMKG." dengan
  /// kalimat terakhir dimiringkan.
  static TextSpan _sumberData(BuildContext context, AppLocalizations l) {
    final teks = l.tentangSumber;
    final i = teks.indexOf(l.bukanResmi);
    final gaya = _gayaKecil(context);
    if (i < 0) return TextSpan(text: teks, style: gaya);
    return TextSpan(
      style: gaya,
      children: [
        TextSpan(text: teks.substring(0, i)),
        TextSpan(
          text: l.bukanResmi,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        TextSpan(text: teks.substring(i + l.bukanResmi.length)),
      ],
    );
  }

  /// Nama repositori (mis. cahyadsn/wilayah) ditulis monospasi.
  static TextSpan _dataWilayah(BuildContext context, AppLocalizations l) {
    final teks = l.tentangDataWilayah;
    final gaya = _gayaKecil(context);
    final latar = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: .07);
    final kode = RegExp(r'[a-z0-9]+/[a-z0-9_]+');
    final anak = <InlineSpan>[];
    var awal = 0;
    for (final m in kode.allMatches(teks)) {
      if (m.start > awal) {
        anak.add(TextSpan(text: teks.substring(awal, m.start)));
      }
      anak.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(fontFamily: 'monospace', backgroundColor: latar),
        ),
      );
      awal = m.end;
    }
    if (awal < teks.length) anak.add(TextSpan(text: teks.substring(awal)));
    return TextSpan(style: gaya, children: anak);
  }

  static TextStyle? _gayaKecil(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
  }
}

const _paddingBaris = EdgeInsets.symmetric(horizontal: 14, vertical: 2);

Future<void> _tampilkanPilihan<T>(
  BuildContext context, {
  required String judul,
  required T nilai,
  required Map<T, String> pilihan,
  required Future<void> Function(T) onPilih,
}) async {
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

/// Kartu pengantar: ikon dalam kotak bertint dan satu kalimat.
class _KartuPengantar extends StatelessWidget {
  const _KartuPengantar({required this.teks});

  final String teks;

  @override
  Widget build(BuildContext context) {
    return KartuKaca(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const _KotakIkon(IkonApp.setelan, _biru, ukuran: 40),
          const SizedBox(width: 12),
          Expanded(child: Text(teks)),
        ],
      ),
    );
  }
}

/// Judul bagian: huruf kapital kecil berjarak, dengan lencana opsional di
/// kanan.
class _JudulKecil extends StatelessWidget {
  const _JudulKecil(this.teks, {this.lencana});

  final String teks;
  final String? lencana;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                teks.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (lencana != null) _LencanaKecil(lencana!, _biru),
        ],
      ),
    );
  }
}

/// Lencana kecil bertepi tipis ("Lokal", "iOS Glass").
class _LencanaKecil extends StatelessWidget {
  const _LencanaKecil(this.teks, this.warna);

  final String teks;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: .10),
        border: Border.all(color: warna.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        teks,
        style: theme.textTheme.labelSmall?.copyWith(
          color: warna,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Ikon dalam kotak bulat bertint (baris daftar).
class _KotakIkon extends StatelessWidget {
  const _KotakIkon(this.ikon, this.warna, {this.ukuran = 36});

  final IconData ikon;
  final Color warna;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: warna.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(ukuran * .31),
      ),
      child: IkonDuo(ikon, size: ukuran * .55, color: warna),
    );
  }
}

class _Lingkaran extends StatelessWidget {
  const _Lingkaran(this.ikon, this.warna, {required this.ukuran});

  final IconData ikon;
  final Color warna;
  final double ukuran;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        color: warna.withValues(alpha: .15),
        shape: BoxShape.circle,
      ),
      child: IkonDuo(ikon, size: ukuran * .52, color: warna),
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

/// Satu kartu kaca berisi baris-baris yang dipisah garis tipis. Isinya
/// dibungkus Material transparan supaya efek ketuk tergambar di atas kaca.
class _Kelompok extends StatelessWidget {
  const _Kelompok({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final garis = AppTheme.kacaTepi(Theme.of(context).brightness);
    return KartuKaca(
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
    );
  }
}

/// Ubin setengah lebar: ikon di kiri atas, panah serong di kanan atas, lalu
/// label kecil dan nilai terpilih; lencana "Aktif" bila bukan "Ikuti sistem".
class _UbinPilihan<T> extends StatelessWidget {
  const _UbinPilihan({
    required this.ikon,
    required this.warna,
    required this.judul,
    required this.nilai,
    required this.pilihan,
    required this.aktifBila,
    required this.onPilih,
  });

  final IconData ikon;
  final Color warna;
  final String judul;
  final T nilai;
  final Map<T, String> pilihan;
  final bool aktifBila;
  final Future<void> Function(T) onPilih;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: '$judul, ${pilihan[nilai] ?? ''}',
      excludeSemantics: true,
      child: KartuKaca(
        padding: EdgeInsets.zero,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
            onTap: () => _tampilkanPilihan<T>(
              context,
              judul: judul,
              nilai: nilai,
              pilihan: pilihan,
              onPilih: onPilih,
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Lingkaran(ikon, warna, ukuran: 40),
                      const Spacer(),
                      _Lingkaran(
                        IkonApp.panahSerong,
                        scheme.onSurfaceVariant,
                        ukuran: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    judul,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        pilihan[nilai] ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (aktifBila) _LencanaKecil(l.pengaturanAktif, _hijau),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu lebar penuh untuk notifikasi gempa: ikon lonceng, label "Peringatan
/// cepat", judul, ambang terpilih dalam lencana, dan panah.
class _KartuPeringatanCepat extends StatelessWidget {
  const _KartuPeringatanCepat({
    required this.judul,
    required this.nilai,
    required this.pilihan,
    required this.aktif,
    required this.onPilih,
    this.keterangan,
  });

  final String judul;
  final AmbangGempa nilai;
  final Map<AmbangGempa, String> pilihan;
  final bool aktif;
  final String? keterangan;
  final Future<void> Function(AmbangGempa) onPilih;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mati = nilai == AmbangGempa.mati;
    final warnaLencana = mati ? _abu : _merah;
    return Opacity(
      opacity: aktif ? 1 : .55,
      child: Semantics(
        button: true,
        enabled: aktif,
        label: '$judul, ${pilihan[nilai] ?? ''}',
        excludeSemantics: true,
        child: KartuKaca(
          padding: EdgeInsets.zero,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
              onTap: aktif
                  ? () => _tampilkanPilihan<AmbangGempa>(
                      context,
                      judul: judul,
                      nilai: nilai,
                      pilihan: pilihan,
                      onPilih: onPilih,
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _Lingkaran(
                      mati ? IkonApp.notifMati : IkonApp.notifAktif,
                      _merah,
                      ukuran: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.pengaturanPeringatanCepat.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1,
                              fontSize: 10,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(judul, style: theme.textTheme.titleSmall),
                          if (keterangan != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                keterangan!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: warnaLencana.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        pilihan[nilai] ?? '',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: warnaLencana,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const _Panah(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarisVersi extends StatelessWidget {
  const _BarisVersi();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final info = snap.data;
        return ListTile(
          contentPadding: _paddingBaris,
          leading: const _KotakIkon(IkonApp.versi, _abu),
          title: Text(l.tentangVersi),
          subtitle: Text(l.versiTerpasang),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: scheme.onSurface.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              info == null
                  ? '-'
                  : l.versiAplikasi(info.version, info.buildNumber),
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}
