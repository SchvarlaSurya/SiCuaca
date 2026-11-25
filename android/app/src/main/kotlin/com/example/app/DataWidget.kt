package com.example.app

import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone
import kotlin.math.abs
import kotlin.math.asin
import kotlin.math.atan2
import kotlin.math.cos
import kotlin.math.pow
import kotlin.math.roundToInt
import kotlin.math.sin

/**
 * Logika murni widget (tanpa Android): perkiraan UV, pemilihan entri
 * prakiraan BMKG terdekat, dan pembacaan kualitas udara. Dipisah supaya bisa
 * diuji di JVM dengan data asli (lihat DataWidgetTest).
 */

/**
 * Perkiraan indeks UV, port dari `lib/core/uv.dart` dan
 * `Astronomi.tinggiMatahari` di aplikasi. Rumus langit cerah baku dikali
 * faktor awan; tanpa aerosol, jadi hanya perkiraan.
 */
object UvHitung {
    private const val RAD = Math.PI / 180

    private fun normal(derajat: Double): Double {
        val n = derajat % 360
        return if (n < 0) n + 360 else n
    }

    /** Ketinggian matahari (derajat di atas cakrawala) pada [utcMs]. */
    fun tinggiMatahari(lat: Double, lon: Double, utcMs: Long): Double {
        val jd = utcMs / 86400000.0 + 2440587.5
        val n = jd - 2451545.0
        val l = normal(280.460 + 0.9856474 * n)
        val g = normal(357.528 + 0.9856003 * n) * RAD
        val bujur = normal(l + 1.915 * sin(g) + 0.020 * sin(2 * g))
        val miring = (23.439 - 0.0000004 * n) * RAD
        val lam = bujur * RAD
        val ra = normal(atan2(cos(miring) * sin(lam), cos(lam)) / RAD)
        val dek = asin(sin(miring) * sin(lam))
        val gmst = normal(280.46061837 + 360.98564736629 * (jd - 2451545.0))
        val h = (gmst + lon - ra) * RAD
        val f = lat * RAD
        val s = sin(f) * sin(dek) + cos(f) * cos(dek) * cos(h)
        return asin(s.coerceIn(-1.0, 1.0)) / RAD
    }

    fun ozon(lat: Double): Double {
        val a = abs(lat)
        return (260 + (a - 15) / 30 * 40).coerceIn(260.0, 320.0)
    }

    fun faktorAwan(persen: Int?): Double {
        if (persen == null) return 1.0
        val n = persen.coerceIn(0, 100) / 100.0
        return 1 - 0.75 * n.pow(3.4)
    }

    fun perkiraan(lat: Double, lon: Double, utcMs: Long, awanPersen: Int?): Double {
        val tinggi = tinggiMatahari(lat, lon, utcMs)
        if (tinggi <= 0) return 0.0
        val mu0 = sin(tinggi * RAD)
        val cerah = 12.5 * mu0.pow(2.42) * (ozon(lat) / 300).pow(-1.23)
        return cerah * faktorAwan(awanPersen)
    }

    /** 0 rendah, 1 sedang, 2 tinggi, 3 sangat tinggi, 4 ekstrem (WHO). */
    fun kategori(uvi: Double): Int {
        val n = uvi.roundToInt()
        return when {
            n <= 2 -> 0
            n <= 5 -> 1
            n <= 7 -> 2
            n <= 10 -> 3
            else -> 4
        }
    }
}

object KategoriAqi {
    /** 0 baik, 1 sedang, 2 sensitif, 3 tidak sehat, 4 sangat tidak sehat, 5 berbahaya (US AQI). */
    fun indeks(aqi: Int): Int = when {
        aqi <= 50 -> 0
        aqi <= 100 -> 1
        aqi <= 150 -> 2
        aqi <= 200 -> 3
        aqi <= 300 -> 4
        else -> 5
    }
}

/** Nilai satu entri prakiraan BMKG yang dibutuhkan widget (semua teks). */
data class CuacaWidget(
    val suhu: String,
    val kelembapan: String,
    val angin: String,
    val kondisiId: String,
    val kondisiEn: String,
    val kode: String,
    val malam: Boolean,
    val awan: String,
)

object PenguraiWidget {

    /** Entri prakiraan BMKG yang waktunya paling dekat dengan [sekarangMs]. */
    fun pilihTerdekat(json: JSONObject, sekarangMs: Long): JSONObject? {
        val data = json.optJSONArray("data") ?: return null
        val cuaca = data.optJSONObject(0)?.optJSONArray("cuaca") ?: return null
        var terbaik: JSONObject? = null
        var selisihTerbaik = Long.MAX_VALUE

        fun periksa(x: Any?) {
            when (x) {
                is JSONArray -> for (i in 0 until x.length()) periksa(x.opt(i))
                is JSONObject -> {
                    val waktu = waktuUtc(x) ?: return
                    val selisih = abs(waktu - sekarangMs)
                    if (selisih < selisihTerbaik) {
                        selisihTerbaik = selisih
                        terbaik = x
                    }
                }
            }
        }
        periksa(cuaca)
        return terbaik
    }

    fun waktuUtc(entri: JSONObject): Long? {
        val teks = entri.optString("utc_datetime", "").ifEmpty { entri.optString("datetime", "") }
        if (teks.length < 19) return null
        val pola = if (teks.contains('T')) "yyyy-MM-dd'T'HH:mm:ss" else "yyyy-MM-dd HH:mm:ss"
        return try {
            SimpleDateFormat(pola, Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
                .parse(teks.take(19))?.time
        } catch (e: Exception) {
            null
        }
    }

    private fun angka(e: JSONObject, kunci: String): String {
        if (!e.has(kunci) || e.isNull(kunci)) return ""
        return when (val v = e.opt(kunci)) {
            is Number -> v.toDouble().roundToInt().toString()
            is String -> v.toDoubleOrNull()?.roundToInt()?.toString() ?: ""
            else -> ""
        }
    }

    /** Malam bila jam setempat 18.00 sampai 05.59 (sama dengan aplikasi). */
    fun malam(e: JSONObject): Boolean {
        val lokal = e.optString("local_datetime", "")
        val jam = lokal.substringAfter(' ', "").take(2).toIntOrNull() ?: return false
        return jam >= 18 || jam < 6
    }

    fun dariEntri(e: JSONObject) = CuacaWidget(
        suhu = angka(e, "t"),
        kelembapan = angka(e, "hu"),
        angin = angka(e, "ws"),
        kondisiId = e.optString("weather_desc", ""),
        kondisiEn = e.optString("weather_desc_en", ""),
        kode = angka(e, "weather"),
        malam = malam(e),
        awan = angka(e, "tcc"),
    )

    /** `current.us_aqi` dari Open-Meteo Air Quality; null bila tidak ada. */
    fun parseAqi(json: JSONObject): Int? {
        val saat = json.optJSONObject("current") ?: return null
        if (!saat.has("us_aqi") || saat.isNull("us_aqi")) return null
        return (saat.opt("us_aqi") as? Number)?.toDouble()?.roundToInt()
    }

    /** Koordinat dibulatkan ke 0,1 derajat sebelum dikirim ke Open-Meteo. */
    fun bulatkan(derajat: Double): Double = (derajat * 10).roundToInt() / 10.0
}
