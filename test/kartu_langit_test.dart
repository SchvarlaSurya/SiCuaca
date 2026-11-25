import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/astronomi.dart';
import 'package:app/core/format.dart';
import 'package:app/core/l10n.dart';
import 'package:app/models/prakiraan.dart';
import 'package:app/widgets/deret_cuaca.dart';
import 'package:app/widgets/kartu_langit.dart';

final l = lookupAppLocalizations(const Locale('id'));
const _wib = Duration(hours: 7);

Widget _app(Widget anak, {double skalaTeks = 1.3}) => MaterialApp(
  locale: const Locale('id'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(360, 800),
      textScaler: TextScaler.linear(skalaTeks),
    ),
    child: Scaffold(body: SingleChildScrollView(child: anak)),
  ),
);

EntriPrakiraan _entri({String? jarak}) => EntriPrakiraan(
  waktuLokal: DateTime.utc(2026, 3, 20, 12),
  waktuUtc: DateTime.utc(2026, 3, 20, 5),
  kodeCuaca: 3,
  deskripsi: 'Berawan',
  suhu: 30,
  kelembapan: 70,
  kecepatanAngin: 10,
  arahAngin: 'NE',
  jarakPandang: jarak,
);

void main() {
  void setelUkuran(WidgetTester tester) {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  testWidgets('kartu matahari dan bulan: jam, lama siang, fase, dan catatan '
      'sumber tampil tanpa overflow (360 dp, huruf 1,3x)', (tester) async {
    setelUkuran(tester);
    await tester.pumpWidget(
      _app(
        KartuMatahariBulan(
          lat: -6.2088,
          lon: 106.8456,
          hariSetempat: DateTime.utc(2026, 3, 20, 9),
          selisih: _wib,
        ),
      ),
    );
    final a = Astronomi.hitung(
      lat: -6.2088,
      lon: 106.8456,
      tanggalSetempat: DateTime.utc(2026, 3, 20),
      selisih: _wib,
    );
    expect(find.text(l.langitJudul), findsOneWidget);
    expect(find.text(Format.jam(a.matahari.terbit)), findsOneWidget);
    expect(find.text(Format.jam(a.matahari.terbenam)), findsOneWidget);
    expect(find.text(l.lamaSiang), findsOneWidget);
    expect(find.textContaining(namaFaseBulan(l, a.fase)), findsOneWidget);
    // Catatan jujur bahwa ini hitungan aplikasi, bukan data BMKG.
    expect(find.text(l.langitCatatan), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bulan masih di bawah cakrawala: lintasan malam ini dengan '
      'tanda hari berikutnya, matahari di atas', (tester) async {
    setelUkuran(tester);
    // Purnama 3 Mar 2026, sore hari: bulan terbit nanti malam, terbenam
    // besok pagi.
    await tester.pumpWidget(
      _app(
        KartuMatahariBulan(
          lat: -6.2088,
          lon: 106.8456,
          hariSetempat: DateTime.utc(2026, 3, 3, 15, 10),
          selisih: _wib,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(l.diBawahHorizon), findsOneWidget);
    expect(find.textContaining('(+1)'), findsOneWidget);
    expect(find.text(l.fasePurnama), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bulan sedang di atas cakrawala: tidak ada teks di bawah '
      'cakrawala untuk keduanya', (tester) async {
    setelUkuran(tester);
    // Purnama, tengah malam: matahari di bawah, bulan di atas. Matahari
    // menampilkan teks "di bawah cakrawala", bulan tidak.
    await tester.pumpWidget(
      _app(
        KartuMatahariBulan(
          lat: -6.2088,
          lon: 106.8456,
          hariSetempat: DateTime.utc(2026, 3, 3, 23, 30),
          selisih: _wib,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(l.diBawahHorizon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('kurangi gerakan: ikon langsung di posisinya, tanpa error', (
    tester,
  ) async {
    setelUkuran(tester);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: KartuMatahariBulan(
                lat: -6.2088,
                lon: 106.8456,
                hariSetempat: DateTime.utc(2026, 3, 20, 9),
                selisih: _wib,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ringkasan detail: titik embun dihitung dari suhu dan '
      'kelembapan', (tester) async {
    setelUkuran(tester);
    await tester.pumpWidget(_app(RingkasDetail(entri: _entri())));
    expect(find.text(l.titikEmbun), findsOneWidget);
    expect(
      find.text(Format.suhu(Astronomi.titikEmbun(30, 70))),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ringkasan detail dengan jarak pandang (empat sel) dibagi dua '
      'baris tanpa overflow', (tester) async {
    setelUkuran(tester);
    await tester.pumpWidget(
      _app(RingkasDetail(entri: _entri(jarak: '> 10 km'))),
    );
    for (final label in [l.kelembapan, l.angin, l.jarakPandang, l.titikEmbun]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('tanpa suhu atau kelembapan: tidak ada sel titik embun', (
    tester,
  ) async {
    setelUkuran(tester);
    final tanpa = EntriPrakiraan(
      waktuLokal: DateTime.utc(2026, 3, 20, 12),
      waktuUtc: DateTime.utc(2026, 3, 20, 5),
      kodeCuaca: 3,
      deskripsi: 'Berawan',
      suhu: null,
      kelembapan: 70,
      kecepatanAngin: 10,
      arahAngin: 'NE',
      jarakPandang: null,
    );
    await tester.pumpWidget(_app(RingkasDetail(entri: tanpa)));
    expect(find.text(l.titikEmbun), findsNothing);
  });
}
