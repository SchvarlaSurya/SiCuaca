import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'l10n.dart';

/// Membuka halaman resmi BMKG di browser dalam aplikasi (Custom Tab di
/// Android). Isinya tidak diambil atau disalin oleh SiCuaca. Bila gagal,
/// beri tahu pengguna lewat SnackBar.
abstract final class TautanResmiBmkg {
  /// Bisa diganti saat pengujian.
  static Future<bool> Function(Uri) pembuka = (uri) =>
      launchUrl(uri, mode: LaunchMode.inAppBrowserView);

  static Future<void> buka(BuildContext context, String url) async {
    var berhasil = false;
    try {
      berhasil = await pembuka(Uri.parse(url));
    } catch (_) {
      berhasil = false;
    }
    if (!berhasil && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.layananGagalBuka)));
    }
  }
}
