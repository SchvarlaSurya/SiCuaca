import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../providers/pengaturan_provider.dart';
import '../widgets/app_chrome.dart';
import '../widgets/pencet_lembut.dart';

/// Mengatur urutan bagian Beranda. Bisa diseret (gagang di kanan) atau
/// memakai tombol panah, supaya tetap bisa dipakai tanpa gestur seret.
/// Perubahan langsung tersimpan.
class UrutanBerandaScreen extends StatelessWidget {
  const UrutanBerandaScreen({super.key});

  static String _nama(AppLocalizations l, SeksiBeranda s) => switch (s) {
    SeksiBeranda.cuaca => l.cuacaSaatIni,
    SeksiBeranda.gempa => l.gempaTerbaruJudul,
    SeksiBeranda.peringatan => l.navPeringatan,
    SeksiBeranda.siaga => l.siagaJudul,
  };

  static IconData _ikon(SeksiBeranda s) => switch (s) {
    SeksiBeranda.cuaca => IkonApp.cuaca,
    SeksiBeranda.gempa => IkonApp.gempa,
    SeksiBeranda.peringatan => IkonApp.peringatan,
    SeksiBeranda.siaga => IkonApp.siaga,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pengaturan = context.watch<PengaturanProvider>();
    final urutan = pengaturan.urutanBeranda;
    final scheme = Theme.of(context).colorScheme;

    void pindah(int dari, int ke) {
      if (ke < 0 || ke >= urutan.length) return;
      final baru = [...urutan];
      baru.insert(ke, baru.removeAt(dari));
      pengaturan.aturUrutanBeranda(baru);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.urutanBerandaJudul)),
      body: LatarAtmosfer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              l.urutanBerandaKeterangan,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderItem: pindah,
              children: [
                for (final (i, s) in urutan.indexed)
                  Padding(
                    key: ValueKey(s),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            IkonDuo(_ikon(s), color: scheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _nama(l, s),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            IconButton(
                              tooltip: l.naikkanBagian(_nama(l, s)),
                              onPressed: i == 0 ? null : () => pindah(i, i - 1),
                              icon: const IkonDuo(IkonApp.naik),
                            ),
                            IconButton(
                              tooltip: l.turunkanBagian(_nama(l, s)),
                              onPressed: i == urutan.length - 1
                                  ? null
                                  : () => pindah(i, i + 1),
                              icon: const IkonDuo(IkonApp.turun),
                            ),
                            ReorderableDragStartListener(
                              index: i,
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: IkonDuo(IkonApp.geser),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: PencetLembut(
                child: OutlinedButton.icon(
                  onPressed: pengaturan.urutanBerandaBawaan
                      ? null
                      : pengaturan.setelUlangUrutanBeranda,
                  icon: const IkonDuo(IkonApp.setelUlang),
                  label: Text(l.setelUlangUrutan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
