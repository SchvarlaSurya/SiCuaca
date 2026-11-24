import 'geo.dart';

/// Hasil pencarian perairan terdekat.
typedef PerairanTerdekat = ({String id, String nama, double jarakKm});

/// Mencari wilayah perairan BMKG yang paling dekat dengan titik (lat, lon)
/// dari GeoJSON resmi `meta/wilmetos.min.geojson` (poligon perairan, koordinat
/// [lon, lat] WGS84).
///
/// Pengguna biasanya berada di darat, jadi yang dicari bukan "poligon yang
/// memuat titik" melainkan perairan dengan tepi terdekat; jaraknya diukur ke
/// titik sudut poligon (cukup rapat di data BMKG, ±14 ribu titik). Titik di
/// dalam poligon (di laut) berjarak 0.
///
/// Null bila tidak ada perairan yang terbaca. Berjalan murni (tanpa I/O)
/// supaya bisa dijalankan di isolate lewat `compute`.
PerairanTerdekat? cariPerairanTerdekat(
  Map<String, dynamic> geojson,
  double lat,
  double lon,
) {
  final fitur = geojson['features'];
  if (fitur is! List) return null;
  PerairanTerdekat? terbaik;
  for (final f in fitur) {
    if (f is! Map) continue;
    final prop = f['properties'];
    final geo = f['geometry'];
    if (prop is! Map || geo is! Map) continue;
    final id = '${prop['ID_MAR'] ?? ''}'.trim();
    if (id.isEmpty) continue;
    final nama = '${prop['perairan'] ?? id}'.trim();
    final cincin = _cincinLuar(geo);
    if (cincin.isEmpty) continue;
    var jarak = double.infinity;
    for (final c in cincin) {
      if (_dalamPoligon(c, lat, lon)) {
        jarak = 0;
        break;
      }
      for (final t in c) {
        final d = jarakKmAntara(lat, lon, t.$2, t.$1);
        if (d < jarak) jarak = d;
      }
    }
    if (terbaik == null || jarak < terbaik.jarakKm) {
      terbaik = (id: id, nama: nama, jarakKm: jarak);
    }
  }
  return terbaik;
}

/// Argumen untuk `compute` (fungsi tingkat atas).
PerairanTerdekat? cariPerairanTerdekatDariArgumen(
  ({Map<String, dynamic> geojson, double lat, double lon}) a,
) => cariPerairanTerdekat(a.geojson, a.lat, a.lon);

/// Cincin luar poligon sebagai daftar (lon, lat).
List<List<(double, double)>> _cincinLuar(Map geo) {
  final tipe = geo['type'];
  final koordinat = geo['coordinates'];
  if (koordinat is! List) return const [];
  List<(double, double)> cincin(Object? r) => [
    if (r is List)
      for (final t in r)
        if (t is List && t.length >= 2 && t[0] is num && t[1] is num)
          ((t[0] as num).toDouble(), (t[1] as num).toDouble()),
  ];
  return switch (tipe) {
    'Polygon' when koordinat.isNotEmpty => [cincin(koordinat.first)],
    'MultiPolygon' => [
      for (final p in koordinat)
        if (p is List && p.isNotEmpty) cincin(p.first),
    ],
    _ => const [],
  };
}

/// Ray casting: apakah (lat, lon) di dalam cincin (lon, lat).
bool _dalamPoligon(List<(double, double)> c, double lat, double lon) {
  var dalam = false;
  for (var i = 0, j = c.length - 1; i < c.length; j = i++) {
    final (xi, yi) = c[i];
    final (xj, yj) = c[j];
    if ((yi > lat) != (yj > lat) &&
        lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
      dalam = !dalam;
    }
  }
  return dalam;
}
