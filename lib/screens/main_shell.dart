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
/// bening melayang (warna kaca mengikuti tema) dengan lensa kaca berbentuk
/// kapsul di tab aktif. Lensa bisa digeser jari dari tab ke tab (efek jeli,
/// milik paket); saat diam, lensa kaca kapsul sendiri tetap menempel di tab
/// aktif. Tab tidak aktif hanya ikon; tab aktif ikon + label. Isi tab Cuaca
/// dan Gempa tetap data langsung (suhu dan magnitudo).
///
/// Di Android (Impeller) kaca membiaskan isi di belakangnya; di web hanya
/// tingkat "standard". Bila efek kaca cair dimatikan di Pengaturan, semua
/// kaca jadi kaca sederhana tanpa shader (lihat GlassTheme di main.dart).
class _NavigasiBawah extends StatefulWidget {
  const _NavigasiBawah({required this.indeks});

  final int indeks;

  @override
  State<_NavigasiBawah> createState() => _NavigasiBawahState();
}

class _NavigasiBawahState extends State<_NavigasiBawah>
    with SingleTickerProviderStateMixin {
  static const _tinggiBar = 66.0;
  static const _jarakSisi = 14.0;
  static const _jarakTegak = 12.0;
  static const _isiLensa = 4.0;

  /// Jarak dalam deretan tab di dalam pil (tabPadding bawaan GlassTabBar).
  static const _isiDeret = 4.0;

  /// 1 = lensa diam tampil; 0 = disembunyikan selama jari menyentuh bar
  /// (saat itu lensa jeli milik paket yang tampil dan bergerak).
  late final AnimationController _lensaDiam;

  @override
  void initState() {
    super.initState();
    _lensaDiam = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
      value: 1,
    );
  }

  @override
  void dispose() {
    _lensaDiam.dispose();
    super.dispose();
  }

  void _sentuh() =>
      _lensaDiam.animateBack(0, duration: const Duration(milliseconds: 110));

  // Muncul lagi setelah lensa jeli paket selesai meluncur dan memudar.
  void _lepas() => _lensaDiam.animateTo(
    1,
    duration: const Duration(milliseconds: 720),
    curve: const Interval(.55, 1, curve: Curves.easeOut),
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final indeks = widget.indeks;
    final gelap = Theme.of(context).brightness == Brightness.dark;
    final tanpaGerak = MediaQuery.of(context).disableAnimations;
    final warnaAktif = gelap ? _warnaIkonAktif : const Color(0xFF17151F);
    final warnaPasif = gelap ? _warnaIkonPasif : const Color(0xFF45424F);

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
              IconTheme.of(context).color ?? (aktif ? warnaAktif : warnaPasif),
              aktif,
            ),
          ),
        ),
      );
    }

    final tabs = [
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
    ];

    // Kaca bening, refraksi rendah. Gelap: tint gelap tipis + ikon terang;
    // terang: tint putih + ikon gelap, supaya ikon tetap terbaca di atas
    // konten apa pun yang lewat di belakangnya (kaca juga di-frost).
    final kacaPil =
        (gelap
                ? LiquidGlassSettings.ios27Dark.copyWith(
                    glassColor: const Color(0x590B0C10),
                  )
                : LiquidGlassSettings.ios27Light)
            .copyWith(thickness: 18, refractiveIndex: 1.12);
    final kacaLensa = LiquidGlassSettings.ios27Indicator.copyWith(
      thickness: 22,
      refractiveIndex: 1.1,
      glassColor: gelap ? const Color(0x24FFFFFF) : const Color(0x4DFFFFFF),
    );

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, batas) {
          final lebarTab =
              (batas.maxWidth - 2 * (_jarakSisi + _isiDeret)) / tabs.length;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Listener(
                onPointerDown: (_) => _sentuh(),
                onPointerUp: (_) => _lepas(),
                onPointerCancel: (_) => _lepas(),
                child: GlassTabBar.bottom(
                  selectedIndex: indeks,
                  onTabSelected: Navigasi.bukaTab,
                  barHeight: _tinggiBar,
                  horizontalPadding: _jarakSisi,
                  verticalPadding: _jarakTegak,
                  iconSize: 26,
                  labelFontSize: 12,
                  iconLabelSpacing: 3,
                  selectedIconColor: warnaAktif,
                  unselectedIconColor: warnaPasif,
                  selectedLabelColor: warnaAktif,
                  unselectedLabelColor: warnaPasif,
                  settings: kacaPil,
                  // Latar datar bawaan tab aktif diganti lensa kaca di bawah.
                  indicatorColor: const Color(0x00000000),
                  indicatorExpansion: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  indicatorSettings: kacaLensa,
                  tabs: tabs,
                ),
              ),
              // Lensa kaca kapsul yang menempel di tab aktif saat diam.
              AnimatedPositioned(
                duration: tanpaGerak
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: _jarakSisi + _isiDeret + indeks * lebarTab + _isiLensa,
                top: _jarakTegak + _isiLensa,
                width: lebarTab - 2 * _isiLensa,
                height: _tinggiBar - 2 * _isiLensa,
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: _lensaDiam,
                    child: GlassContainer(
                      useOwnLayer: true,
                      shape: const LiquidRoundedSuperellipse(
                        borderRadius: (_tinggiBar - 2 * _isiLensa) / 2,
                      ),
                      settings: kacaLensa,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
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
