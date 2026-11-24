import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/navigasi.dart';
import '../core/l10n.dart';
import '../core/warna_semantik.dart';
import '../models/prakiraan.dart';
import '../providers/gempa_provider.dart';
import '../providers/weather_provider.dart';
import '../services/notifikasi_service.dart';
import '../widgets/ikon_cuaca.dart';
import '../widgets/transisi_tab.dart';
import 'beranda_screen.dart';
import 'cuaca_screen.dart';
import 'gempa_screen.dart';
import 'pengaturan_screen.dart';

/// Kerangka utama dengan bottom bar 4 tab. Tab Cuaca dan Gempa menampilkan
/// data langsung (suhu sekarang dan magnitudo gempa terbaru) di tempat
/// ikonnya.
///
/// Memakai [TransisiTab] (tumpukan seperti IndexedStack) supaya semua tab tetap
/// hidup di memori, jadi state (posisi scroll, data yang sudah dimuat) tidak
/// hilang saat berpindah tab, dengan transisi halus saat pindah.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    Navigasi.tabAktif.value = TabUtama.beranda;
    // Navigator sudah ada setelah frame pertama; ketukan notifikasi yang
    // terjadi sebelumnya (aplikasi diluncurkan dari notifikasi) dibuka saat
    // pembuka dipasang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotifikasiService>().pembuka.pasang(
        Navigasi.bukaDetailGempa,
      );
    });
  }

  static const List<Widget> _halaman = [
    BerandaScreen(),
    CuacaScreen(),
    GempaScreen(),
    PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: Navigasi.tabAktif,
      builder: (context, indeks, _) => Scaffold(
        // Isi layar tembus ke belakang navbar, jadi yang terlihat hanya
        // pill-nya. Scaffold menambahkan tinggi navbar ke padding bawah
        // MediaQuery; daftar di tiap tab memakai itu sebagai jarak bawah.
        extendBody: true,
        body: TransisiTab(indeks: indeks, anak: _halaman),
        bottomNavigationBar: _NavigasiBawah(indeks: indeks),
      ),
    );
  }
}

/// Navbar kaca cair (liquid glass) dari paket liquid_glass_widgets: pil kaca
/// gelap melayang dengan lensa kapsul yang bisa digeser jari dari tab ke tab
/// (efek jeli), seperti tab bar iOS. Tab tidak aktif hanya ikon; tab aktif
/// ikon + label. Isi tab Cuaca dan Gempa tetap data langsung (suhu dan
/// magnitudo).
///
/// Di Android (Impeller) lensa membiaskan isi di belakangnya; di web hanya
/// tingkat "standard" (tanpa pembiasan latar).
class _NavigasiBawah extends StatelessWidget {
  const _NavigasiBawah({required this.indeks});

  final int indeks;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;

    // Satu widget untuk keadaan aktif dan tidak aktif (tanpa activeIcon).
    GlassTab tab({
      required int urutan,
      required String kunci,
      required String label,
      required Widget Function(Color warna, bool aktif) isi,
      String? nilai,
    }) {
      final aktif = indeks == urutan;
      return GlassTab(
        label: aktif ? label : null,
        // Node semantik tab dibuat GlassTabBar (tombol, terpilih, aksi
        // ketuk); isi ikon dikecualikan, jadi nilai data langsung (suhu,
        // magnitudo) ikut dibacakan lewat label ini.
        semanticLabel: nilai == null ? label : '$label, $nilai',
        icon: KeyedSubtree(
          key: ValueKey('nav.$kunci'),
          child: Builder(
            builder: (context) => isi(
              IconTheme.of(context).color ??
                  (aktif ? _warnaIkonAktif : _warnaIkonPasif),
              aktif,
            ),
          ),
        ),
      );
    }

