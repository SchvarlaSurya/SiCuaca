import 'package:flutter/material.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';

/// Halaman pembuka (onboarding) yang ditampilkan saat pertama kali aplikasi dibuka.
/// Mengenalkan 3 fitur inti: Prakiraan Cuaca BMKG, Informasi & Notifikasi Gempa,
/// serta kemudahan pemilihan wilayah di seluruh Indonesia.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onSelesai});

  final VoidCallback onSelesai;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _halamanAktif = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _halamanBerikutnya() {
    if (_halamanAktif < 2) {
      // Hormati "kurangi gerakan": langsung lompat tanpa animasi geser.
      if (MediaQuery.of(context).disableAnimations) {
        _pageController.jumpToPage(_halamanAktif + 1);
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onSelesai();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
        ikon: IkonApp.koordinat,
        warnaIkon: scheme.primary,
        warnaLatarIkon: scheme.primaryContainer,
        judul: l.onboardingWilayahJudul,
        deskripsi: l.onboardingWilayahDeskripsi,
      ),
    ];

    final adalahHalamanTerakhir = _halamanAktif == daftarSlide.length - 1;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          if (!adalahHalamanTerakhir)
            TextButton(
              onPressed: widget.onSelesai,
              child: Text(
                l.onboardingLewati,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                        constraints: BoxConstraints(minHeight: batas.maxHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: data.warnaLatarIkon,
                                shape: BoxShape.circle,
                              ),
                              child: IkonDuo(
                                data.ikon,
                                size: 72,
                                color: data.warnaIkon,
                              ),
                            ),
                            const SizedBox(height: 36),
                            Text(
                              data.judul,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              data.deskripsi,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
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
                        duration: MediaQuery.of(context).disableAnimations
                            ? Duration.zero
                            : const Duration(milliseconds: 250),
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
                  SizedBox(
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
                      child: Text(
                        adalahHalamanTerakhir
                            ? l.onboardingMulai
                            : l.onboardingLanjut,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.w600,
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
  });

  final IconData ikon;
  final Color warnaIkon;
  final Color warnaLatarIkon;
  final String judul;
  final String deskripsi;
}
