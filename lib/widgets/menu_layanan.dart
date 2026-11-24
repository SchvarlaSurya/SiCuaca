import 'package:flutter/material.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../screens/layanan_screen.dart';
import 'app_chrome.dart';
import 'sumber_bmkg.dart';

/// Kisi tombol menu layanan BMKG di Beranda: menu tambahan di samping
/// navbar (menu utama). Tiap tombol langsung membuka layanannya; yang
/// bertanda ↗ membuka halaman resmi BMKG.
///
/// Tiga kolom (dua baris); di layar sempit atau huruf sangat besar menjadi
/// dua kolom supaya label tidak terpotong.
class MenuLayanan extends StatelessWidget {
  const MenuLayanan({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final semua = daftarLayanan(l);
    return LayoutBuilder(
      builder: (context, batas) {
        final skala = MediaQuery.textScalerOf(context).scale(1);
        final kolom = batas.maxWidth / skala < 270 ? 2 : 3;
        const jarak = 10.0;
        final lebar = (batas.maxWidth - jarak * (kolom - 1)) / kolom;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: jarak,
              runSpacing: jarak,
              children: [
                for (final t in semua)
                  SizedBox(
                    width: lebar,
                    child: _TombolMenu(item: t),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.menuTautanCatatan,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SumberBmkg(),
          ],
        );
      },
    );
  }
}

class _TombolMenu extends StatelessWidget {
  const _TombolMenu({required this.item});

  final ItemLayanan item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      key: ValueKey('menu.${item.kunci}'),
      button: true,
      label: item.judul,
      hint: item.tautanKeluar ? l.layananBukaResmi : null,
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: TekanLembut(
          onTap: () => item.buka(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IkonDuo(
                        item.ikon,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    if (item.tautanKeluar)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '↗',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.judul,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
