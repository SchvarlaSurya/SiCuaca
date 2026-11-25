package com.example.app

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

/**
 * Menguji logika murni widget di JVM memakai data asli (fixture BMKG dan
 * Open-Meteo yang juga dipakai tes Dart) dan nilai acuan dari implementasi
 * Dart (`lib/core/uv.dart`), supaya port Kotlin terbukti sama.
 */
class DataWidgetTest {

    private fun fixture(nama: String): JSONObject =
        JSONObject(File("../../test/fixtures/$nama").readText())

    // lat | lon | utcMs | awan | tinggi | UVI | kategori  (dari implementasi Dart)
    private data class Acuan(
        val lat: Double, val lon: Double, val utc: Long, val awan: Int,
        val tinggi: Double, val uvi: Double, val kategori: Int,
    )

    private val acuan = listOf(
        Acuan(-6.2088, 106.8456, 1773982800000, 0, 83.949790, 14.705556, 4),
        Acuan(-6.2088, 106.8456, 1773982800000, 60, 83.949790, 12.763521, 4),
        Acuan(-6.2088, 106.8456, 1773982800000, 100, 83.949790, 3.676389, 1),
        Acuan(-6.2088, 106.8456, 1773972000000, 30, 44.646008, 6.267646, 2),
        Acuan(-6.2088, 106.8456, 1774000800000, 30, 14.944511, 0.554025, 0),
        Acuan(-6.2088, 106.8456, 1774036800000, 30, -44.673689, 0.0, 0),
        Acuan(-7.5666, 110.8167, 1795582800000, 56, 74.159425, 12.154962, 4),
        Acuan(3.5952, 98.6722, 1782885600000, 20, 69.119410, 12.606262, 4),
        Acuan(-37.8, 144.96, 1797822000000, 0, 73.059184, 11.685780, 4),
        Acuan(55.0, 12.0, 1797850800000, 0, 11.536074, 0.241043, 0),
    )

    @Test
    fun tinggiMatahariSamaDenganDart() {
        for (a in acuan) {
            assertEquals(a.tinggi, UvHitung.tinggiMatahari(a.lat, a.lon, a.utc), 0.001)
        }
    }

    @Test
    fun perkiraanUvSamaDenganDartDanKategorinya() {
        for (a in acuan) {
            val uvi = UvHitung.perkiraan(a.lat, a.lon, a.utc, a.awan)
            assertEquals(a.uvi, uvi, 0.001)
            assertEquals(a.kategori, UvHitung.kategori(uvi))
        }
    }

    @Test
    fun batasKategoriUv() {
        assertEquals(0, UvHitung.kategori(2.4))
        assertEquals(1, UvHitung.kategori(2.6))
        assertEquals(1, UvHitung.kategori(5.4))
        assertEquals(2, UvHitung.kategori(5.6))
        assertEquals(2, UvHitung.kategori(7.4))
        assertEquals(3, UvHitung.kategori(7.6))
        assertEquals(3, UvHitung.kategori(10.4))
        assertEquals(4, UvHitung.kategori(10.6))
    }

    @Test
    fun faktorAwanDanOzon() {
        assertEquals(1.0, UvHitung.faktorAwan(null), 0.0)
        assertEquals(1.0, UvHitung.faktorAwan(0), 1e-9)
        assertEquals(0.25, UvHitung.faktorAwan(100), 1e-9)
        assertEquals(0.25, UvHitung.faktorAwan(150), 1e-9)
        assertEquals(260.0, UvHitung.ozon(0.0), 0.0)
        assertEquals(300.0, UvHitung.ozon(45.0), 0.001)
    }

    @Test
    fun batasKategoriAqi() {
        assertEquals(0, KategoriAqi.indeks(50))
        assertEquals(1, KategoriAqi.indeks(51))
        assertEquals(2, KategoriAqi.indeks(101))
        assertEquals(3, KategoriAqi.indeks(158))
        assertEquals(4, KategoriAqi.indeks(201))
        assertEquals(5, KategoriAqi.indeks(301))
    }

