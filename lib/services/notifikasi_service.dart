import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';
import '../core/strings.dart';
import '../models/ambang_gempa.dart';

/// Handler pesan FCM saat aplikasi di latar belakang atau tertutup.
///
/// Wajib fungsi tingkat atas. Pesan dari backend bertipe "notification",
/// jadi Android sudah menampilkannya sendiri di channel gempa; di sini tidak
/// perlu menampilkan apa-apa lagi (menghindari notifikasi ganda).
@pragma('vm:entry-point')
Future<void> tanganiPesanLatarBelakang(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM latar belakang: ${message.messageId}');
}

/// Pembungkus Firebase Messaging + notifikasi lokal.
///
/// Bila Firebase belum dikonfigurasi (google-services.json belum ada) atau
/// berjalan di web, [siap] bernilai false dan aplikasi tetap jalan normal.
class NotifikasiService {
  final FlutterLocalNotificationsPlugin _lokal =
      FlutterLocalNotificationsPlugin();

  bool _siap = false;
  bool get siap => _siap;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    NotifikasiConstants.channelGempaId,
    Str.channelGempaNama,
    description: Str.channelGempaDeskripsi,
    importance: Importance.high,
  );

  /// Dipanggil sekali di main() sebelum runApp. Tidak pernah melempar error.
  Future<void> mulai() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase belum dikonfigurasi, notifikasi nonaktif: $e');
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(tanganiPesanLatarBelakang);

      await _lokal.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _lokal
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // Saat aplikasi terbuka, Android tidak menampilkan notifikasi FCM
      // sendiri, jadi ditampilkan lewat notifikasi lokal.
      FirebaseMessaging.onMessage.listen(_tampilkanDiDepan);
      _siap = true;
    } catch (e) {
      debugPrint('Gagal menyiapkan notifikasi: $e');
    }
  }

  Future<void> _tampilkanDiDepan(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;
    try {
      await _lokal.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecond,
        title: notif.title,
        body: notif.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Gagal menampilkan notifikasi: $e');
    }
  }

  /// Meminta izin notifikasi (POST_NOTIFICATIONS di Android 13+).
  /// Mengembalikan true bila diizinkan.
  Future<bool> mintaIzin() async {
    try {
      final hasil = await FirebaseMessaging.instance.requestPermission();
      return hasil.authorizationStatus == AuthorizationStatus.authorized ||
          hasil.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  /// Subscribe ke topic [ambang] dan berhenti dari topic lain.
  /// Melempar error bila gagal (mis. tidak ada internet).
  Future<void> langganan(AmbangGempa ambang) async {
    final messaging = FirebaseMessaging.instance;
    for (final a in AmbangGempa.values) {
      final topik = a.topik;
      if (topik != null && a != ambang) {
        await messaging.unsubscribeFromTopic(topik);
      }
    }
    final topik = ambang.topik;
    if (topik != null) await messaging.subscribeToTopic(topik);
  }

  Future<void> bukaPengaturanAplikasi() async {
    try {
      await Geolocator.openAppSettings();
    } catch (_) {}
  }
}
