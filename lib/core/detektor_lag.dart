/// Mendeteksi aplikasi yang tersendat dari durasi frame.
///
/// Frame dihitung per jendela (bawaan 60 frame ≈ 1 detik animasi). Sebuah
/// jendela "buruk" bila sedikitnya [rasioBuruk] dari frame-nya lebih lama
/// dari [batasFrame]. Lag baru dilaporkan setelah [jendelaBerturut] jendela
/// buruk BERTURUT-TURUT, supaya satu lonjakan sesaat (mis. membuka layar
/// berat pertama kali) tidak dianggap HP lambat. Jendela yang mulus
/// mengulang hitungan dari nol.
///
/// Kelas ini murni logika (tanpa Flutter) sehingga mudah diuji.
class DetektorLag {
  DetektorLag({
    this.ukuranJendela = 60,
    this.batasFrame = const Duration(milliseconds: 34),
    this.rasioBuruk = 0.3,
    this.jendelaBerturut = 2,
  });

  /// Jumlah frame per jendela penilaian.
  final int ukuranJendela;

  /// Frame yang lebih lama dari ini dihitung tersendat (≈ 2 frame terlewat
  /// di layar 60 Hz).
  final Duration batasFrame;

  /// Bagian frame tersendat (0..1) yang membuat satu jendela "buruk".
  final double rasioBuruk;

  /// Jumlah jendela buruk berturut-turut sebelum lag dilaporkan.
  final int jendelaBerturut;

  int _frame = 0;
  int _tersendat = 0;
  int _burukBerturut = 0;

  /// Mencatat satu frame. Mengembalikan true tepat saat lag terdeteksi;
  /// hitungan lalu diulang dari nol.
  bool catat(Duration lamaFrame) {
    _frame++;
    if (lamaFrame > batasFrame) _tersendat++;
    if (_frame < ukuranJendela) return false;

    final buruk = _tersendat / _frame >= rasioBuruk;
    _frame = 0;
    _tersendat = 0;
    if (!buruk) {
      _burukBerturut = 0;
      return false;
    }
    _burukBerturut++;
    if (_burukBerturut < jendelaBerturut) return false;
    _burukBerturut = 0;
    return true;
  }

  /// Membuang semua hitungan (mis. saat efek kaca dimatikan).
  void ulang() {
    _frame = 0;
    _tersendat = 0;
    _burukBerturut = 0;
  }
}
