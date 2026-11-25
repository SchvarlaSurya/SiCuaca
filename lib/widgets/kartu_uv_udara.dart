import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/format.dart';
import '../core/ikon.dart';
import '../core/l10n.dart';
import '../core/theme.dart';
import '../core/uv.dart';
import '../models/kualitas_udara.dart';
import '../models/prakiraan.dart';
import '../providers/kualitas_udara_provider.dart';
import 'app_chrome.dart';
import 'kartu_kaca.dart';

const _warnaUv = [
  Color(0xFF4EB400),
  Color(0xFFF7E400),
  Color(0xFFF85900),
  Color(0xFFD8001D),
  Color(0xFF6B49C8),
];

const _warnaAqi = [
  Color(0xFF00B83F),
  Color(0xFFE6C700),
  Color(0xFFFF7E00),
  Color(0xFFE60000),
  Color(0xFF8F3F97),
  Color(0xFF7E0023),
];

String namaKategoriUv(AppLocalizations l, KategoriUv k) => switch (k) {
  KategoriUv.rendah => l.uvRendah,
  KategoriUv.sedang => l.uvSedang,
  KategoriUv.tinggi => l.uvTinggi,
  KategoriUv.sangatTinggi => l.uvSangatTinggi,
  KategoriUv.ekstrem => l.uvEkstrem,
};

String saranUv(AppLocalizations l, KategoriUv k) => switch (k) {
  KategoriUv.rendah => l.uvSaranRendah,
  KategoriUv.sedang => l.uvSaranSedang,
  KategoriUv.tinggi => l.uvSaranTinggi,
  KategoriUv.sangatTinggi => l.uvSaranSangatTinggi,
  KategoriUv.ekstrem => l.uvSaranEkstrem,
};

String namaKategoriAqi(AppLocalizations l, KategoriAqi k) => switch (k) {
  KategoriAqi.baik => l.aqiBaik,
  KategoriAqi.sedang => l.aqiSedang,
  KategoriAqi.sensitif => l.aqiSensitif,
  KategoriAqi.tidakSehat => l.aqiTidakSehat,
  KategoriAqi.sangatTidakSehat => l.aqiSangatTidakSehat,
  KategoriAqi.berbahaya => l.aqiBerbahaya,
};

String saranAqi(AppLocalizations l, KategoriAqi k) => switch (k) {
  KategoriAqi.baik => l.aqiSaranBaik,
  KategoriAqi.sedang => l.aqiSaranSedang,
  KategoriAqi.sensitif => l.aqiSaranSensitif,
  KategoriAqi.tidakSehat => l.aqiSaranTidakSehat,
  KategoriAqi.sangatTidakSehat => l.aqiSaranSangatTidakSehat,
  KategoriAqi.berbahaya => l.aqiSaranBerbahaya,
};

/// Posisi 0..1 penanda pada skala AQI yang dibagi enam ruas sama lebar.
double posisiAqi(int aqi) {
  const batas = [0, 50, 100, 150, 200, 300, 500];
  final n = aqi.clamp(0, 500);
  for (var i = 0; i < 6; i++) {
    if (n <= batas[i + 1]) {
      final f = (n - batas[i]) / (batas[i + 1] - batas[i]);
      return (i + f.clamp(0.0, 1.0)) / 6;
    }
  }
  return 1;
}

/// Kartu Indeks UV: perkiraan SiCuaca dari posisi matahari dan tutupan awan
/// BMKG (bukan data layanan luar). Punya label sumbernya sendiri.
class KartuUv extends StatelessWidget {
  const KartuUv({
    super.key,
    required this.lat,
    required this.lon,
    required this.prakiraan,
    required this.terdekat,
    required this.hariSetempat,
    required this.selisih,
  });

  final double lat;
  final double lon;
  final Prakiraan prakiraan;
  final EntriPrakiraan terdekat;

  /// Jam dinding setempat sekarang (DateTime UTC yang sudah digeser zona).
  final DateTime hariSetempat;
  final Duration selisih;

  @override
  Widget build(BuildContext context) {
    return KartuKaca(
      padding: const EdgeInsets.all(16),
      child: _BagianUv(
        lat: lat,
        lon: lon,
        prakiraan: prakiraan,
        terdekat: terdekat,
        hariSetempat: hariSetempat,
        selisih: selisih,
      ),
    );
  }
}