    return GlassTabBar.bottom(
      selectedIndex: indeks,
      onTabSelected: Navigasi.bukaTab,
      barHeight: 66,
      horizontalPadding: 14,
      verticalPadding: 14,
      iconSize: 26,
      labelFontSize: 12,
      iconLabelSpacing: 3,
      selectedIconColor: _warnaIkonAktif,
      unselectedIconColor: _warnaIkonPasif,
      selectedLabelColor: _warnaIkonAktif,
      unselectedLabelColor: _warnaIkonPasif,
      // Pil: kaca gelap pekat dengan tepi menyala tipis (di kedua tema).
      settings: LiquidGlassSettings.ios27Dark.copyWith(
        glassColor: const Color(0xE60B0C10),
        thickness: 18,
        refractiveIndex: 1.12,
      ),
      // Lensa kapsul (radius bawaan = penuh), sedikit membesar saat digeser.
      indicatorExpansion: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      // Refraksi lensa diturunkan supaya lebih halus, tidak terlalu melengkung.
      indicatorSettings: LiquidGlassSettings.ios27Indicator.copyWith(
        thickness: 22,
        refractiveIndex: 1.1,
      ),
      tabs: [
        tab(
          urutan: TabUtama.beranda,
          kunci: 'beranda',
          label: l.navBeranda,
          isi: (warna, aktif) => _IkonTab(IkonApp.beranda, warna, aktif),
        ),
        tab(
          urutan: TabUtama.cuaca,
          kunci: 'cuaca',
          label: l.navCuaca,
          nilai: _nilaiCuaca(context),
          isi: (warna, aktif) => _IsiCuaca(warna: warna, aktif: aktif),
        ),
        tab(
          urutan: TabUtama.gempa,
          kunci: 'gempa',
          label: l.navGempa,
          nilai: _nilaiGempa(context),
          isi: (warna, aktif) => _IsiGempa(warna: warna, aktif: aktif),
        ),
        tab(
          urutan: TabUtama.pengaturan,
          kunci: 'pengaturan',
          label: l.navPengaturan,
          isi: (warna, aktif) => _IkonTab(IkonApp.pengaturan, warna, aktif),
        ),
      ],
    );
  }

  /// Teks untuk pembaca layar, mis. "28°C, Hujan Ringan".
  static String? _nilaiCuaca(BuildContext context) {
    final entri = _entriSekarang(context);
    if (entri == null) return null;
    return '${Format.suhu(entri.suhu)}, ${context.l10n.deskripsiCuaca(entri)}';
  }

  static String? _nilaiGempa(BuildContext context) {
    final gempa = context.watch<GempaProvider>().terbaru.data;
    if (gempa == null) return null;
    final l = context.l10n;
    return l.magnitudoSemantik(
      gempa.magnitudo,
      TingkatMagnitudo.dari(gempa.magnitudoAngka).label(l),
    );
  }
}

EntriPrakiraan? _entriSekarang(BuildContext context) {
  final cuaca = context.watch<WeatherProvider>();
  if (cuaca.status != StatusCuaca.berhasil) return null;
  return cuaca.prakiraan?.entriTerdekat(DateTime.now());
}

const _warnaIkonPasif = Color(0xFFE4E2EC);
const _warnaIkonAktif = Color(0xFFFFFFFF);

class _IkonTab extends StatelessWidget {
  const _IkonTab(this.ikon, this.warna, this.aktif);

  final IconData ikon;
  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    return IkonDuo(
      ikon,
      size: 24,
      color: warna,
      // Tab aktif: isian duotone lebih pekat.
      duotoneSecondaryOpacity: aktif ? 0.45 : 0.18,
    );
  }
}

/// Ikon kondisi + suhu sekarang, mis. ☁ 28°. Tanpa data: ikon cuaca biasa.
class _IsiCuaca extends StatelessWidget {
  const _IsiCuaca({required this.warna, required this.aktif});

  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final entri = _entriSekarang(context);
    if (entri == null) return _IkonTab(IkonApp.cuaca, warna, aktif);
    final suhu = entri.suhu;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IkonCuaca(
          deskripsi: entri.deskripsi,
          malam: entri.malam,
          size: 20,
          warna: warna,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            suhu == null ? Format.tandaKosong : '${suhu.round()}°',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: warna,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

/// Chip magnitudo gempa terbaru dengan warna tingkatnya. Tanpa data: ikon.
class _IsiGempa extends StatelessWidget {
  const _IsiGempa({required this.warna, required this.aktif});

  final Color warna;
  final bool aktif;

  @override
  Widget build(BuildContext context) {
    final gempa = context.watch<GempaProvider>().terbaru.data;
    if (gempa == null) return _IkonTab(IkonApp.gempa, warna, aktif);
    final tingkat = TingkatMagnitudo.dari(gempa.magnitudoAngka);
    final angka = gempa.magnitudo.isNotEmpty
        ? gempa.magnitudo
        : (gempa.magnitudoAngka?.toStringAsFixed(1) ?? Format.tandaKosong);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: tingkat.latar,
        borderRadius: BorderRadius.circular(8),
        border: aktif ? Border.all(color: warna, width: 1.5) : null,
      ),
      child: Text(
        'M$angka',
        maxLines: 1,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: tingkat.depan,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
