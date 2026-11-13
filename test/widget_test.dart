import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/exceptions.dart';
import 'package:app/main.dart';
import 'package:app/models/gempa.dart';
import 'package:app/services/api_service.dart';

class _FakeApiService extends ApiService {
  _FakeApiService({this.gagal = false});

  final bool gagal;

  @override
  Future<Gempa> fetchAutoGempa() async {
    if (gagal) throw ApiException.noInternet();
    return Gempa.fromJson(const {
      'Magnitude': '4.6',
      'Wilayah': 'Pusat gempa berada di laut 32 km barat laut Pulau Panjang',
    });
  }
}

void main() {
  test('Gempa.fromJson tidak crash saat field hilang atau null', () {
    final gempa = Gempa.fromJson(const {'Magnitude': null});
    expect(gempa.magnitudo, '');
    expect(gempa.wilayah, '');
    expect(gempa.shakemapUrl, isNull);
  });

  test('Gempa.fromAutoGempaJson membaca Infogempa.gempa', () {
    final gempa = Gempa.fromAutoGempaJson(const {
      'Infogempa': {
        'gempa': {'Magnitude': '5.1', 'Shakemap': 'x.mmi.jpg'},
      },
    });
    expect(gempa.magnitudo, '5.1');
    expect(gempa.shakemapUrl, 'https://data.bmkg.go.id/DataMKG/TEWS/x.mmi.jpg');
  });

  testWidgets('Beranda menampilkan gempa terbaru, tab Tentang bisa dibuka', (
    tester,
  ) async {
    await tester.pumpWidget(SiCuacaApp(apiService: _FakeApiService()));
    await tester.pumpAndSettle();

    expect(find.text('4.6'), findsOneWidget);
    expect(find.textContaining('Pulau Panjang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.info_outline).last);
    await tester.pumpAndSettle();
    expect(find.textContaining('bukan aplikasi resmi BMKG'), findsOneWidget);
  });

  testWidgets('Pesan error dan tombol coba lagi saat gagal', (tester) async {
    await tester.pumpWidget(
      SiCuacaApp(apiService: _FakeApiService(gagal: true)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Tidak ada koneksi internet'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}
