import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pengaturan_provider.dart';

/// Apakah efek kaca cair penuh (shader, lapisan kaca) sedang nyala.
///
/// Dibaca dari Pengaturan > "Efek kaca cair". Saat mati, SEMUA komponen
/// bukan hanya memakai kaca sederhana: kartu, tombol, dan navbar diganti
/// widget biasa (warna tembus pandang + garis tepi) tanpa lapisan kaca,
/// shader, maupun blur, supaya ringan di HP yang kurang kuat.
///
/// Dipakai di `build` (mendaftarkan perubahan). Tanpa provider (mis. widget
/// diuji sendiri) dianggap nyala.
bool kacaCairAktif(BuildContext context) {
  try {
    return context.select<PengaturanProvider, bool>((p) => p.kacaCair);
  } on ProviderNotFoundException {
    return true;
  }
}
