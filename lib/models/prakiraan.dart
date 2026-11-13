import '../core/parsing.dart';
import 'lokasi.dart';

/// Satu titik prakiraan (BMKG memberi satu entri tiap 3 jam).
class EntriPrakiraan {
  const EntriPrakiraan({
    required this.waktuLokal,
    required this.waktuUtc,
    required this.kodeCuaca,
    required this.deskripsi,
    required this.suhu,
    required this.kelembapan,
    required this.kecepatanAngin,
    required this.arahAngin,
    required this.jarakPandang,
  });

  factory EntriPrakiraan.fromJson(Map<String, dynamic> json) {
    return EntriPrakiraan(
      waktuLokal: Baca.waktuSetempat(json['local_datetime']),
      waktuUtc:
          Baca.waktuUtc(json['datetime']) ??
          Baca.waktuSetempat(json['utc_datetime']),
      kodeCuaca: Baca.bulat(json['weather']),
      deskripsi: Baca.teks(json['weather_desc']),
      suhu: Baca.angka(json['t']),
      kelembapan: Baca.bulat(json['hu']),
      kecepatanAngin: Baca.angka(json['ws']),
      arahAngin: Baca.teks(json['wd']),
      jarakPandang: Baca.teksAtauNull(json['vs_text']),
    );
  }

  /// Jam dinding di lokasi tersebut (disimpan sebagai DateTime UTC supaya
  /// tidak digeser oleh zona waktu perangkat).
  final DateTime? waktuLokal;
  final DateTime? waktuUtc;

  /// Kode cuaca BMKG (`weather`), mis. 3 = Berawan.
  final int? kodeCuaca;

  /// Teks kondisi (`weather_desc`), mis. "Cerah Berawan".
  final String deskripsi;

  /// Suhu udara, °C.
  final double? suhu;

  /// Kelembapan, %.
  final int? kelembapan;

  /// Kecepatan angin, km/jam.
  final double? kecepatanAngin;

  /// Arah asal angin, mis. "NE".
  final String arahAngin;

  /// Jarak pandang. Pada respons yang diperiksa nilainya selalu null.
  final String? jarakPandang;

  /// Malam bila jam setempat 18.00–05.59.
  bool get malam {
    final jam = waktuLokal?.hour;
    return jam != null && (jam >= 18 || jam < 6);
  }
}

/// Seluruh prakiraan untuk satu wilayah.
class Prakiraan {
  const Prakiraan({required this.lokasi, required this.hari});

  /// Respons BMKG:
  /// `{"lokasi": {...}, "data": [{"lokasi": {...}, "cuaca": [[...], ...]}]}`.
  factory Prakiraan.fromJson(Map<String, dynamic> json) {
    final data = Baca.daftar(json['data']);
    final pertama = data.isEmpty ? null : Baca.peta(data.first);
    if (pertama == null) {
      throw const FormatException('kunci "data" kosong');
    }

    final lokasiJson =
        Baca.peta(json['lokasi']) ?? Baca.peta(pertama['lokasi']);
    final hari = <List<EntriPrakiraan>>[];
    for (final h in Baca.daftar(pertama['cuaca'])) {
      final entri = <EntriPrakiraan>[];
      for (final e in Baca.daftar(h)) {
        final peta = Baca.peta(e);
        if (peta != null) entri.add(EntriPrakiraan.fromJson(peta));
      }
      if (entri.isNotEmpty) hari.add(entri);
    }

    return Prakiraan(
      lokasi: Lokasi.fromJson(lokasiJson ?? const {}),
      hari: hari,
    );
  }

  final Lokasi lokasi;

  /// Dikelompokkan per tanggal setempat, urut waktu. Hari pertama hanya
  /// berisi jam yang belum lewat.
  final List<List<EntriPrakiraan>> hari;

  bool get kosong => hari.isEmpty;

  Iterable<EntriPrakiraan> get semuaEntri => hari.expand((h) => h);

  /// Selisih jam setempat terhadap UTC, dihitung dari data itu sendiri.
  Duration? get selisihZona {
    for (final e in semuaEntri) {
      final lokal = e.waktuLokal;
      final utc = e.waktuUtc;
      if (lokal != null && utc != null) return lokal.difference(utc);
    }
    return null;
  }

  /// Entri yang waktunya paling dekat dengan [sekarang].
  EntriPrakiraan? entriTerdekat(DateTime sekarang) {
    final acuan = sekarang.toUtc();
    EntriPrakiraan? terbaik;
    Duration? jarakTerbaik;
    for (final e in semuaEntri) {
      final w = e.waktuUtc;
      if (w == null) continue;
      final jarak = w.difference(acuan).abs();
      if (jarakTerbaik == null || jarak < jarakTerbaik) {
        terbaik = e;
        jarakTerbaik = jarak;
      }
    }
    return terbaik ?? (semuaEntri.isEmpty ? null : semuaEntri.first);
  }
}
