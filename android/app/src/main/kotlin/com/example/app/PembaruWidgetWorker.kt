package com.example.app

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONArray
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Locale
import java.util.TimeZone
import kotlin.math.abs

/**
 * Menyegarkan data widget dari API publik BMKG di latar belakang (tiap jam,
 * hanya saat ada jaringan), lalu menggambar ulang widget.
 *
 * Satu permintaan per jam untuk satu wilayah, jauh di bawah batas BMKG
 * (60 permintaan per menit per IP). Kode wilayah (adm4) disimpan aplikasi;
 * tanpa kode itu worker tidak melakukan apa-apa. Bila gagal, data lama
 * tetap tampil (diberi tanda "data lama" bila lebih dari 6 jam).
 */
class PembaruWidgetWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val adm4 = prefs.getString("adm4", null)
        if (adm4.isNullOrEmpty() || !adm4.matches(Regex("[0-9.]{4,20}"))) return Result.success()
        return try {
            val entri = pilihTerdekat(ambil(adm4)) ?: return Result.retry()
            prefs.edit()
                .putString("suhu", entri.optDoubleOrNull("t")?.let { Math.round(it).toString() } ?: "")
                .putString("kelembapan", entri.optDoubleOrNull("hu")?.let { Math.round(it).toString() } ?: "")
                .putString("angin", entri.optDoubleOrNull("ws")?.let { Math.round(it).toString() } ?: "")
                .putString("kondisi_id", entri.optString("weather_desc", ""))
                .putString("kondisi_en", entri.optString("weather_desc_en", ""))
                .putString("kode", entri.optString("weather", ""))
                .putString("malam", if (malam(entri)) "1" else "0")
                .putString("ada_data", "1")
                .putString("diperbarui_ms", System.currentTimeMillis().toString())
                .apply()
            WidgetCuacaProvider.perbaruiSemua(applicationContext)
            Result.success()
        } catch (e: Exception) {
            Result.retry()
        }
    }

    private fun ambil(adm4: String): JSONObject {
        val koneksi = URL("https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4")
            .openConnection() as HttpURLConnection
        try {
            koneksi.connectTimeout = 10_000
            koneksi.readTimeout = 15_000
            koneksi.setRequestProperty("Accept", "application/json")
            if (koneksi.responseCode != 200) throw IllegalStateException("HTTP ${koneksi.responseCode}")
            return JSONObject(koneksi.inputStream.bufferedReader().use { it.readText() })
        } finally {
            koneksi.disconnect()
        }
    }

    /** Entri prakiraan yang waktunya paling dekat dengan sekarang. */
    private fun pilihTerdekat(json: JSONObject): JSONObject? {
        val data = json.optJSONArray("data") ?: return null
        val cuaca = data.optJSONObject(0)?.optJSONArray("cuaca") ?: return null
        val sekarang = System.currentTimeMillis()
        var terbaik: JSONObject? = null
        var selisihTerbaik = Long.MAX_VALUE
        fun periksa(x: Any?) {
            when (x) {
                is JSONArray -> for (i in 0 until x.length()) periksa(x.opt(i))
                is JSONObject -> {
                    val waktu = waktuUtc(x) ?: return
                    val selisih = abs(waktu - sekarang)
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

    private fun waktuUtc(entri: JSONObject): Long? {
        val teks = entri.optString("utc_datetime", "").ifEmpty { entri.optString("datetime", "") }
        if (teks.isEmpty()) return null
        val pola = if (teks.contains('T')) "yyyy-MM-dd'T'HH:mm:ss" else "yyyy-MM-dd HH:mm:ss"
        return try {
            SimpleDateFormat(pola, Locale.US).apply { timeZone = TimeZone.getTimeZone("UTC") }
                .parse(teks.take(19))?.time
        } catch (e: Exception) {
            null
        }
    }

    /** Malam bila jam setempat 18.00 sampai 05.59 (sama dengan aplikasi). */
    private fun malam(entri: JSONObject): Boolean {
        val lokal = entri.optString("local_datetime", "")
        val jam = lokal.substringAfter(' ', "").take(2).toIntOrNull() ?: return false
        return jam >= 18 || jam < 6
    }

    private fun JSONObject.optDoubleOrNull(kunci: String): Double? {
        if (!has(kunci) || isNull(kunci)) return null
        val v = opt(kunci)
        return when (v) {
            is Number -> v.toDouble()
            is String -> v.toDoubleOrNull()
            else -> null
        }
    }
}
