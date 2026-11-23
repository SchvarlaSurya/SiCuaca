import 'package:flutter/material.dart';

/// Satu keluarga ikon untuk seluruh aplikasi: Material Icons gaya Rounded
/// (`*_rounded`, sudah termasuk di Flutter, tidak menambah ukuran APK).
/// Warna ikon selalu dari token tema (IconTheme / ColorScheme).
///
/// Material Symbols Rounded tidak dipakai: paket material_symbols_icons
/// membawa font variabel 15 MB (Rounded) dari total 34,5 MB.
abstract final class IkonApp {
  // Navigasi bawah.
  static const IconData beranda = Icons.home_rounded;
  static const IconData cuaca = Icons.wb_sunny_rounded;
  static const IconData gempa = Icons.waves_rounded;
  static const IconData peringatan = Icons.notifications_rounded;
  static const IconData pengaturan = Icons.settings_rounded;

  // Aksi.
  static const IconData lokasiSaya = Icons.my_location_rounded;
  static const IconData cari = Icons.search_rounded;
  static const IconData favorit = Icons.star_rounded;
  static const IconData bukanFavorit = Icons.star_border_rounded;
  static const IconData selengkapnya = Icons.chevron_right_rounded;
  static const IconData muatUlang = Icons.refresh_rounded;
  static const IconData tutup = Icons.close_rounded;
  static const IconData daftarWilayah = Icons.account_tree_rounded;
  static const IconData saring = Icons.filter_list_rounded;

  // Status.
  static const IconData offline = Icons.cloud_off_rounded;
  static const IconData kosong = Icons.inbox_rounded;
  static const IconData lokasiMati = Icons.location_off_rounded;
  static const IconData lokasiCari = Icons.location_searching_rounded;
  static const IconData info = Icons.info_rounded;

  // Data cuaca.
  static const IconData kelembapan = Icons.water_drop_rounded;
  static const IconData angin = Icons.air_rounded;
  static const IconData cerah = Icons.wb_sunny_rounded;
  static const IconData cerahMalam = Icons.bedtime_rounded;
  static const IconData cerahBerawan = Icons.filter_drama_rounded;
  static const IconData cerahBerawanMalam = Icons.nights_stay_rounded;
  static const IconData berawan = Icons.cloud_rounded;
  static const IconData kabut = Icons.dehaze_rounded;
  static const IconData hujan = Icons.umbrella_rounded;
  static const IconData petir = Icons.thunderstorm_rounded;

  // Data gempa.
  static const IconData waktu = Icons.schedule_rounded;
  static const IconData tempat = Icons.place_rounded;
  static const IconData kedalaman = Icons.vertical_align_bottom_rounded;
  static const IconData koordinat = Icons.explore_rounded;
  static const IconData potensi = Icons.tsunami_rounded;
  static const IconData dirasakan = Icons.groups_rounded;
  static const IconData jarak = Icons.near_me_rounded;
  static const IconData gambarTidakAda = Icons.image_not_supported_rounded;
  static const IconData riwayat = Icons.history_rounded;
  static const IconData siaga = Icons.health_and_safety_rounded;
  static const IconData panduan = Icons.check_circle_rounded;
  static const IconData salin = Icons.content_copy_rounded;

  // Peringatan dan Tentang.
  static const IconData notifAktif = Icons.notifications_active_rounded;
  static const IconData notifMati = Icons.notifications_off_rounded;
  static const IconData peringatanDini = Icons.warning_amber_rounded;
  static const IconData bahasa = Icons.translate_rounded;
  static const IconData tema = Icons.contrast_rounded;
  static const IconData peta = Icons.map_rounded;
  static const IconData lisensi = Icons.description_rounded;
  static const IconData versi = Icons.new_releases_rounded;
}
