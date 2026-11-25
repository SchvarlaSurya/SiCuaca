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
import '../widgets/mode_kaca.dart';
import '../core/theme.dart';
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

  bool _ditekan = false;

  void _sentuh() {
    _ditekan = true;
    _lensaDiam.animateBack(0, duration: const Duration(milliseconds: 90));
  }

  void _lepas() {
    _ditekan = false;
    _tampilkanNanti();
  }

  /// Lensa diam baru muncul setelah gelembung jeli milik paket sampai di tab
  /// tujuan dan mulai memudar (sekitar 0,65 detik), lalu memudar masuk.
  /// Kalau lebih cepat, lensa diam terlihat duluan di tab tujuan sebelum
  /// gelembungnya tiba.
  void _tampilkanNanti() {
    if (MediaQuery.of(context).disableAnimations) {
      _lensaDiam.value = 1;
      return;
    }
    _lensaDiam.animateTo(
      1,
      duration: const Duration(milliseconds: 880),
      curve: const Interval(.74, 1, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_NavigasiBawah lama) {
    super.didUpdateWidget(lama);
    if (lama.indeks == widget.indeks) return;
    // Tab berganti (diketuk, digeser, atau lewat tautan): gelembung jeli paket
    // sedang meluncur. Sembunyikan lensa diam seketika; ia pindah tanpa
    // animasi dan muncul lagi setelah gelembung tiba.
    _lensaDiam.value = 0;
    if (!_ditekan) _tampilkanNanti();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final indeks = widget.indeks;
    final gelap = Theme.of(context).brightness == Brightness.dark;
    final warnaAktif = gelap ? _warnaIkonAktif : const Color(0xFF17151F);
    final warnaPasif = gelap ? _warnaIkonPasif : const Color(0xFF45424F);

    final data = <_DataTab>[
      _DataTab(
        urutan: TabUtama.beranda,
        kunci: 'beranda',
        label: l.navBeranda,
        isi: (warna, aktif) => _IkonTab(IkonApp.beranda, warna, aktif),
      ),
      _DataTab(
        urutan: TabUtama.cuaca,
        kunci: 'cuaca',
        label: l.navCuaca,
        nilai: _nilaiCuaca(context),
        isi: (warna, aktif) => _IsiCuaca(warna: warna, aktif: aktif),
      ),
      _DataTab(
        urutan: TabUtama.gempa,
        kunci: 'gempa',
        label: l.navGempa,
        nilai: _nilaiGempa(context),
        isi: (warna, aktif) => _IsiGempa(warna: warna, aktif: aktif),
      ),
      _DataTab(
        urutan: TabUtama.pengaturan,
        kunci: 'pengaturan',
        label: l.navPengaturan,
        isi: (warna, aktif) => _IkonTab(IkonApp.pengaturan, warna, aktif),
      ),
    ];

    // Efek kaca cair mati: navbar biasa tanpa GlassTabBar/lensa/shader.
    if (!kacaCairAktif(context)) {
      return _NavigasiRingan(
        data: data,
        indeks: indeks,
        warnaAktif: warnaAktif,
        warnaPasif: warnaPasif,
      );
    }

    // Satu widget untuk keadaan aktif dan tidak aktif (tanpa activeIcon).
    GlassTab tab(_DataTab d) {
      final aktif = indeks == d.urutan;
      return GlassTab(
        label: aktif ? d.label : null,
        // Node semantik tab dibuat GlassTabBar (tombol, terpilih, aksi
        // ketuk); isi ikon dikecualikan, jadi nilai data langsung (suhu,
        // magnitudo) ikut dibacakan lewat label ini.
        semanticLabel: d.nilai == null ? d.label : '${d.label}, ${d.nilai}',
        icon: KeyedSubtree(
          key: ValueKey('nav.${d.kunci}'),
          child: Builder(
            builder: (context) => d.isi(
              IconTheme.of(context).color ?? (aktif ? warnaAktif : warnaPasif),
              aktif,
            ),
          ),
        ),
      );
    }

    final tabs = [for (final d in data) tab(d)];

    // Pil: kaca bening TANPA refraksi (indeks bias 1,0), lensa tetap
    // membias. Gelap: tint gelap tipis + ikon terang; terang: tint putih +
    // ikon gelap, supaya ikon terbaca di atas konten apa pun (kaca di-frost).
    final kacaPil =
        (gelap
                ? LiquidGlassSettings.ios27Dark.copyWith(
                    glassColor: const Color(0x590B0C10),
                  )
                : LiquidGlassSettings.ios27Light)
            .copyWith(thickness: 18, refractiveIndex: 1.0);
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
              Positioned(
                left: _jarakSisi + _isiDeret + indeks * lebarTab + _isiLensa,
                top: _jarakTegak + _isiLensa,
                width: lebarTab - 2 * _isiLensa,
                height: _tinggiBar - 2 * _isiLensa,
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: _lensaDiam,
                    child: GlassContainer(
                      key: const ValueKey('nav.lensa'),
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

class _DataTab {
  const _DataTab({
    required this.urutan,
    required this.kunci,
    required this.label,
    required this.isi,
    this.nilai,
  });

  final int urutan;
  final String kunci;
  final String label;
  final String? nilai;
  final Widget Function(Color warna, bool aktif) isi;
}

/// Navbar ringan (efek kaca cair mati): pil biasa berisi deretan tab dan satu
/// kapsul sorot yang bergeser ke tab aktif. Tanpa kaca, shader, blur, atau
/// lensa; node semantik, kunci `nav.<tab>`, dan data langsung (suhu,
/// magnitudo) sama dengan navbar kaca.
class _NavigasiRingan extends StatelessWidget {
  const _NavigasiRingan({
    required this.data,
    required this.indeks,
    required this.warnaAktif,
    required this.warnaPasif,
  });

  final List<_DataTab> data;
  final int indeks;
  final Color warnaAktif;
  final Color warnaPasif;

  static const _tinggi = 66.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gelap = theme.brightness == Brightness.dark;
    final tanpaGerak = MediaQuery.of(context).disableAnimations;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Container(
          height: _tinggi,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_tinggi / 2),
            color: gelap ? const Color(0xF50E1A33) : const Color(0xF8FFFFFF),
            border: Border.all(color: AppTheme.kacaTepi(theme.brightness)),
          ),
          child: LayoutBuilder(
            builder: (context, batas) {
              final lebar = (batas.maxWidth - 8) / data.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: tanpaGerak
                        ? Duration.zero
                        : const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    left: 4 + indeks * lebar + 3,
                    top: 5,
                    width: lebar - 6,
                    height: _tinggi - 10,
                    child: DecoratedBox(
                      key: const ValueKey('nav.sorot'),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_tinggi / 2),
                        color: theme.colorScheme.primary.withValues(
                          alpha: gelap ? .24 : .16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      children: [
                        for (final d in data)
                          Expanded(
                            child: _SelRingan(
                              d: d,
                              aktif: d.urutan == indeks,
                              warna: d.urutan == indeks
                                  ? warnaAktif
                                  : warnaPasif,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SelRingan extends StatelessWidget {
  const _SelRingan({required this.d, required this.aktif, required this.warna});

  final _DataTab d;
  final bool aktif;
  final Color warna;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: aktif,
      label: d.nilai == null ? d.label : '${d.label}, ${d.nilai}',
      excludeSemantics: true,
      onTap: () => Navigasi.bukaTab(d.urutan),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => Navigasi.bukaTab(d.urutan),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              KeyedSubtree(
                key: ValueKey('nav.${d.kunci}'),
                child: d.isi(warna, aktif),
              ),
              if (aktif)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    d.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: warna,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

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
