import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';

enum StatusGps { berhasil, layananMati, ditolak, ditolakPermanen, gagal }

class HasilGps {
  const HasilGps(this.status, {this.lat, this.lon});

  final StatusGps status;
  final double? lat;
  final double? lon;
}

/// Pembungkus geolocator. Tidak pernah melempar error: semua kasus izin dan
/// layanan dikembalikan sebagai [StatusGps].
class GpsService {
  Future<HasilGps> ambilPosisi() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const HasilGps(StatusGps.layananMati);
      }

      var izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.denied) {
        return const HasilGps(StatusGps.ditolak);
      }
      if (izin == LocationPermission.deniedForever) {
        return const HasilGps(StatusGps.ditolakPermanen);
      }

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: LokasiConstants.batasWaktuGps,
        ),
      );
      return HasilGps(
        StatusGps.berhasil,
        lat: posisi.latitude,
        lon: posisi.longitude,
      );
    } on LocationServiceDisabledException {
      return const HasilGps(StatusGps.layananMati);
    } on PermissionDeniedException {
      return const HasilGps(StatusGps.ditolak);
    } on TimeoutException {
      return _posisiTerakhir();
    } catch (_) {
      return const HasilGps(StatusGps.gagal);
    }
  }

  /// Cadangan bila GPS terlalu lama: posisi terakhir yang diketahui sistem.
  Future<HasilGps> _posisiTerakhir() async {
    try {
      final posisi = await Geolocator.getLastKnownPosition();
      if (posisi != null) {
        return HasilGps(
          StatusGps.berhasil,
          lat: posisi.latitude,
          lon: posisi.longitude,
        );
      }
    } catch (_) {
      // Tidak didukung di sebagian platform (mis. web).
    }
    return const HasilGps(StatusGps.gagal);
  }

  Future<void> bukaPengaturanAplikasi() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }

  Future<void> bukaPengaturanLokasi() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (_) {}
  }
}
