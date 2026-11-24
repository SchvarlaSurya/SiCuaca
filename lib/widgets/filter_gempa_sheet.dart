import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../providers/riwayat_gempa_provider.dart';
import 'pencet_lembut.dart';

/// Membuka lembar filter riwayat. Mengembalikan saringan baru bila pengguna
/// menekan "Terapkan" atau "Setel ulang"; null bila ditutup tanpa memilih.
Future<FilterRiwayat?> bukaFilterRiwayat(
  BuildContext context, {
  required FilterRiwayat awal,
  required bool adaLokasi,
  RentangData? rentang,
}) {
  return showModalBottomSheet<FilterRiwayat>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        FilterGempaSheet(awal: awal, adaLokasi: adaLokasi, rentang: rentang),
  );
}

/// Filter riwayat: rentang tanggal, magnitudo minimum, jarak maksimum.
/// Saringan jarak dinonaktifkan (dengan penjelasan) bila lokasi pengguna
/// belum diketahui.
class FilterGempaSheet extends StatefulWidget {
  const FilterGempaSheet({
    super.key,
    required this.awal,
    required this.adaLokasi,
    this.rentang,
  });

  final FilterRiwayat awal;
  final bool adaLokasi;

  /// Rentang data yang tersimpan; membatasi pemilih tanggal.
  final RentangData? rentang;

  @override
  State<FilterGempaSheet> createState() => _FilterGempaSheetState();
}

class _FilterGempaSheetState extends State<FilterGempaSheet> {
  late FilterRiwayat _f = widget.awal;

  static const _magnitudo = [4.0, 5.0, 6.0, 7.0];
  static const _jarak = [50.0, 100.0, 250.0, 500.0, 1000.0];
  static const _hari = [7, 14, 30];

  DateTime get _hariIni {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime _mulaiHari(int n) => _hariIni.subtract(Duration(days: n - 1));

  bool _hariTerpilih(int n) => _f.selesai == null && _f.mulai == _mulaiHari(n);

  Future<void> _pilihTanggal() async {
    final l = context.l10n;
    final batasAkhir = _hariIni;
    final batasAwal = widget.rentang == null
        ? batasAkhir.subtract(const Duration(days: 30))
        : DateTime(
            widget.rentang!.tertua.year,
            widget.rentang!.tertua.month,
            widget.rentang!.tertua.day,
          );
    final awalPilih = DateTimeRange(
      start: _f.mulai ?? batasAwal,
      end: _f.selesai ?? batasAkhir,
    );
    final dalamBatas =
        !awalPilih.start.isBefore(batasAwal) &&
        !awalPilih.end.isAfter(batasAkhir) &&
        !awalPilih.start.isAfter(awalPilih.end);
    final hasil = await showDateRangePicker(
      context: context,
      firstDate: batasAwal.isAfter(batasAkhir) ? batasAkhir : batasAwal,
      lastDate: batasAkhir,
      initialDateRange: _f.rentangTanggal && dalamBatas ? awalPilih : null,
      helpText: l.filterPilihTanggalBantuan,
      locale: Locale(l.localeName),
    );
    if (hasil == null || !mounted) return;
    setState(
      () => _f = FilterRiwayat(
        mulai: hasil.start,
        selesai: hasil.end,
        magnitudoMin: _f.magnitudoMin,
        jarakMaksKm: _f.jarakMaksKm,
        kataKunci: _f.kataKunci,
      ),
    );
  }

  void _atur({
    DateTime? mulai,
    bool ubahTanggal = false,
    double? magnitudo,
    bool ubahMagnitudo = false,
    double? jarak,
    bool ubahJarak = false,
  }) {
    setState(
      () => _f = FilterRiwayat(
        mulai: ubahTanggal ? mulai : _f.mulai,
        selesai: ubahTanggal ? null : _f.selesai,
        magnitudoMin: ubahMagnitudo ? magnitudo : _f.magnitudoMin,
        jarakMaksKm: ubahJarak ? jarak : _f.jarakMaksKm,
        kataKunci: _f.kataKunci,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tgl = DateFormat('d MMM yyyy', l.localeName);
    // Rentang yang bukan salah satu pilihan "N hari terakhir".
    final kustom = _f.rentangTanggal && !_hari.any(_hariTerpilih);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.filterJudul, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _Judul(l.filterTanggal),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.filterSemuaTanggal),
                  selected: !_f.rentangTanggal,
                  onSelected: (_) => _atur(ubahTanggal: true),
                ),
                for (final n in _hari)
                  ChoiceChip(
                    label: Text(l.filterHariTerakhir('$n')),
                    selected: _hariTerpilih(n),
                    onSelected: (_) =>
                        _atur(ubahTanggal: true, mulai: _mulaiHari(n)),
                  ),
                ChoiceChip(
                  avatar: const IkonDuo(IkonApp.waktu, size: 18),
                  label: Text(
                    kustom && _f.mulai != null && _f.selesai != null
                        ? '${tgl.format(_f.mulai!)} – ${tgl.format(_f.selesai!)}'
                        : l.filterPilihTanggal,
                  ),
                  selected: kustom,
                  onSelected: (_) => _pilihTanggal(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _Judul(l.filterMagnitudo),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.semuaMagnitudo),
                  selected: _f.magnitudoMin == null,
                  onSelected: (_) => _atur(ubahMagnitudo: true),
                ),
                for (final m in _magnitudo)
                  ChoiceChip(
                    label: Text(l.minimalMagnitudo(m.toStringAsFixed(1))),
                    selected: _f.magnitudoMin == m,
                    onSelected: (_) => _atur(ubahMagnitudo: true, magnitudo: m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _Judul(l.filterJarak),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l.filterSemuaJarak),
                  selected: _f.jarakMaksKm == null,
                  onSelected: widget.adaLokasi
                      ? (_) => _atur(ubahJarak: true)
                      : null,
                ),
                for (final j in _jarak)
                  ChoiceChip(
                    label: Text(l.filterJarakKm(j.toStringAsFixed(0))),
                    selected: _f.jarakMaksKm == j,
                    onSelected: widget.adaLokasi
                        ? (_) => _atur(ubahJarak: true, jarak: j)
                        : null,
                  ),
              ],
            ),
            if (!widget.adaLokasi) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IkonDuo(IkonApp.lokasiMati, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.filterJarakNonaktif,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PencetLembut(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pop(const FilterRiwayat()),
                      child: Text(l.filterSetelUlang),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PencetLembut(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(_f),
                      child: Text(l.filterTerapkan),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  const _Judul(this.teks);

  final String teks;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Semantics(
      header: true,
      child: Text(teks, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

/// Ringkas satu saringan aktif jadi teks pendek untuk chip di layar.
String ringkasTanggal(AppLocalizations l, FilterRiwayat f) {
  final fmt = DateFormat('d MMM', l.localeName);
  final a = f.mulai;
  final b = f.selesai;
  if (a != null && b != null) return '${fmt.format(a)} – ${fmt.format(b)}';
  if (a != null) return '${fmt.format(a)} –';
  if (b != null) return '– ${fmt.format(b)}';
  return l.filterSemuaTanggal;
}