    @Test
    fun memilihEntriBmkgTerdekatDariDataAsli() {
        val json = fixture("prakiraan_31.71.01.1001.json")
        val semua = mutableListOf<JSONObject>()
        val cuaca = json.getJSONArray("data").getJSONObject(0).getJSONArray("cuaca")
        for (i in 0 until cuaca.length()) {
            val hari = cuaca.getJSONArray(i)
            for (j in 0 until hari.length()) semua.add(hari.getJSONObject(j))
        }
        assertTrue(semua.size > 10)

        // Tepat di waktu entri mana pun: entri itu sendiri.
        val kedua = semua[1]
        val t = PenguraiWidget.waktuUtc(kedua)!!
        assertEquals(kedua.getString("utc_datetime"), PenguraiWidget.pilihTerdekat(json, t)!!.getString("utc_datetime"))

        // Sedikit setelah entri pertama, jauh sebelum yang kedua: yang pertama.
        val t0 = PenguraiWidget.waktuUtc(semua[0])!!
        val t1 = PenguraiWidget.waktuUtc(semua[1])!!
        val dekatPertama = t0 + (t1 - t0) / 4
        assertEquals(semua[0].getString("utc_datetime"), PenguraiWidget.pilihTerdekat(json, dekatPertama)!!.getString("utc_datetime"))
        val dekatKedua = t0 + (t1 - t0) * 3 / 4
        assertEquals(semua[1].getString("utc_datetime"), PenguraiWidget.pilihTerdekat(json, dekatKedua)!!.getString("utc_datetime"))
    }

    @Test
    fun membacaNilaiEntriBmkgDenganBenar() {
        val json = fixture("prakiraan_31.71.01.1001.json")
        val e = json.getJSONArray("data").getJSONObject(0).getJSONArray("cuaca")
            .getJSONArray(0).getJSONObject(0)
        val c = PenguraiWidget.dariEntri(e)
        assertEquals(Math.round(e.getDouble("t")).toString(), c.suhu)
        assertEquals(Math.round(e.getDouble("hu")).toString(), c.kelembapan)
        assertEquals(Math.round(e.getDouble("ws")).toString(), c.angin)
        assertEquals(e.getString("weather_desc"), c.kondisiId)
        assertEquals(e.getString("weather_desc_en"), c.kondisiEn)
        assertEquals(e.getInt("weather").toString(), c.kode)
        assertEquals(e.getInt("tcc").toString(), c.awan)
        assertFalse(c.suhu.contains("null"))
    }

    @Test
    fun malamMengikutiJamSetempat() {
        fun e(lokal: String) = JSONObject("{\"local_datetime\":\"$lokal\"}")
        assertTrue(PenguraiWidget.malam(e("2026-11-25 18:00:00")))
        assertTrue(PenguraiWidget.malam(e("2026-11-25 05:00:00")))
        assertFalse(PenguraiWidget.malam(e("2026-11-25 06:00:00")))
        assertFalse(PenguraiWidget.malam(e("2026-11-25 12:00:00")))
    }

    @Test
    fun nilaiKosongMenjadiTeksKosongBukanNull() {
        val c = PenguraiWidget.dariEntri(JSONObject("{\"t\":null,\"hu\":\"x\"}"))
        assertEquals("", c.suhu)
        assertEquals("", c.kelembapan)
        assertEquals("", c.angin)
    }

    @Test
    fun membacaAqiDariOpenMeteo() {
        assertEquals(158, PenguraiWidget.parseAqi(fixture("openmeteo_udara.json")))
        assertNull(PenguraiWidget.parseAqi(JSONObject("{}")))
        assertNull(PenguraiWidget.parseAqi(JSONObject("{\"current\":{\"us_aqi\":null}}")))
    }

    @Test
    fun koordinatDibulatkanKeSepersepuluhDerajat() {
        assertEquals(-7.6, PenguraiWidget.bulatkan(-7.566612), 1e-9)
        assertEquals(110.8, PenguraiWidget.bulatkan(110.816745), 1e-9)
        assertNotNull(PenguraiWidget.bulatkan(0.04))
    }
}
