"""Membangun assets/data/wilayah.tsv dari dataset terbuka cahyadsn (MIT).

Sumber:
  - https://github.com/cahyadsn/wilayah            -> kode + nama semua tingkat
  - https://github.com/cahyadsn/wilayah_boundaries -> titik tengah (centroid)
                                                     tiap desa/kelurahan
Keduanya mengikuti Kepmendagri No 300.2.2-2430 Tahun 2025.

Format keluaran (UTF-8, satu baris per wilayah, dipisah TAB):
  kode<TAB>nama                    provinsi (2), kab/kota (5), kecamatan (8)
  kode<TAB>nama<TAB>lat<TAB>lng    desa/kelurahan (13), lat/lng boleh kosong

Jalankan dari akar proyek:  python tool/build_wilayah.py
Hanya dibutuhkan saat memperbarui data; aplikasi cukup membaca berkas TSV.
"""

import concurrent.futures as cf
import http.client
import json
import pathlib
import re
import time
import urllib.request

OUT = pathlib.Path(__file__).resolve().parent.parent / "assets" / "data" / "wilayah.tsv"

NAMA_REPO = "cahyadsn/wilayah"
BATAS_REPO = "cahyadsn/wilayah_boundaries"

# Nama wilayah bisa mengandung tanda kutip yang di-escape (\' atau '').
_TEKS = r"'((?:[^'\\]|\\.|'')*)'"
RE_NAMA = re.compile(r"\('([\d.]+)'," + _TEKS + r"\)")
RE_TITIK = re.compile(
    r"\('(\d\d\.\d\d\.\d\d\.\d{4})'," + _TEKS + r",(-?[\d.]+|NULL),(-?[\d.]+|NULL),"
)


def ambil(url: str, percobaan: int = 4) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "sicuaca-build-script"})
    for ke in range(1, percobaan + 1):
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                return resp.read()
        except (OSError, http.client.HTTPException):
            if ke == percobaan:
                raise
            time.sleep(2 * ke)
    raise RuntimeError("tidak terjangkau")


def ambil_json(url: str):
    return json.loads(ambil(url))


def raw(repo: str, sha: str, path: str) -> str:
    return ambil(f"https://raw.githubusercontent.com/{repo}/{sha}/{path}").decode("utf-8")


def bersihkan(nama: str) -> str:
    nama = nama.replace("\\'", "'").replace("''", "'").strip()
    nama = re.sub(r"\s+", " ", nama)
    if nama.startswith("Kabupaten "):
        nama = "Kab. " + nama[len("Kabupaten "):]
    return nama


def main() -> None:
    sha_nama = ambil_json(f"https://api.github.com/repos/{NAMA_REPO}/commits/HEAD")["sha"]
    sha_batas = ambil_json(f"https://api.github.com/repos/{BATAS_REPO}/commits/HEAD")["sha"]
    print("wilayah           @", sha_nama)
    print("wilayah_boundaries@", sha_batas)

    nama = {}
    for kode, teks in RE_NAMA.findall(raw(NAMA_REPO, sha_nama, "db/wilayah.sql")):
        nama[kode] = bersihkan(teks)
    print("kode dari wilayah.sql:", len(nama))

    pohon = ambil_json(
        f"https://api.github.com/repos/{BATAS_REPO}/git/trees/{sha_batas}?recursive=1"
    )
    berkas = [
        t["path"]
        for t in pohon["tree"]
        if t["type"] == "blob" and t["path"].startswith("db/kel/") and t["path"].endswith(".sql")
    ]
    print("berkas boundaries desa:", len(berkas))

    titik = {}

    def proses(path: str) -> int:
        n = 0
        for kode, _, lat, lng in RE_TITIK.findall(raw(BATAS_REPO, sha_batas, path)):
            if lat != "NULL" and lng != "NULL":
                titik[kode] = (round(float(lat), 5), round(float(lng), 5))
                n += 1
        return n

    with cf.ThreadPoolExecutor(max_workers=8) as pool:
        for i, _ in enumerate(pool.map(proses, berkas), 1):
            if i % 50 == 0:
                print(f"  {i}/{len(berkas)} berkas")

    baris = []
    desa = tanpa_titik = 0
    for kode in sorted(nama):
        if len(kode) == 13:
            desa += 1
            lat, lng = titik.get(kode, ("", ""))
            if lat == "":
                tanpa_titik += 1
            baris.append(f"{kode}\t{nama[kode]}\t{lat}\t{lng}")
        elif len(kode) in (2, 5, 8):
            baris.append(f"{kode}\t{nama[kode]}")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(baris) + "\n", encoding="utf-8", newline="\n")
    print(f"desa/kelurahan: {desa}, tanpa koordinat: {tanpa_titik}")
    print(f"tertulis: {OUT} ({OUT.stat().st_size / 1e6:.2f} MB)")


if __name__ == "__main__":
    main()
