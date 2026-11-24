import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../models/maritim.dart';
import '../providers/maritim_provider.dart';
import '../widgets/ajak_lokasi.dart';
import '../widgets/app_chrome.dart';
import '../widgets/pencet_lembut.dart';
import '../widgets/status_data.dart';
import '../widgets/sumber_bmkg.dart';
import '../widgets/tombol_kaca.dart';

/// Cuaca maritim satu wilayah perairan dari API resmi BMKG: tinggi dan
/// kategori gelombang (label teks BMKG, bukan hanya warna), angin, arus, dan
/// cuaca, untuk sekarang dan beberapa hari ke depan.
class MaritimScreen extends StatefulWidget {
  const MaritimScreen({super.key});

  @override
  State<MaritimScreen> createState() => _MaritimScreenState();
}

class _MaritimScreenState extends State<MaritimScreen> {
  @override
  void initState() {
    super.initState();
    // Data segar diambil dari cache (TTL), jadi membuka layar berulang tidak
    // memanggil BMKG berulang.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<MaritimProvider>().muat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final p = context.watch<MaritimProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.layananMaritimJudul),
        actions: [
          GrupTombolKaca(
            children: [
              TombolKaca(
                tooltip: l.maritimPilihPerairan,
                icon: const IkonDuo(IkonApp.peta),
                onPressed: () => bukaPilihPerairan(context),
              ),
            ],
          ),
        ],
      ),
      body: LatarAtmosfer(
        gelap: false,
        child: RefreshIndicator(
          onRefresh: p.muat,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              ..._isi(context, p),
              const SizedBox(height: 16),
              if (p.data?.data.terbit case final terbit?)
                Text(
                  l.maritimDiterbitkan(Format.waktuSingkat(l, terbit)),
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 4),
              Text(
                l.maritimCatatanKategori,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              const SumberBmkg(),
              const SizedBox(height: 4),
              Text(
                l.bukanResmi,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _isi(BuildContext context, MaritimProvider p) {
    final l = context.l10n;
    switch (p.status) {
      case StatusMaritim.awal:
      case StatusMaritim.memuat:
        return [
          MemuatData(pesan: l.maritimMemuat, bentuk: BentukKerangka.kartu),
        ];
      case StatusMaritim.perluPilih:
        return [
          KosongData(pesan: l.maritimPerluPilih),
          const AjakLokasi(),
          const SizedBox(height: 12),
          PencetLembut(
            child: FilledButton.icon(
              onPressed: () => bukaPilihPerairan(context),
              icon: const IkonDuo(IkonApp.peta),
              label: Text(l.maritimPilihPerairan),
            ),
          ),
        ];
      case StatusMaritim.gagal:
        return [
          GagalMuat(
            pesan: '${l.maritimGagal} ${l.pesanGalat(p.galat)}',
            onCobaLagi: p.muat,
            aksiTambahan: PencetLembut(
              child: OutlinedButton(
                onPressed: () => bukaPilihPerairan(context),
                child: Text(l.maritimPilihPerairan),
              ),
            ),
          ),
        ];
      case StatusMaritim.berhasil:
        break;
    }
    final data = p.data!;
    final prakiraan = data.data;
    final sekarang = DateTime.now();
    final mendatang = prakiraan.mulaiDari(sekarang);
    final saatIni = mendatang.first;
    final batas24 = saatIni.waktuUtc.add(const Duration(hours: 24));
    final perJam = mendatang
        .where((e) => e.waktuUtc.isBefore(batas24))
        .skip(1)
        .toList();
    final berikutnya = mendatang
        .where((e) => !e.waktuUtc.isBefore(batas24))
        .toList();

    return [
      if (data.dariCache) BannerOffline(diperbarui: data.diperbarui),
      MasukLembut(
        child: _KepalaPerairan(
          nama: prakiraan.nama,
          keterangan: switch (p.asal) {
            AsalPerairan.terdekat when p.jarakKm != null =>
              l.maritimPerairanTerdekat(Format.jarak(l, p.jarakKm!)),
            AsalPerairan.pilihan => l.maritimPerairanPilihan,
            _ => null,
          },
        ),
      ),
      const SizedBox(height: 12),
      MasukLembut(
        delay: const Duration(milliseconds: 60),
        child: _KartuSaatIni(entri: saatIni),
      ),
      if (perJam.isNotEmpty) ...[
        JudulBagian(l.maritimPrakiraanJam),
        _DaftarEntri(entri: perJam),
      ],
      if (berikutnya.isNotEmpty) ...[
        JudulBagian(l.maritimPrakiraanHari),
        for (final hari in _perHari(berikutnya)) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Text(
              Format.labelHari(l, hari.first.waktuUtc.toLocal(), sekarang),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          _DaftarEntri(entri: hari),
        ],
      ],
    ];
  }

  static List<List<EntriMaritim>> _perHari(List<EntriMaritim> entri) {
    final hasil = <List<EntriMaritim>>[];
    for (final e in entri) {
      final w = e.waktuUtc.toLocal();
      if (hasil.isEmpty) {
        hasil.add([e]);
        continue;
      }
      final akhir = hasil.last.last.waktuUtc.toLocal();
      if (akhir.year == w.year &&
          akhir.month == w.month &&
          akhir.day == w.day) {
        hasil.last.add(e);
      } else {
        hasil.add([e]);
      }
    }
    return hasil;
  }
}

/// Teks kategori gelombang sesuai bahasa; kategori yang tidak dikenal
/// ditampilkan apa adanya dari BMKG.
String labelGelombang(AppLocalizations l, EntriMaritim e) =>
    switch (e.tingkat) {
      TingkatGelombang.tenang => l.gelombangTenang,
      TingkatGelombang.rendah => l.gelombangRendah,
      TingkatGelombang.sedang => l.gelombangSedang,
      TingkatGelombang.tinggi => l.gelombangTinggi,
      TingkatGelombang.sangatTinggi => l.gelombangSangatTinggi,
      TingkatGelombang.ekstrem => l.gelombangEkstrem,
      TingkatGelombang.sangatEkstrem => l.gelombangSangatEkstrem,
      TingkatGelombang.tidakDikenal =>
        e.kategoriGelombang.isEmpty ? Format.tandaKosong : e.kategoriGelombang,
    };

/// Warna latar dan teks chip kategori (selalu disertai label teks).
(Color, Color) _warnaGelombang(
  TingkatGelombang t,
  ColorScheme scheme,
) => switch (t) {
  TingkatGelombang.tenang => (const Color(0xFF1D6E8C), Colors.white),
  TingkatGelombang.rendah => (const Color(0xFF1F7A5A), Colors.white),
  TingkatGelombang.sedang => (const Color(0xFFF2C14E), const Color(0xFF2B1D00)),
  TingkatGelombang.tinggi => (const Color(0xFFE07B28), const Color(0xFF2B1200)),
  TingkatGelombang.sangatTinggi => (const Color(0xFFC62828), Colors.white),
  TingkatGelombang.ekstrem => (const Color(0xFF7B1FA2), Colors.white),
  TingkatGelombang.sangatEkstrem => (const Color(0xFF4A148C), Colors.white),
  TingkatGelombang.tidakDikenal => (
    scheme.surfaceContainerHighest,
    scheme.onSurface,
  ),
};

class _ChipGelombang extends StatelessWidget {
  const _ChipGelombang({required this.entri, this.besar = false});

  final EntriMaritim entri;
  final bool besar;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final (latar, depan) = _warnaGelombang(
      entri.tingkat,
      Theme.of(context).colorScheme,
    );
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: besar ? 12 : 8,
        vertical: besar ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(besar ? 12 : 8),
      ),
      child: Text(
        labelGelombang(l, entri),
        style:
            (besar
                    ? Theme.of(context).textTheme.labelLarge
                    : Theme.of(context).textTheme.labelMedium)
                ?.copyWith(color: depan, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _KepalaPerairan extends StatelessWidget {
  const _KepalaPerairan({required this.nama, this.keterangan});

  final String nama;
  final String? keterangan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IkonDuo(IkonApp.kapal, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nama, style: theme.textTheme.titleLarge),
              if (keterangan != null)
                Text(
                  keterangan!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KartuSaatIni extends StatelessWidget {
  const _KartuSaatIni({required this.entri});

  final EntriMaritim entri;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final waktu = entri.waktuUtc.toLocal();
    final tinggi = Format.desimal(l, entri.tinggiGelombang);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.maritimSaatIni} · ${l.maritimBerlaku('${Format.jam(waktu)} ${Format.zonaPerangkat(waktu.timeZoneOffset)}')}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Semantics(
              label: l.maritimKategoriSemantik(
                labelGelombang(l, entri),
                tinggi,
              ),
              child: ExcludeSemantics(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      l.maritimMeter(tinggi),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _ChipGelombang(entri: entri, besar: true),
                  ],
                ),
              ),
            ),
            Text(
              l.maritimGelombang,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 24),
            _BarisInfo(
              ikon: IkonApp.angin,
              judul: l.maritimAngin,
              nilai: l.maritimAnginNilai(
                l.arahNama(entri.arahAngin),
                Format.desimal(l, entri.anginKnot),
                Format.desimal(l, entri.hembusanKnot),
              ),
            ),
            _BarisInfo(
              ikon: IkonApp.potensi,
              judul: l.maritimArus,
              nilai: l.maritimArusNilai(
                l.arahNama(entri.arahArus),
                Format.desimal(l, entri.arusKnot),
              ),
            ),
            _BarisInfo(
              ikon: IkonApp.cuaca,
              judul: l.maritimCuaca,
              nilai: [
                if (entri.cuaca.isNotEmpty) l.cuacaTeks(entri.cuaca),
                if (entri.suhu != null) Format.suhu(entri.suhu),
              ].join(' · '),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({
    required this.ikon,
    required this.judul,
    required this.nilai,
  });

  final IconData ikon;
  final String judul;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IkonDuo(ikon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '$judul  ', style: theme.textTheme.labelLarge),
                  TextSpan(
                    text: nilai.isEmpty ? Format.tandaKosong : nilai,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DaftarEntri extends StatelessWidget {
  const _DaftarEntri({required this.entri});

  final List<EntriMaritim> entri;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Column(
        children: [
          for (final (i, e) in entri.indexed) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      Format.jam(e.waktuUtc.toLocal()),
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _ChipGelombang(entri: e),
                            Text(
                              l.maritimMeter(
                                Format.desimal(l, e.tinggiGelombang),
                              ),
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (e.cuaca.isNotEmpty) l.cuacaTeks(e.cuaca),
                            l.maritimAnginNilai(
                              l.arahNama(e.arahAngin),
                              Format.desimal(l, e.anginKnot),
                              Format.desimal(l, e.hembusanKnot),
                            ),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Lembar pilih perairan: cari nama perairan/provinsi, atau kembali ke
/// perairan terdekat dari lokasi.
Future<void> bukaPilihPerairan(BuildContext context) {
  final p = context.read<MaritimProvider>();
  if (p.daftar == null) p.muatDaftar();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) =>
        ChangeNotifierProvider.value(value: p, child: const _LembarPilih()),
  );
}

class _LembarPilih extends StatefulWidget {
  const _LembarPilih();

  @override
  State<_LembarPilih> createState() => _LembarPilihState();
}

class _LembarPilihState extends State<_LembarPilih> {
  String _kata = '';

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.watch<MaritimProvider>();
    final tinggi = MediaQuery.sizeOf(context).height * .8;
    final daftar = p.daftar;
    final tersaring = daftar == null
        ? const <AreaPerairan>[]
        : MaritimProvider.saring(daftar, _kata);

    Widget isi;
    if (daftar == null && p.galatDaftar != null) {
      isi = ListView(
        children: [
          GagalMuat(
            pesan: '${l.maritimDaftarGagal} ${l.pesanGalat(p.galatDaftar)}',
            onCobaLagi: p.muatDaftar,
          ),
        ],
      );
    } else if (daftar == null) {
      isi = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MemuatData(
            pesan: l.maritimMemuatDaftar,
            bentuk: BentukKerangka.daftar,
          ),
        ],
      );
    } else if (tersaring.isEmpty) {
      isi = ListView(children: [KosongData(pesan: l.maritimTidakAdaHasil)]);
    } else {
      isi = ListView.builder(
        itemCount: tersaring.length,
        itemBuilder: (context, i) {
          final a = tersaring[i];
          return ListTile(
            key: ValueKey('perairan.${a.id}'),
            title: Text(a.nama),
            subtitle: Text(a.provinsi),
            selected: a.id == p.kode,
            onTap: () {
              Navigator.of(context).pop();
              p.pilih(a);
            },
          );
        },
      );
    }

    return SizedBox(
      height: tinggi,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l.maritimCariPerairan,
                  prefixIcon: const IkonDuo(IkonApp.cari),
                ),
                onChanged: (v) => setState(() => _kata = v),
              ),
            ),
            if (p.asal == AsalPerairan.pilihan)
              ListTile(
                leading: const IkonDuo(IkonApp.lokasiSaya),
                title: Text(l.maritimPakaiTerdekat),
                onTap: () {
                  Navigator.of(context).pop();
                  p.pakaiTerdekat();
                },
              ),
            Expanded(child: isi),
          ],
        ),
      ),
    );
  }
}
