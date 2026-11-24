import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/navigasi.dart';
import '../services/riwayat_notifikasi_service.dart';
import '../widgets/app_chrome.dart';
import '../widgets/badge_magnitudo.dart';
import '../widgets/status_data.dart';
import '../widgets/pencet_lembut.dart';
import '../widgets/tombol_kaca.dart';

/// Riwayat notifikasi gempa yang pernah diterima perangkat (tersimpan lokal,
/// maksimal 50). Diketuk membuka detail gempa; tarik untuk menyegarkan.
class RiwayatNotifikasiScreen extends StatefulWidget {
  const RiwayatNotifikasiScreen({super.key, this.layanan});

  /// Bisa diganti saat pengujian.
  final RiwayatNotifikasiService? layanan;

  @override
  State<RiwayatNotifikasiScreen> createState() =>
      _RiwayatNotifikasiScreenState();
}

class _RiwayatNotifikasiScreenState extends State<RiwayatNotifikasiScreen> {
  late final RiwayatNotifikasiService _layanan =
      widget.layanan ?? RiwayatNotifikasiService();
  List<CatatanNotifikasi>? _daftar;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final hasil = await _layanan.baca();
    if (mounted) setState(() => _daftar = hasil);
  }

  Future<void> _hapusSemua() async {
    final l = context.l10n;
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.hapusRiwayat),
        content: Text(l.hapusRiwayatKonfirmasi),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.aksiBatal),
          ),
          PencetLembut(
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l.aksiHapus),
            ),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    await _layanan.hapusSemua();
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final daftar = _daftar;
    final theme = Theme.of(context);

    final Widget isi;
    if (daftar == null) {
      isi = Padding(
        padding: const EdgeInsets.all(16),
        child: MemuatData(pesan: l.memuatGempa, bentuk: BentukKerangka.daftar),
      );
    } else if (daftar.isEmpty) {
      isi = Center(child: KosongData(pesan: l.riwayatNotifKosong));
    } else {
      isi = RefreshIndicator(
        onRefresh: _muat,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: daftar.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final c = daftar[i];
            final g = c.gempa;
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigasi.bukaDetailGempa(g),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BadgeMagnitudo(
                        magnitudo: g.magnitudoAngka,
                        teks: g.magnitudo,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              g.wilayah.isEmpty
                                  ? Format.tandaKosong
                                  : g.wilayah,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Format.waktuLengkap(l, g.waktuUtc),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              l.diterimaWaktu(
                                Format.waktuRelatif(
                                  l,
                                  c.diterima,
                                  DateTime.now(),
                                ),
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const IkonDuo(IkonApp.selengkapnya),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.riwayatNotifJudul),
        actions: [
          GrupTombolKaca(
            children: [
              if (daftar != null && daftar.isNotEmpty)
                TombolKaca(
                  tooltip: l.hapusRiwayat,
                  onPressed: _hapusSemua,
                  icon: const IkonDuo(IkonApp.hapusSemua),
                ),
            ],
          ),
        ],
      ),
      body: LatarAtmosfer(child: isi),
    );
  }
}
