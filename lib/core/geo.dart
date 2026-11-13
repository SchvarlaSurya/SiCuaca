import 'dart:math' as math;

/// Jari-jari rata-rata bumi, km.
const double _jariJariBumiKm = 6371.0;

/// Jarak lingkaran besar (haversine) antara dua titik, dalam kilometer.
double jarakKmAntara(double lat1, double lon1, double lat2, double lon2) {
  double rad(double derajat) => derajat * math.pi / 180;

  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLon / 2), 2);
  final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _jariJariBumiKm * c;
}
