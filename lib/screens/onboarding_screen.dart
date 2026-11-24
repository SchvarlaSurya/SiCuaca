import 'package:flutter/material.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../widgets/app_chrome.dart';
import '../widgets/pencet_lembut.dart';

/// Halaman pembuka (onboarding) yang ditampilkan saat pertama kali aplikasi
/// dibuka. Mengenalkan empat hal: prakiraan cuaca BMKG, info dan notifikasi
/// gempa, Siap Siaga, serta pemilihan wilayah di seluruh Indonesia. Halaman
/// terakhir menegaskan sumber data BMKG dan bahwa SiCuaca bukan aplikasi resmi.
///
/// Geraknya: ilustrasi bergeser sedikit mengikuti jari (paralaks) dan memudar
/// saat halaman berganti, teks masuk berurutan, dan ilustrasi "bernapas"
/// pelan beberapa kali lalu berhenti. Semua gerak mati bila pengguna memilih
/// "kurangi gerakan".
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSelesai});

  final VoidCallback onSelesai;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _jumlahHalaman = 4;

  final PageController _pageController = PageController();

  /// Gerak "bernapas" ilustrasi. Terbatas (3 kali bolak-balik) supaya tidak
  /// menjalankan animasi tanpa henti.
  late final AnimationController _napas;

  int _halamanAktif = 0;
  bool _napasDimulai = false;

  @override
  void initState() {
    super.initState();
    _napas = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_napasDimulai) return;
    _napasDimulai = true;
    if (!MediaQuery.of(context).disableAnimations) {
      _napas.repeat(reverse: true, count: 6);
    }
  }

  @override
  void dispose() {
    _napas.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _halamanBerikutnya() {
    if (_halamanAktif < _jumlahHalaman - 1) {
      // Hormati "kurangi gerakan": langsung lompat tanpa animasi geser.
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(_halamanAktif + 1);
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onSelesai();
    }
  }

  /// Posisi halaman yang sedang digeser (pecahan), aman sebelum terpasang.
  double _posisi() {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      return _pageController.page ?? _halamanAktif.toDouble();
    }
    return _halamanAktif.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tanpaGerak = MediaQuery.of(context).disableAnimations;

    final daftarSlide = [
      _SlideData(
        ikon: IkonApp.cuaca,
        warnaIkon: scheme.onTertiaryContainer,
        warnaLatarIkon: scheme.tertiaryContainer,
        judul: l.onboardingCuacaJudul,
        deskripsi: l.onboardingCuacaDeskripsi,
      ),
      _SlideData(
        ikon: IkonApp.gempa,
        warnaIkon: scheme.onSecondaryContainer,
        warnaLatarIkon: scheme.secondaryContainer,
        judul: l.onboardingGempaJudul,
        deskripsi: l.onboardingGempaDeskripsi,
      ),
      _SlideData(
        ikon: IkonApp.siaga,
        warnaIkon: scheme.primary,
        warnaLatarIkon: scheme.surfaceContainerHigh,
        judul: l.onboardingSiagaJudul,
        deskripsi: l.onboardingSiagaDeskripsi,
      ),
      _SlideData(
        ikon: IkonApp.koordinat,
        warnaIkon: scheme.primary,
        warnaLatarIkon: scheme.primaryContainer,
        judul: l.onboardingWilayahJudul,
        deskripsi: l.onboardingWilayahDeskripsi,
        catatan: l.onboardingSumber,
      ),
    ];

    final adalahHalamanTerakhir = _halamanAktif == daftarSlide.length - 1;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: LatarAtmosfer(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AnimatedSwitcher(
                      duration: tanpaGerak
                          ? Duration.zero
                          : const Duration(milliseconds: 200),
                      child: adalahHalamanTerakhir
                          ? const SizedBox.shrink()
                          : TextButton(
                              onPressed: widget.onSelesai,
                              child: Text(
                                l.onboardingLewati,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: daftarSlide.length,
                  onPageChanged: (index) {
                    setState(() => _halamanAktif = index);
                  },
                  itemBuilder: (context, index) {
                    final data = daftarSlide[index];
                    // Bisa digulir supaya tidak meluap di layar kecil atau
                    // huruf besar.
                    return LayoutBuilder(
                      builder: (context, batas) => SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: batas.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: Listenable.merge([
                                  _pageController,
                                  _napas,
                                ]),
                                builder: (context, _) => _Ilustrasi(
                                  data: data,
                                  selisih: _posisi() - index,
                                  napas: tanpaGerak ? 0 : _napas.value,
                                ),
                              ),
                              const SizedBox(height: 36),
                              MasukLembut(
                                delay: const Duration(milliseconds: 60),
                                child: Text(
                                  data.judul,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: scheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              MasukLembut(
                                delay: const Duration(milliseconds: 140),
                                child: Text(
                                  data.deskripsi,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              if (data.catatan != null) ...[
                                const SizedBox(height: 20),
                                MasukLembut(
                                  delay: const Duration(milliseconds: 220),
                                  child: Text(
                                    data.catatan!,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        daftarSlide.length,
                        (index) => AnimatedContainer(
                          duration: tanpaGerak
                              ? Duration.zero
                              : const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _halamanAktif == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _halamanAktif == index
                                ? scheme.primary
                                : scheme.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PencetLembut(
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusTile,
                              ),
                            ),
                          ),
                          onPressed: _halamanBerikutnya,
                          child: AnimatedSwitcher(
                            duration: tanpaGerak
                                ? Duration.zero
                                : const Duration(milliseconds: 200),
                            child: Text(
                              adalahHalamanTerakhir
                                  ? l.onboardingMulai
                                  : l.onboardingLanjut,
                              key: ValueKey(adalahHalamanTerakhir),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: scheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustrasi satu halaman: lingkaran berisi ikon dengan dua cincin tipis yang
/// bernapas. [selisih] = posisi halaman saat ini dikurangi indeks halaman ini
/// (0 saat tepat di layar, +/-1 saat tergeser penuh); dipakai untuk paralaks
/// dan memudar.
class _Ilustrasi extends StatelessWidget {
  const _Ilustrasi({
    required this.data,
    required this.selisih,
    required this.napas,
  });

  final _SlideData data;
  final double selisih;
  final double napas;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final jauh = selisih.abs().clamp(0.0, 1.0);
    final cincin = scheme.primary.withValues(alpha: .16);

    Widget lingkaran(double ukuran, double alpha) => Container(
      width: ukuran,
      height: ukuran,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cincin.withValues(alpha: alpha), width: 1.5),
      ),
    );

    return Opacity(
      opacity: 1 - jauh,
      child: Transform.translate(
        // Ilustrasi bergerak lebih cepat dari teks, memberi kesan kedalaman.
        offset: Offset(-selisih * 90, 0),
        child: SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + .05 * napas,
                child: lingkaran(228, .5),
              ),
              Transform.scale(
                scale: 1 + .03 * napas,
                child: lingkaran(184, .9),
              ),
              Transform.translate(
                offset: Offset(0, -6 * napas),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: data.warnaLatarIkon,
                    shape: BoxShape.circle,
                  ),
                  child: IkonDuo(data.ikon, size: 72, color: data.warnaIkon),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.ikon,
    required this.warnaIkon,
    required this.warnaLatarIkon,
    required this.judul,
    required this.deskripsi,
    this.catatan,
  });

  final IconData ikon;
  final Color warnaIkon;
  final Color warnaLatarIkon;
  final String judul;
  final String deskripsi;
  final String? catatan;
}
