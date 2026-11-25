package com.example.app

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters
import org.json.JSONObject
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale

/**
 * Menyegarkan data widget di latar belakang (tiap jam, hanya saat ada
 * jaringan) lalu menggambar ulang widget:
 *
 * - Cuaca: satu permintaan ke API publik BMKG untuk wilayah yang disimpan
 *   aplikasi (adm4), dilewati bila data masih segar (kurang dari 30 menit,
 *   mis. baru saja dimuat aplikasi). Jauh di bawah batas BMKG (60 permintaan
 *   per menit per IP).
 * - Kualitas udara: satu permintaan ke Open-Meteo (model CAMS, tanpa kunci,
 *   CC BY 4.0) dengan koordinat titik pusat wilayah yang dibulatkan ke
 *   0,1 derajat; dilewati bila masih segar (kurang dari 45 menit).
 *
 * Bila salah satu gagal, data lama tetap tampil (diberi tanda "data lama"
 * bila cuaca lebih dari 6 jam) dan pekerjaan diulang oleh WorkManager.
 */
class PembaruWidgetWorker(context: Context, params: WorkerParameters) : Worker(context, params) {

    override fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val sekarang = System.currentTimeMillis()
        var gagal = false

        val adm4 = prefs.getString("adm4", null)
        val cuacaSegar = prefs.getString("diperbarui_ms", null)?.toLongOrNull()
            ?.let { sekarang - it < SEGAR_CUACA_MS } == true
        if (!adm4.isNullOrEmpty() && adm4.matches(Regex("[0-9.]{4,20}")) && !cuacaSegar) {
            try {
                val entri = PenguraiWidget.pilihTerdekat(
                    ambilJson("https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4"),
                    sekarang,
                )
                if (entri == null) {
                    gagal = true
                } else {
                    val c = PenguraiWidget.dariEntri(entri)
                    prefs.edit()
                        .putString("suhu", c.suhu)
                        .putString("kelembapan", c.kelembapan)
                        .putString("angin", c.angin)
                        .putString("kondisi_id", c.kondisiId)
                        .putString("kondisi_en", c.kondisiEn)
                        .putString("kode", c.kode)
                        .putString("malam", if (c.malam) "1" else "0")
                        .putString("awan", c.awan)
                        .putString("ada_data", "1")
                        .putString("diperbarui_ms", sekarang.toString())
                        .apply()
                }
            } catch (e: Exception) {
                gagal = true
            }
        }

        val lat = prefs.getString("lat", null)?.toDoubleOrNull()
        val lon = prefs.getString("lon", null)?.toDoubleOrNull()
        val udaraSegar = prefs.getString("aqi_ms", null)?.toLongOrNull()
            ?.let { sekarang - it < SEGAR_UDARA_MS } == true
        if (lat != null && lon != null && !udaraSegar) {
            try {
                val url = String.format(
                    Locale.US,
                    "https://air-quality-api.open-meteo.com/v1/air-quality" +
                        "?latitude=%.1f&longitude=%.1f&current=us_aqi&timezone=auto",
                    PenguraiWidget.bulatkan(lat),
                    PenguraiWidget.bulatkan(lon),
                )
                val aqi = PenguraiWidget.parseAqi(ambilJson(url))
                if (aqi == null) {
                    gagal = true
                } else {
                    prefs.edit()
                        .putString("aqi", aqi.toString())
                        .putString("aqi_ms", sekarang.toString())
                        .apply()
                }
            } catch (e: Exception) {
                gagal = true
            }
        }

        WidgetCuacaProvider.perbaruiSemua(applicationContext)
        return if (gagal) Result.retry() else Result.success()
    }

    private fun ambilJson(alamat: String): JSONObject {
        val koneksi = URL(alamat).openConnection() as HttpURLConnection
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

    private companion object {
        const val SEGAR_CUACA_MS = 30L * 60 * 1000
        const val SEGAR_UDARA_MS = 45L * 60 * 1000
    }
}
