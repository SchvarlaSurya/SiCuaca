import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/gempa.dart';
import 'riwayat_gempa_repository.dart';

/// Penyimpanan riwayat di SQLite (sqflite). Hanya untuk Android/iOS; web
/// memakai [MemoriRiwayatStore] (lihat [buatPenyimpananRiwayat]).
///
/// Skema versi 1: tabel `riwayat_gempa` dan `meta`. Versi berikutnya
/// ditambahkan di [_naik] dengan `ALTER TABLE` tanpa menghapus data.
class SqfliteRiwayatStore implements RiwayatGempaStore {
  SqfliteRiwayatStore({this._pabrik, this._lokasi});

  /// Versi skema database saat ini.
  static const int versi = 1;
  static const String _tabel = 'riwayat_gempa';

  final DatabaseFactory? _pabrik;
  final String? _lokasi;
  Future<Database>? _terbuka;

  Future<Database> get _db => _terbuka ??= _buka();

  Future<Database> _buka() async {
    final pabrik = _pabrik ?? databaseFactory;
    final lokasi =
        _lokasi ?? p.join(await pabrik.getDatabasesPath(), 'sicuaca.db');
    return pabrik.openDatabase(
      lokasi,
      options: OpenDatabaseOptions(
        version: versi,
        onCreate: (db, v) => _buat(db),
        onUpgrade: _naik,
      ),
    );
  }

