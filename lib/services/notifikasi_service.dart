import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../core/constants.dart';
import '../core/l10n.dart';
import '../models/ambang_gempa.dart';
import '../models/gempa.dart';
import 'riwayat_notifikasi_service.dart';

/// Handler pesan FCM saat aplikasi di latar belakang atau tertutup.
///
/// Wajib fungsi tingkat atas. Pesan dari backend bertipe "notification",
/// jadi Android sudah menampilkannya sendiri di channel gempa; di sini tidak
/// perlu menampilkan apa-apa lagi (menghindari notifikasi ganda).
@pragma('vm:entry-point')
Future<void> tanganiPesanLatarBelakang(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM latar belakang: ${message.messageId}');
  await RiwayatNotifikasiService().catat(message.data);
}

/// Mengubah data notifikasi menjadi [Gempa] lalu membukanya lewat fungsi
/// pembuka yang dipasang aplikasi. Bila ketukan terjadi sebelum aplikasi
/// siap (diluncurkan dari notifikasi), gempa disimpan dulu lalu dibuka saat
/// pembuka dipasang. Data rusak diabaikan dan dicatat di log, tanpa crash.
class PembukaNotifikasi {
  void Function(Gempa gempa)? _buka;
  Gempa? _tertunda;

  /// Dipanggil sekali setelah navigator siap.
  void pasang(void Function(Gempa gempa) buka) {
    _buka = buka;
    final tertunda = _tertunda;
    _tertunda = null;
    if (tertunda != null) buka(tertunda);
  }

  /// Data FCM (`RemoteMessage.data`).
  void tanganiData(Map<String, dynamic>? data, {required String sumber}) {
    final gempa = Gempa.dariPayload(data);
    if (gempa == null) {
      debugPrint('Notifikasi ($sumber) diabaikan: payload bukan gempa/rusak');
      return;
    }
    // Ketukan juga dicatat: notifikasi latar belakang yang tiba saat
    // handler tidak sempat menulis tetap masuk riwayat. Duplikat diabaikan.
    RiwayatNotifikasiService().catat(data);
    final buka = _buka;
    if (buka == null) {
      _tertunda = gempa;
    } else {
      buka(gempa);
    }
  }

  /// Payload notifikasi lokal: JSON dari data FCM.
  void tanganiPayloadLokal(String? payload, {required String sumber}) {
    if (payload == null || payload.isEmpty) {
      debugPrint('Notifikasi lokal ($sumber) tanpa payload, diabaikan');
      return;
    }
    try {
      final data = jsonDecode(payload);
      tanganiData(
        data is Map ? Map<String, dynamic>.from(data) : null,
        sumber: sumber,
      );
    } on FormatException {
      debugPrint('Notifikasi lokal ($sumber): payload bukan JSON, diabaikan');
    }
  }
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

  /// Penerus ketukan notifikasi ke halaman detail gempa.
  final PembukaNotifikasi pembuka = PembukaNotifikasi();

  /// Channel gempa. Nama/deskripsinya mengikuti bahasa perangkat saat
  /// aplikasi dibuka (pilihan bahasa di aplikasi belum diketahui di sini).
  late final AndroidNotificationChannel _channel = () {
    final l = l10nUntuk(PlatformDispatcher.instance.locale);
    return AndroidNotificationChannel(
      NotifikasiConstants.channelGempaId,
      l.channelGempaNama,
      description: l.channelGempaDeskripsi,
      importance: Importance.high,
    );
  }();

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
        // Ketukan notifikasi lokal saat aplikasi masih hidup.
        onDidReceiveNotificationResponse: (respons) =>
            pembuka.tanganiPayloadLokal(respons.payload, sumber: 'lokal'),
      );
      await _lokal
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);

      // Saat aplikasi terbuka, Android tidak menampilkan notifikasi FCM
      // sendiri, jadi ditampilkan lewat notifikasi lokal.
      FirebaseMessaging.onMessage.listen(_tampilkanDiDepan);

      // Ketukan notifikasi sistem saat aplikasi di latar belakang.
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => pembuka.tanganiData(m.data, sumber: 'latar belakang'),
      );

      // Aplikasi diluncurkan dari notifikasi sistem (sebelumnya tertutup).
      final awal = await FirebaseMessaging.instance.getInitialMessage();
      if (awal != null) pembuka.tanganiData(awal.data, sumber: 'tertutup');

      // Aplikasi diluncurkan dari notifikasi lokal (tampil saat aplikasi
      // terbuka, lalu aplikasi ditutup sebelum notifikasi diketuk).
      final peluncuran = await _lokal.getNotificationAppLaunchDetails();
      if (peluncuran?.didNotificationLaunchApp ?? false) {
        pembuka.tanganiPayloadLokal(
          peluncuran!.notificationResponse?.payload,
          sumber: 'lokal (peluncuran)',
        );
      }
      _siap = true;
    } catch (e) {
      debugPrint('Gagal menyiapkan notifikasi: $e');
    }
  }

  Future<void> _tampilkanDiDepan(RemoteMessage message) async {
    await RiwayatNotifikasiService().catat(message.data);
    final notif = message.notification;
    if (notif == null) return;
    try {
      await _lokal.show(
        id: message.messageId?.hashCode ?? DateTime.now().millisecond,
        title: notif.title,
        body: notif.body,
        payload: jsonEncode(message.data),
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
