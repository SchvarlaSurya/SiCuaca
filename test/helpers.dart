import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';

import 'package:app/core/ikon.dart';
import 'package:app/core/constants.dart';
import 'package:app/core/exceptions.dart';
import 'package:app/core/l10n.dart';
import 'package:app/main.dart';
import 'package:app/models/ambang_gempa.dart';
import 'package:app/providers/pengaturan_provider.dart';
import 'package:app/services/api_service.dart';
import 'package:app/services/gps_service.dart';
import 'package:app/services/notifikasi_service.dart';
import 'package:app/services/preferences_service.dart';
import 'package:app/services/riwayat_gempa_repository.dart';
import 'package:app/services/widget_layar_service.dart';
import 'package:app/services/wilayah_service.dart';

/// Teks Bahasa Indonesia (bahasa default) untuk dicocokkan di test.
final AppLocalizations l = lookupAppLocalizations(const Locale('id'));

/// Teks Bahasa Inggris.
final AppLocalizations en = lookupAppLocalizations(const Locale('en'));

const tsvUji =
    '31\tDKI Jakarta\r\n' // satu baris CRLF untuk menguji toleransi
    '31.71\tKota Adm. Jakarta Pusat\n'
    '31.71.01\tGambir\n'
    '31.71.01.1001\tGambir\t-6.17638\t106.82671\n'
    '31.71.01.1002\tCideng\t-6.17298\t106.80831\n'
    '35\tJawa Timur\n'
    '35.07\tKab. Malang\n'
    '35.07.10\tGondanglegi\n'
    '35.07.10.2001\tPutat Kidul\t-8.17004\t112.64473\n'
    "35.07.10.2002\tSuka'maju\t\t\n";

Map<String, dynamic> fixture(String nama) =>
    jsonDecode(File('test/fixtures/$nama').readAsStringSync())
        as Map<String, dynamic>;

/// API palsu: membalas fixture asli BMKG sesuai URL; [offline] bisa diubah
/// di tengah test untuk mensimulasikan mode pesawat.
class FakeApi extends ApiService {
  FakeApi({this.offline = false});

  bool offline;
  int panggilan = 0;

  @override
  Future<Map<String, dynamic>> ambilJson(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    panggilan++;
    if (offline) throw ApiException.noInternet();
    return switch (url) {
      ApiConstants.autoGempaUrl => fixture('autogempa.json'),
      ApiConstants.gempaTerkiniUrl => fixture('gempaterkini.json'),
      ApiConstants.gempaDirasakanUrl => fixture('gempadirasakan.json'),
      ApiConstants.prakiraanCuacaUrl => fixture('prakiraan_31.71.01.1001.json'),
      // Kualitas udara Open-Meteo (titik generik).
      ApiConstants.openMeteoUdaraUrl => fixture('openmeteo_udara.json'),
      // Data maritim asli BMKG (GeoJSON dipotong; data pribadi dihapus).
      ApiConstants.maritimAreaUrl => fixture('maritim_area_province.json'),
      ApiConstants.maritimWilayahUrl => fixture('maritim_wilayah.geojson'),
      _ when url.startsWith('${ApiConstants.maritimBaseUrl}/perairan/') =>
        fixture('maritim_perairan.json'),
      _ => throw ApiException.notFound(),
    };
  }
}

class FakeGps extends GpsService {
  FakeGps(this.hasil);

  final HasilGps hasil;

  @override
  Future<HasilGps> ambilPosisi({bool mintaIzin = true}) async =>
      mintaIzin ? hasil : const HasilGps(StatusGps.ditolak);
}

class FakeWilayah extends WilayahService {
  @override
  Future<IndeksWilayah> muat() async => parseWilayah(tsvUji);
}

class FakeNotif extends NotifikasiService {
  FakeNotif({this.izin = true, this.gagal = false, this.aktif = true});

  final bool izin;
  final bool gagal;
  final bool aktif;
  final List<AmbangGempa> langgananDipanggil = [];

  @override
  bool get siap => aktif;

  @override
  Future<bool> mintaIzin() async => izin;

  @override
  Future<void> langganan(AmbangGempa ambang) async {
    if (gagal) throw Exception('SERVICE_NOT_AVAILABLE');
    langgananDipanggil.add(ambang);
  }

  @override
  Future<void> bukaPengaturanAplikasi() async {}
}

Widget buatApp({
  required HasilGps gps,
  bool offline = false,
  FakeApi? api,
  NotifikasiService? notif,
  PengaturanProvider? pengaturan,
  bool sudahOnboarding = true,
  RiwayatGempaRepository? riwayatGempa,
  bool splash = false,
  PenyimpanWidget? penyimpanWidget,
}) => SiCuacaApp(
  penyimpanWidget: penyimpanWidget ?? PenyimpanWidgetDiam(),
  sudahOnboarding: sudahOnboarding,
  tampilkanSplash: splash,
  // Memori, bukan SQLite: pengujian widget tidak punya platform channel.
  riwayatGempa: riwayatGempa ?? RiwayatGempaRepository(MemoriRiwayatStore()),
  apiService: api ?? FakeApi(offline: offline),
  gpsService: FakeGps(gps),
  wilayahService: FakeWilayah(),
  notifikasiService: notif,
  // Test berjalan dengan locale en-US; paksa Bahasa Indonesia (default
  // aplikasi) kecuali test memberi pengaturan sendiri.
  pengaturan:
      pengaturan ??
      PengaturanProvider(PreferencesService(), bahasa: PilihanBahasa.indonesia),
  preferencesService: PreferencesService(),
);

/// Tab di navigasi bawah: 'beranda', 'cuaca', 'gempa', 'pengaturan'.
/// Dicari lewat key karena tab Cuaca dan Gempa menampilkan data, bukan ikon.
// Navbar kaca menggambar isi tab dua kali (lapisan dasar dan lapisan tab
// terpilih), jadi ambil yang pertama.
Finder navTab(String nama) => find.byKey(ValueKey('nav.$nama')).first;

/// Menggulir [f] ke sekitar tengah layar supaya tidak tertutup navbar
/// melayang, lalu menunggu animasi selesai.
Future<void> gulirKeTengah(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await Scrollable.ensureVisible(tester.element(f), alignment: .4);
  await tester.pumpAndSettle();
}

/// Membuka pengaturan notifikasi lewat tombol lonceng di tab Gempa.
Future<void> bukaPeringatan(WidgetTester tester) async {
  await tester.tap(navTab('gempa'));
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(IkonApp.peringatan));
  await tester.pumpAndSettle();
}
