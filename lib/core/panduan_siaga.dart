// BERKAS HASIL GENERATE dari sumber resmi. Teks ada di file ARB
// (kunci pSebelum*, pSaat*, pSetelah*, tasItem*, istilah_*).
import 'package:flutter/foundation.dart';

import '../l10n/app_localizations.dart';

/// Sumber konten edukasi. Nama dan alamatnya ditampilkan di layar Siaga.
@immutable
class SumberPanduan {
  const SumberPanduan(this.nama, this.url);

  final String nama;
  final String url;
}

const SumberPanduan sumberBmkgAntisipasi = SumberPanduan(
  'BMKG, Antisipasi Gempa Bumi',
  'https://www.bmkg.go.id/gempabumi/mitigasi/antisipasi-gempabumi',
);

const SumberPanduan sumberBnpbTas = SumberPanduan(
  'BNPB, Edukasi Tas Siaga Bencana Bagi Warga Tambakrejo',
  'https://bnpb.go.id/berita/edukasi-tas-siaga-bencana-bagi-warga-tambakrejo',
);

const SumberPanduan sumberBmkgIstilah = SumberPanduan(
  'BMKG, Katalog Gempabumi Merusak 1821-2025 (Daftar Istilah)',
  'https://content.bmkg.go.id/wp-content/uploads/Katalog-Gempabumi-Signifikan-Merusak-1821-2025_BMKG.pdf',
);

@immutable
class KelompokPanduan {
  const KelompokPanduan(this.judul, this.butir);

  final String judul;
  final List<String> butir;
}

@immutable
class BagianPanduan {
  const BagianPanduan(this.id, this.judul, this.sumber, this.kelompok);

  final String id;
  final String judul;
  final SumberPanduan sumber;
  final List<KelompokPanduan> kelompok;
}

/// Satu butir tas siaga. [id] stabil dan dipakai untuk menyimpan centang,
/// jadi tidak boleh diubah walau urutan/teksnya berubah.
@immutable
class ItemTas {
  const ItemTas(this.id, this.teks);

  final String id;
  final String teks;
}

@immutable
class IstilahGempa {
  const IstilahGempa(this.id, this.nama, this.isi);

  final String id;
  final String nama;
  final String isi;
}

/// Id butir tas siaga, urut seperti daftar BNPB.
const List<String> idTasSiaga = [
  'dokumen',
  'sandang',
  'makanan',
  'air',
  'p3k',
  'radio',
  'mandi',
  'masker',
  'peluit',
  'uang',
  'penerangan',
];

List<BagianPanduan> panduanSiaga(AppLocalizations l) => [
  BagianPanduan('sebelum', l.siagaSebelum, sumberBmkgAntisipasi, [
    KelompokPanduan(l.pSebelumG1, [
      l.pSebelumG1B1,
      l.pSebelumG1B2,
      l.pSebelumG1B3,
    ]),
    KelompokPanduan(l.pSebelumG2, [
      l.pSebelumG2B1,
      l.pSebelumG2B2,
      l.pSebelumG2B3,
      l.pSebelumG2B4,
    ]),
    KelompokPanduan(l.pSebelumG3, [
      l.pSebelumG3B1,
      l.pSebelumG3B2,
      l.pSebelumG3B3,
    ]),
    KelompokPanduan(l.pSebelumG4, [l.pSebelumG4B1, l.pSebelumG4B2]),
    KelompokPanduan(l.pSebelumG5, [
      l.pSebelumG5B1,
      l.pSebelumG5B2,
      l.pSebelumG5B3,
      l.pSebelumG5B4,
    ]),
  ]),
  BagianPanduan('saat', l.siagaSaat, sumberBmkgAntisipasi, [
    KelompokPanduan(l.pSaatG1, [l.pSaatG1B1, l.pSaatG1B2, l.pSaatG1B3]),
    KelompokPanduan(l.pSaatG2, [l.pSaatG2B1, l.pSaatG2B2]),
    KelompokPanduan(l.pSaatG3, [l.pSaatG3B1, l.pSaatG3B2]),
    KelompokPanduan(l.pSaatG4, [l.pSaatG4B1]),
    KelompokPanduan(l.pSaatG5, [l.pSaatG5B1]),
  ]),
  BagianPanduan('setelah', l.siagaSetelah, sumberBmkgAntisipasi, [
    KelompokPanduan(l.pSetelahG1, [
      l.pSetelahG1B1,
      l.pSetelahG1B2,
      l.pSetelahG1B3,
      l.pSetelahG1B4,
    ]),
    KelompokPanduan(l.pSetelahG2, [
      l.pSetelahG2B1,
      l.pSetelahG2B2,
      l.pSetelahG2B3,
      l.pSetelahG2B4,
      l.pSetelahG2B5,
    ]),
    KelompokPanduan(l.pSetelahG3, [l.pSetelahG3B1]),
    KelompokPanduan(l.pSetelahG4, [l.pSetelahG4B1]),
    KelompokPanduan(l.pSetelahG5, [l.pSetelahG5B1, l.pSetelahG5B2]),
    KelompokPanduan(l.pSetelahG6, [l.pSetelahG6B1]),
    KelompokPanduan(l.pSetelahG7, [l.pSetelahG7B1]),
  ]),
];

List<ItemTas> tasSiaga(AppLocalizations l) => [
  ItemTas('dokumen', l.tasItem1),
  ItemTas('sandang', l.tasItem2),
  ItemTas('makanan', l.tasItem3),
  ItemTas('air', l.tasItem4),
  ItemTas('p3k', l.tasItem5),
  ItemTas('radio', l.tasItem6),
  ItemTas('mandi', l.tasItem7),
  ItemTas('masker', l.tasItem8),
  ItemTas('peluit', l.tasItem9),
  ItemTas('uang', l.tasItem10),
  ItemTas('penerangan', l.tasItem11),
];

List<IstilahGempa> istilahGempa(AppLocalizations l) => [
  IstilahGempa('magnitudo', l.istilah_magnitudo_Nama, l.istilah_magnitudo_Isi),
  IstilahGempa('richter', l.istilah_richter_Nama, l.istilah_richter_Isi),
  IstilahGempa('kedalaman', l.istilah_kedalaman_Nama, l.istilah_kedalaman_Isi),
  IstilahGempa('mmi', l.istilah_mmi_Nama, l.istilah_mmi_Isi),
  IstilahGempa('waktu', l.istilah_waktu_Nama, l.istilah_waktu_Isi),
];
