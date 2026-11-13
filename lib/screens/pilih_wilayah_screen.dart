import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/lokasi.dart';
import '../services/wilayah_service.dart';
import '../widgets/status_data.dart';

/// Membuka pemilih wilayah bertingkat. Hasilnya desa/kelurahan yang
/// dipilih, atau null bila dibatalkan.
Future<Lokasi?> bukaPilihWilayah(BuildContext context) {
  final wilayah = context.read<WilayahService>();
  return Navigator.of(context).push<Lokasi>(
    MaterialPageRoute(builder: (_) => PilihWilayahScreen(wilayah: wilayah)),
  );
}

/// Provinsi → kabupaten/kota → kecamatan → desa/kelurahan, dari dataset
/// wilayah lokal yang sama dengan pencarian nama.
class PilihWilayahScreen extends StatefulWidget {
  const PilihWilayahScreen({super.key, required this.wilayah});

  final WilayahService wilayah;

  @override
  State<PilihWilayahScreen> createState() => _PilihWilayahScreenState();
}

class _PilihWilayahScreenState extends State<PilihWilayahScreen> {
  IndeksWilayah? _indeks;
  bool _gagal = false;

  /// Simpul yang sudah dipilih, dari provinsi ke bawah.
  final List<SimpulWilayah> _jejak = [];
  final TextEditingController _saring = TextEditingController();

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    setState(() => _gagal = false);
    try {
      final indeks = await widget.wilayah.muat();
      if (mounted) setState(() => _indeks = indeks);
    } catch (_) {
      if (mounted) setState(() => _gagal = true);
    }
  }

  @override
  void dispose() {
    _saring.dispose();
    super.dispose();
  }

  void _masuk(SimpulWilayah simpul) {
    if (simpul.desa) {
      Navigator.of(context).pop(_indeks?.desaDenganKode(simpul.kode));
      return;
    }
    setState(() {
      _jejak.add(simpul);
      _saring.clear();
    });
  }

  void _kembaliKe(int panjang) {
    setState(() {
      _jejak.removeRange(panjang, _jejak.length);
      _saring.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final judul = [
      l.pilihProvinsi,
      l.pilihKabKota,
      l.pilihKecamatan,
      l.pilihDesa,
    ][_jejak.length.clamp(0, 3)];
    final indeks = _indeks;

    final Widget isi;
    if (_gagal) {
      isi = Padding(
        padding: const EdgeInsets.all(16),
        child: GagalMuat(pesan: l.gagalMemuatDataWilayah, onCobaLagi: _muat),
      );
    } else if (indeks == null) {
      isi = Padding(
        padding: const EdgeInsets.all(16),
        child: MemuatData(
          pesan: l.memuatDataWilayah,
          bentuk: BentukKerangka.daftar,
        ),
      );
    } else {
      isi = _Daftar(
        simpul: indeks.anak(_jejak.isEmpty ? '' : _jejak.last.kode),
        saring: _saring,
        onPilih: _masuk,
      );
    }

    return PopScope(
      canPop: _jejak.isEmpty,
      onPopInvokedWithResult: (sudahKeluar, _) {
        if (!sudahKeluar) _kembaliKe(_jejak.length - 1);
      },
      child: Scaffold(
        // BackButton memanggil maybePop, jadi PopScope di atas yang
        // memutuskan: naik satu tingkat atau keluar dari layar.
        appBar: AppBar(leading: const BackButton(), title: Text(judul)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Jejak(jejak: _jejak, onKembaliKe: _kembaliKe),
            Expanded(child: isi),
          ],
        ),
      ),
    );
  }
}

/// Remah roti: Indonesia › Provinsi › Kab/Kota › Kecamatan. Tiap bagian
/// bisa diketuk untuk kembali ke tingkat itu.
class _Jejak extends StatelessWidget {
  const _Jejak({required this.jejak, required this.onKembaliKe});

  final List<SimpulWilayah> jejak;
  final ValueChanged<int> onKembaliKe;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bagian = [l.semuaWilayah, for (final s in jejak) s.nama];
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (var i = 0; i < bagian.length; i++) ...[
            if (i > 0) const Icon(IkonApp.selengkapnya, size: 18),
            TextButton(
              onPressed: i == bagian.length - 1 ? null : () => onKembaliKe(i),
              child: Text(bagian[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _Daftar extends StatelessWidget {
  const _Daftar({
    required this.simpul,
    required this.saring,
    required this.onPilih,
  });

  final List<SimpulWilayah> simpul;
  final TextEditingController saring;
  final ValueChanged<SimpulWilayah> onPilih;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: saring,
      builder: (context, nilai, _) {
        final q = IndeksWilayah.normalkan(nilai.text);
        final tampil = q.isEmpty
            ? simpul
            : [
                for (final s in simpul)
                  if (IndeksWilayah.normalkan(s.nama).contains(q)) s,
              ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: saring,
                decoration: InputDecoration(
                  prefixIcon: const Icon(IkonApp.saring),
                  hintText: l.saringDaftar,
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: tampil.isEmpty
                  ? KosongData(pesan: l.cariTidakAdaHasil)
                  : ListView.separated(
                      itemCount: tampil.length,
                      separatorBuilder: (_, _) =>
                          const Divider(indent: 16, endIndent: 16),
                      itemBuilder: (context, i) {
                        final s = tampil[i];
                        return ListTile(
                          title: Text(s.nama),
                          trailing: s.desa
                              ? null
                              : const Icon(IkonApp.selengkapnya),
                          onTap: () => onPilih(s),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