/// Kartu kualitas udara dari Open-Meteo (model CAMS): bukan data BMKG dan
/// diberi label sumbernya sendiri. Memuat datanya saat kartu tampil.
class KartuUdara extends StatefulWidget {
  const KartuUdara({super.key, required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  State<KartuUdara> createState() => _KartuUdaraState();
}

class _KartuUdaraState extends State<KartuUdara> {
  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void didUpdateWidget(KartuUdara lama) {
    super.didUpdateWidget(lama);
    if (lama.lat != widget.lat || lama.lon != widget.lon) _muat();
  }

  void _muat() {
    // Sesudah frame ini: provider memberi tahu pendengar saat mulai memuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<KualitasUdaraProvider>().muat(widget.lat, widget.lon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return KartuKaca(
      padding: const EdgeInsets.all(16),
      child: _BagianUdara(lat: widget.lat, lon: widget.lon),
    );
  }
}

/// Tautan ke halaman Udara dan UV, dipasang di layar Cuaca (isinya sendiri
/// tidak ditampilkan di sana).
class TautanUdaraUv extends StatelessWidget {
  const TautanUdaraUv({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: '${l.udaraUvJudul}. ${l.udaraUvTautanKet}',
      excludeSemantics: true,
      child: TekanLembut(
        borderRadius: BorderRadius.circular(AppTheme.radiusKartu),
        onTap: onTap,
        child: KartuKaca(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              IkonDuo(IkonApp.udara, size: 26, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.udaraUvJudul, style: theme.textTheme.titleSmall),
                    Text(
                      l.udaraUvTautanKet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IkonDuo(
                IkonApp.selengkapnya,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kepala extends StatelessWidget {
  const _Kepala({required this.ikon, required this.judul});

  final IconData ikon;
  final String judul;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IkonDuo(ikon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(judul, style: theme.textTheme.labelLarge)),
      ],
    );
  }
}

class _Skala extends StatelessWidget {
  const _Skala({required this.warna, required this.posisi});

  final List<Color> warna;

  /// 0..1 dari kiri.
  final double posisi;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, c) {
          final x = (c.maxWidth * posisi.clamp(0.0, 1.0)).clamp(
            6.0,
            c.maxWidth - 6,
          );
          return Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  for (final w in warna)
                    Expanded(
                      child: Container(
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: .75),
                        decoration: BoxDecoration(
                          color: w,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: x - 6,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1B2540),
                      width: 2,
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
}

class _BagianUv extends StatelessWidget {
  const _BagianUv({
    required this.lat,
    required this.lon,
    required this.prakiraan,
    required this.terdekat,
    required this.hariSetempat,
    required this.selisih,
  });

  final double lat;
  final double lon;
  final Prakiraan prakiraan;
  final EntriPrakiraan terdekat;
  final DateTime hariSetempat;
  final Duration selisih;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sekarangUtc = hariSetempat.subtract(selisih);
    final uvi = Uv.perkiraan(
      lat: lat,
      lon: lon,
      utc: sekarangUtc,
      tutupanAwanPersen: terdekat.tutupanAwan,
    );
    final siang = Uv.langitCerah(lat: lat, lon: lon, utc: sekarangUtc) > 0;
    final kategori = Uv.kategori(uvi);

    final titik = [
      for (final e in prakiraan.hari.expand((h) => h))
        if (e.waktuUtc != null) (utc: e.waktuUtc!, awan: e.tutupanAwan),
    ]..sort((a, b) => a.utc.compareTo(b.utc));
    final puncak = Uv.puncak(
      lat: lat,
      lon: lon,
      tanggalSetempat: hariSetempat,
      selisih: selisih,
      titikAwan: titik,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Kepala(ikon: IkonApp.cerah, judul: l.uvJudul),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                namaKategoriUv(l, kategori),
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 10),
            if (siang)
              Text(
                l.uvPerkiraan(uvi.round()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _Skala(warna: _warnaUv, posisi: uvi / 12),
        const SizedBox(height: 10),
        Text(
          siang ? saranUv(l, kategori) : l.uvMalam,
          style: theme.textTheme.bodyMedium,
        ),
        if (puncak != null) ...[
          const SizedBox(height: 6),
          Text(
            l.uvPuncak(
              namaKategoriUv(l, Uv.kategori(puncak.uvi)),
              Format.jam(puncak.waktuSetempat),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l.uvCatatan,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _BagianUdara extends StatelessWidget {
  const _BagianUdara({required this.lat, required this.lon});

  final double lat;
  final double lon;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = context.watch<KualitasUdaraProvider>();
    final redup = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    Widget isi;
    switch (p.status) {
      case StatusUdara.awal:
      case StatusUdara.memuat:
        isi = Row(
          children: [
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l.udaraMemuat, style: redup)),
          ],
        );
      case StatusUdara.gagal:
        isi = Row(
          children: [
            Expanded(child: Text(l.udaraGagal, style: redup)),
            TextButton(
              onPressed: () => p.muat(lat, lon, paksa: true),
              child: Text(l.cobaLagi),
            ),
          ],
        );
      case StatusUdara.berhasil:
        final d = p.data!;
        final u = d.data;
        final kategori = u.kategori;
        if (kategori == null || u.usAqi == null) {
          isi = Text(l.udaraGagal, style: redup);
        } else {
          isi = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      namaKategoriAqi(l, kategori),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(l.aqiNilai(u.usAqi!), style: redup),
                ],
              ),
              const SizedBox(height: 10),
              _Skala(warna: _warnaAqi, posisi: posisiAqi(u.usAqi!)),
              const SizedBox(height: 10),
              Text(saranAqi(l, kategori), style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text(
                [
                  if (u.pm25 != null) l.udaraPm25(Format.desimal(l, u.pm25)),
                  if (u.waktu != null) l.udaraWaktuModel(Format.jam(u.waktu)),
                ].join(' · '),
                style: redup,
              ),
              if (d.dariCache) ...[
                const SizedBox(height: 4),
                Text(l.udaraDataTersimpan, style: redup),
              ],
            ],
          );
        }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Kepala(ikon: IkonApp.udara, judul: l.udaraJudul),
        const SizedBox(height: 10),
        isi,
        const SizedBox(height: 8),
        Text(
          l.udaraSumber,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