  static Future<void> _buat(Database db) async {
    await db.execute('''
      CREATE TABLE $_tabel (
        kunci TEXT PRIMARY KEY,
        waktu_utc INTEGER NOT NULL,
        lat REAL NOT NULL,
        lon REAL NOT NULL,
        magnitudo_angka REAL,
        tanggal TEXT NOT NULL DEFAULT '',
        jam TEXT NOT NULL DEFAULT '',
        koordinat TEXT NOT NULL DEFAULT '',
        lintang TEXT NOT NULL DEFAULT '',
        bujur TEXT NOT NULL DEFAULT '',
        magnitudo TEXT NOT NULL DEFAULT '',
        kedalaman TEXT NOT NULL DEFAULT '',
        wilayah TEXT NOT NULL DEFAULT '',
        potensi TEXT NOT NULL DEFAULT '',
        dirasakan TEXT NOT NULL DEFAULT '',
        shakemap TEXT NOT NULL DEFAULT '',
        dicatat_at INTEGER NOT NULL,
        diperbarui_at INTEGER NOT NULL,
        sumber TEXT NOT NULL DEFAULT 'bmkg'
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_riwayat_waktu ON $_tabel (waktu_utc DESC)',
    );
    await db.execute('CREATE TABLE meta (k TEXT PRIMARY KEY, v TEXT NOT NULL)');
  }

  /// Migrasi bertahap. Belum ada versi lama; kerangka untuk versi 2 dst:
  /// `if (lama < 2) await db.execute('ALTER TABLE ...')`.
  static Future<void> _naik(Database db, int lama, int baru) async {}

  Map<String, Object?> _kePeta(String kunci, BarisRiwayat b) {
    final g = b.gempa;
    return {
      'kunci': kunci,
      'waktu_utc': g.waktuUtc!.toUtc().millisecondsSinceEpoch,
      'lat': g.lat,
      'lon': g.lon,
      'magnitudo_angka': g.magnitudoAngka,
      'tanggal': g.tanggal,
      'jam': g.jam,
      'koordinat': g.koordinat,
      'lintang': g.lintang,
      'bujur': g.bujur,
      'magnitudo': g.magnitudo,
      'kedalaman': g.kedalaman,
      'wilayah': g.wilayah,
      'potensi': g.potensi,
      'dirasakan': g.dirasakan,
      'shakemap': g.shakemap,
      'dicatat_at': b.dicatat.toUtc().millisecondsSinceEpoch,
      'diperbarui_at': b.diperbarui.toUtc().millisecondsSinceEpoch,
      'sumber': b.sumber,
    };
  }

  /// Null bila baris rusak (dilewati, tidak membuat pembacaan gagal).
  BarisRiwayat? _dariPeta(Map<String, Object?> m) {
    try {
      final ms = m['waktu_utc'] as int;
      final waktu = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
      final gempa = Gempa(
        tanggal: '${m['tanggal'] ?? ''}',
        jam: '${m['jam'] ?? ''}',
        koordinat: '${m['koordinat'] ?? ''}',
        lintang: '${m['lintang'] ?? ''}',
        bujur: '${m['bujur'] ?? ''}',
        magnitudo: '${m['magnitudo'] ?? ''}',
        kedalaman: '${m['kedalaman'] ?? ''}',
        wilayah: '${m['wilayah'] ?? ''}',
        potensi: '${m['potensi'] ?? ''}',
        dirasakan: '${m['dirasakan'] ?? ''}',
        shakemap: '${m['shakemap'] ?? ''}',
        waktuUtc: waktu,
        lat: (m['lat'] as num).toDouble(),
        lon: (m['lon'] as num).toDouble(),
      );
      return BarisRiwayat(
        gempa: gempa,
        dicatat: DateTime.fromMillisecondsSinceEpoch(
          m['dicatat_at'] as int,
          isUtc: true,
        ).toLocal(),
        diperbarui: DateTime.fromMillisecondsSinceEpoch(
          m['diperbarui_at'] as int,
          isUtc: true,
        ).toLocal(),
        sumber: '${m['sumber'] ?? 'bmkg'}',
      );
    } catch (e) {
      debugPrint('Baris riwayat rusak dilewati: $e');
      return null;
    }
  }

  @override
  Future<BarisRiwayat?> ambil(String kunci) async {
    final db = await _db;
    final hasil = await db.query(
      _tabel,
      where: 'kunci = ?',
      whereArgs: [kunci],
      limit: 1,
    );
    return hasil.isEmpty ? null : _dariPeta(hasil.first);
  }

  @override
  Future<void> simpan(String kunci, BarisRiwayat baris) async {
    final db = await _db;
    await db.insert(
      _tabel,
      _kePeta(kunci, baris),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<BarisRiwayat>> semua() async {
    final db = await _db;
    final hasil = await db.query(_tabel, orderBy: 'waktu_utc DESC');
    return [for (final m in hasil) ?_dariPeta(m)];
  }

  @override
  Future<int> hapusSebelum(DateTime batas) async {
    final db = await _db;
    return db.delete(
      _tabel,
      where: 'waktu_utc < ?',
      whereArgs: [batas.toUtc().millisecondsSinceEpoch],
    );
  }

  @override
  Future<int> hapusLebihDari(int maks) async {
    final db = await _db;
    return db.rawDelete(
      'DELETE FROM $_tabel WHERE kunci NOT IN '
      '(SELECT kunci FROM $_tabel ORDER BY waktu_utc DESC LIMIT ?)',
      [maks],
    );
  }

  @override
  Future<void> hapusSemua() async {
    final db = await _db;
    await db.delete(_tabel);
  }

  @override
  Future<String?> meta(String kunci) async {
    final db = await _db;
    final hasil = await db.query('meta', where: 'k = ?', whereArgs: [kunci]);
    return hasil.isEmpty ? null : hasil.first['v'] as String?;
  }

  @override
  Future<void> setMeta(String kunci, String nilai) async {
    final db = await _db;
    await db.insert('meta', {
      'k': kunci,
      'v': nilai,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Menutup database (dipakai pengujian).
  Future<void> tutup() async {
    final terbuka = _terbuka;
    _terbuka = null;
    if (terbuka != null) await (await terbuka).close();
  }
}

/// Penyimpanan riwayat untuk platform saat ini: SQLite di perangkat,
/// memori di web (sqflite tidak mendukung web).
RiwayatGempaStore buatPenyimpananRiwayat() =>
    kIsWeb ? MemoriRiwayatStore() : SqfliteRiwayatStore();
