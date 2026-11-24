// Model data cuaca maritim BMKG (API publik maritim.bmkg.go.id/apidoc,
// base URL marine2026-data). Semua waktu di data BMKG dalam UTC.

/// Satu wilayah perairan (mis. P.J.03 "Teluk Jakarta").
class AreaPerairan {
  const AreaPerairan({
    required this.id,
    required this.nama,
    required this.provinsi,
  });

  final String id;
  final String nama;
  final String provinsi;

  /// Daftar perairan dari `meta/area_province.json`. Butir rusak dilewati;
  /// bentuk berkas yang tidak dikenali menghasilkan [FormatException].
  static List<AreaPerairan> daftarDariJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is! List) {
      throw const FormatException('area_province: "data" tidak ada');
    }
    final hasil = <AreaPerairan>[];
    final terlihat = <String>{};
    for (final prov in data) {
      if (prov is! Map) continue;
      final provinsi = '${prov['province'] ?? ''}'.trim();
      final areas = prov['areas'];
      if (areas is! List) continue;
      for (final a in areas) {
        if (a is! Map) continue;
        final id = '${a['id'] ?? ''}'.trim();
        final nama = '${a['name'] ?? ''}'.trim();
        if (id.isEmpty || nama.isEmpty || !terlihat.add(id)) continue;
        hasil.add(AreaPerairan(id: id, nama: nama, provinsi: provinsi));
      }
    }
    return hasil;
  }
}

/// Kategori tinggi gelombang. Labelnya diambil dari teks kategori yang
/// dikirim BMKG (`wave_cat`), bukan dihitung sendiri dari tinggi gelombang.
enum TingkatGelombang {
  tenang,
  rendah,
  sedang,
  tinggi,
  sangatTinggi,
  ekstrem,
  sangatEkstrem,
  tidakDikenal;

  static TingkatGelombang dari(String kategori) =>
      switch (kategori.trim().toLowerCase()) {
        'tenang' => tenang,
        'rendah' => rendah,
        'sedang' => sedang,
        'tinggi' => tinggi,
        'sangat tinggi' => sangatTinggi,
        'ekstrem' || 'ekstrim' => ekstrem,
        'sangat ekstrem' || 'sangat ekstrim' => sangatEkstrem,
        _ => tidakDikenal,
      };
}

/// Prakiraan satu jam (hari pertama) atau tiga jam (hari ke-2 s.d. ke-4).
class EntriMaritim {
  const EntriMaritim({
    required this.waktuUtc,
    required this.cuaca,
    required this.kategoriGelombang,
    this.tinggiGelombang,
    this.suhu,
    this.kelembapan,
    this.arahAngin = '',
    this.anginKnot,
    this.hembusanKnot,
    this.arahArus = '',
    this.arusKnot,
  });

  final DateTime waktuUtc;
  final String cuaca;

  /// Teks kategori asli BMKG, mis. "Sedang".
  final String kategoriGelombang;

  /// Meter.
  final double? tinggiGelombang;
  final double? suhu;
  final int? kelembapan;

  /// Arah asal angin, nama Indonesia dari BMKG (mis. "Barat Laut").
  final String arahAngin;
  final double? anginKnot;
  final double? hembusanKnot;

  /// Arah tujuan arus (mis. "Barat Daya").
  final String arahArus;
  final double? arusKnot;

  TingkatGelombang get tingkat => TingkatGelombang.dari(kategoriGelombang);

  static double? _angka(Object? v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');

  /// "2026-11-24 00:00 UTC" → DateTime UTC; null bila tidak terbaca.
  static DateTime? waktuDari(Object? v) {
    final teks = '${v ?? ''}'.trim().replaceAll(' UTC', '').trim();
    if (teks.isEmpty) return null;
    final iso = teks.contains('T') ? teks : teks.replaceFirst(' ', 'T');
    final w = DateTime.tryParse(iso.endsWith('Z') ? iso : '${iso}Z');
    return w?.toUtc();
  }

  /// Null bila waktunya tidak terbaca (butir dilewati).
  static EntriMaritim? dariJson(Object? json) {
    if (json is! Map) return null;
    final waktu = waktuDari(json['time']);
    if (waktu == null) return null;
    return EntriMaritim(
      waktuUtc: waktu,
      cuaca: '${json['weather'] ?? ''}'.trim(),
      kategoriGelombang: '${json['wave_cat'] ?? ''}'.trim(),
      tinggiGelombang: _angka(json['wave_height']),
      suhu: _angka(json['temp_avg']),
      kelembapan: _angka(json['rh_avg'])?.round(),
      arahAngin: '${json['wind_from'] ?? ''}'.trim(),
      anginKnot: _angka(json['wind_speed']),
      hembusanKnot: _angka(json['wind_gust']),
      arahArus: '${json['current_to'] ?? ''}'.trim(),
      arusKnot: _angka(json['current_speed']),
    );
  }
}

/// Prakiraan satu wilayah perairan (`perairan/{KODE}.json`).
///
/// Hanya data cuaca yang diambil; identitas prakirawan dan kontak stasiun
/// di berkas BMKG sengaja tidak disimpan di model.
class PrakiraanMaritim {
  const PrakiraanMaritim({
    required this.kode,
    required this.nama,
    required this.entri,
    this.terbit,
    this.berlakuDari,
    this.berlakuSampai,
  });

  final String kode;
  final String nama;

  /// Urut waktu, tanpa duplikat.
  final List<EntriMaritim> entri;
  final DateTime? terbit;
  final DateTime? berlakuDari;
  final DateTime? berlakuSampai;

  factory PrakiraanMaritim.fromJson(Map<String, dynamic> json) {
    final kode = '${json['code'] ?? ''}'.trim();
    if (kode.isEmpty) {
      throw const FormatException('perairan: "code" tidak ada');
    }
    final semua = <DateTime, EntriMaritim>{};
    for (final kunci in json.keys.where((k) => k.startsWith('forecast_'))) {
      final daftar = json[kunci];
      if (daftar is! List) continue;
      for (final butir in daftar) {
        final e = EntriMaritim.dariJson(butir);
        // Hari pertama (per jam) didahulukan bila waktunya sama.
        if (e != null) semua.putIfAbsent(e.waktuUtc, () => e);
      }
    }
    if (semua.isEmpty) {
      throw const FormatException('perairan: tidak ada prakiraan');
    }
    final entri = semua.values.toList()
      ..sort((a, b) => a.waktuUtc.compareTo(b.waktuUtc));
    return PrakiraanMaritim(
      kode: kode,
      nama: '${json['name'] ?? kode}'.trim(),
      entri: List.unmodifiable(entri),
      terbit: EntriMaritim.waktuDari(json['issued']),
      berlakuDari: EntriMaritim.waktuDari(json['valid_from']),
      berlakuSampai: EntriMaritim.waktuDari(json['valid_to']),
    );
  }

  /// Entri yang sedang berlaku pada [sekarang]: entri terakhir yang sudah
  /// dimulai; sebelum entri pertama → entri pertama.
  EntriMaritim terdekat(DateTime sekarang) {
    final t = sekarang.toUtc();
    EntriMaritim pilih = entri.first;
    for (final e in entri) {
      if (e.waktuUtc.isAfter(t)) break;
      pilih = e;
    }
    return pilih;
  }

  /// Entri mulai dari yang sedang berlaku.
  List<EntriMaritim> mulaiDari(DateTime sekarang) {
    final awal = terdekat(sekarang);
    return entri.where((e) => !e.waktuUtc.isBefore(awal.waktuUtc)).toList();
  }
}
