package com.example.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit
import kotlin.math.roundToInt

/**
 * Widget layar utama "Cuaca SiCuaca" (4x2): suhu dan ikon besar, kondisi,
 * kelembapan dan angin, serta dua kartu kecil: indeks UV (perkiraan SiCuaca
 * dari posisi matahari dan tutupan awan BMKG) dan kualitas udara (US AQI dari
 * Open-Meteo, model CAMS). Footer selalu "Sumber: BMKG"; bila ada data udara
 * ditambah "udara: Open-Meteo". SiCuaca bukan aplikasi resmi BMKG (deskripsi
 * widget dan aplikasi menyatakannya).
 *
 * Data cuaca disimpan aplikasi ke SharedPreferences "HomeWidgetPreferences"
 * (paket home_widget). Selama widget terpasang, [PembaruWidgetWorker]
 * menyegarkan data tiap jam di latar belakang. UV dihitung ulang di sini tiap
 * widget digambar, jadi selalu sesuai jam sekarang.
 */
class WidgetCuacaProvider : HomeWidgetProvider() {

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        jadwalkanPembaruan(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        val kerja = WorkManager.getInstance(context)
        kerja.cancelUniqueWork(NAMA_KERJA)
        kerja.cancelUniqueWork(NAMA_KERJA_SEKALI)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        jadwalkanPembaruan(context)
        // Data udara belum ada atau sudah lama: segarkan sekarang juga (satu
        // kali), tanpa menunggu jadwal jam berikutnya.
        val aqiMs = widgetData.getString("aqi_ms", null)?.toLongOrNull()
        val butuhUdara = widgetData.getString("lat", "").orEmpty().isNotEmpty() &&
            (aqiMs == null || System.currentTimeMillis() - aqiMs > BASI_UDARA_MS)
        if (butuhUdara) jalankanSekali(context)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(
                id,
                buatTampilan(context, widgetData, apakahBesar(appWidgetManager, id)),
            )
        }
    }

    /** Widget diubah ukurannya: pilih ulang tata letak besar atau ringkas. */
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        val data = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        appWidgetManager.updateAppWidget(
            appWidgetId,
            buatTampilan(context, data, apakahBesar(appWidgetManager, appWidgetId)),
        )
    }

    companion object {
        /** Tinggi minimal (dp) untuk tata letak besar; di bawahnya ringkas. */
        private const val TINGGI_BESAR_DP = 195

        const val NAMA_KERJA = "widget_cuaca_pembaruan"
        const val NAMA_KERJA_SEKALI = "widget_cuaca_pembaruan_sekali"
        private const val LAMA_BASI_MS = 6L * 60 * 60 * 1000
        private const val BASI_UDARA_MS = 50L * 60 * 1000

        private val WARNA_UV = intArrayOf(
            0xFF4EB400.toInt(), 0xFFF7E400.toInt(), 0xFFF85900.toInt(),
            0xFFD8001D.toInt(), 0xFF6B49C8.toInt(),
        )
        private val WARNA_AQI = intArrayOf(
            0xFF00B83F.toInt(), 0xFFE6C700.toInt(), 0xFFFF7E00.toInt(),
            0xFFE60000.toInt(), 0xFF8F3F97.toInt(), 0xFF7E0023.toInt(),
        )

        private val SYARAT_JARINGAN = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        fun jadwalkanPembaruan(context: Context) {
            val permintaan = PeriodicWorkRequestBuilder<PembaruWidgetWorker>(60, TimeUnit.MINUTES)
                .setConstraints(SYARAT_JARINGAN)
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                NAMA_KERJA,
                ExistingPeriodicWorkPolicy.KEEP,
                permintaan,
            )
        }

        /** Satu kali jalan sekarang (bila belum ada yang antre). */
        fun jalankanSekali(context: Context) {
            val permintaan = OneTimeWorkRequestBuilder<PembaruWidgetWorker>()
                .setConstraints(SYARAT_JARINGAN)
                .build()
            WorkManager.getInstance(context).enqueueUniqueWork(
                NAMA_KERJA_SEKALI,
                ExistingWorkPolicy.KEEP,
                permintaan,
            )
        }

        /** Menggambar ulang semua widget terpasang dari data tersimpan. */
        fun perbaruiSemua(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, WidgetCuacaProvider::class.java))
            if (ids.isEmpty()) return
            val data = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            for (id in ids) {
                manager.updateAppWidget(id, buatTampilan(context, data, apakahBesar(manager, id)))
            }
        }

        /** Tinggi tak diketahui (0) dianggap besar, seperti tampilan awal. */
        private fun apakahBesar(manager: AppWidgetManager, id: Int): Boolean {
            val tinggi = manager.getAppWidgetOptions(id)
                .getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
            return tinggi == 0 || tinggi >= TINGGI_BESAR_DP
        }

        private fun adaBahasaInggris(data: SharedPreferences): Boolean {
            val pilihan = data.getString("bahasa", "sistem") ?: "sistem"
            return when (pilihan) {
                "en" -> true
                "id" -> false
                else -> Locale.getDefault().language == "en"
            }
        }

        /** Emoji kondisi dari kode cuaca BMKG; malam memakai bulan untuk cerah. */
        internal fun ikonKondisi(kode: Int?, malam: Boolean): String = when (kode) {
            0 -> if (malam) "🌙" else "☀️"
            1, 2 -> if (malam) "🌙" else "🌤️"
            3, 4 -> "☁️"
            5, 10, 45 -> "🌫️"
            60, 61, 63, 80 -> "🌧️"
            95, 97 -> "⛈️"
            else -> "⛅"
        }

        private fun namaUv(context: Context, kategori: Int): String = context.getString(
            when (kategori) {
                0 -> R.string.uv_0
                1 -> R.string.uv_1
                2 -> R.string.uv_2
                3 -> R.string.uv_3
                else -> R.string.uv_4
            },
        )

        private fun namaAqi(context: Context, kategori: Int): String = context.getString(
            when (kategori) {
                0 -> R.string.aqi_0
                1 -> R.string.aqi_1
                2 -> R.string.aqi_2
                3 -> R.string.aqi_3
                4 -> R.string.aqi_4
                else -> R.string.aqi_5
            },
        )

        /**
         * Isi kartu: tata letak besar menaruh angka besar dan kategori di
         * bawahnya. Tata letak ringkas memakai satu baris pendek berawalan
         * ("UV 7 · Tinggi", "AQI 114"); [kategoriDiRingkas] menentukan apakah
         * kategorinya ikut (titik warna tetap menandai kategori).
         */
        private fun isiKartu(
            v: RemoteViews,
            besar: Boolean,
            idNilai: Int,
            idKategori: Int,
            nilai: String,
            kategori: String,
            awalan: String,
            kategoriDiRingkas: Boolean,
        ) {
            if (besar) {
                v.setTextViewText(idNilai, nilai)
                v.setTextViewText(idKategori, kategori)
                return
            }
            val ada = nilai != "\u2013"
            val teks = when {
                !ada -> "$awalan \u00B7 $kategori"
                kategoriDiRingkas -> "$awalan $nilai \u00B7 $kategori"
                else -> "$awalan $nilai"
            }
            v.setTextViewText(idNilai, teks)
        }

        private fun buatTampilan(
            context: Context,
            data: SharedPreferences,
            besar: Boolean,
        ): RemoteViews {
            val v = RemoteViews(
                context.packageName,
                if (besar) R.layout.widget_cuaca else R.layout.widget_cuaca_kecil,
            )
            v.setOnClickPendingIntent(
                R.id.widget_akar,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
            )

            val suhu = data.getString("suhu", null)
            if (data.getString("ada_data", "0") != "1" || suhu.isNullOrEmpty()) {
                v.setTextViewText(R.id.widget_wilayah, context.getString(R.string.widget_nama))
                v.setViewVisibility(R.id.widget_isi, View.GONE)
                v.setViewVisibility(R.id.widget_kosong, View.VISIBLE)
                v.setTextViewText(R.id.widget_sumber, context.getString(R.string.widget_sumber_kosong))
                return v
            }
            v.setViewVisibility(R.id.widget_isi, View.VISIBLE)
            v.setViewVisibility(R.id.widget_kosong, View.GONE)

            val inggris = adaBahasaInggris(data)
            val kondisi = (if (inggris) data.getString("kondisi_en", "") else data.getString("kondisi_id", ""))
                ?.takeIf { it.isNotEmpty() }
                ?: data.getString("kondisi_id", "").orEmpty()

            v.setTextViewText(R.id.widget_wilayah, data.getString("wilayah", "").orEmpty())
            v.setTextViewText(
                R.id.widget_ikon,
                ikonKondisi(data.getString("kode", null)?.toIntOrNull(), data.getString("malam", "0") == "1"),
            )
            v.setTextViewText(R.id.widget_suhu, "$suhu°")
            v.setTextViewText(R.id.widget_kondisi, kondisi)

            val lembap = data.getString("kelembapan", "").orEmpty()
            val angin = data.getString("angin", "").orEmpty()
            val detail = buildList {
                if (lembap.isNotEmpty()) add(context.getString(R.string.widget_lembap, lembap))
                if (angin.isNotEmpty()) add(context.getString(R.string.widget_angin, angin))
            }.joinToString(if (besar) "\n" else " · ")
            v.setTextViewText(R.id.widget_detail, detail)

            // Indeks UV: dihitung dari posisi matahari dan tutupan awan BMKG.
            val lat = data.getString("lat", null)?.toDoubleOrNull()
            val lon = data.getString("lon", null)?.toDoubleOrNull()
            if (lat != null && lon != null) {
                v.setViewVisibility(R.id.widget_kartu_uv, View.VISIBLE)
                val uvi = UvHitung.perkiraan(
                    lat, lon, System.currentTimeMillis(), data.getString("awan", null)?.toIntOrNull(),
                )
                if (uvi < 0.5) {
                    v.setTextColor(R.id.widget_uv_titik, Color.parseColor("#9FB8DC"))
                    isiKartu(
                        v, besar, R.id.widget_uv_nilai, R.id.widget_uv_kategori,
                        "\u2013", context.getString(R.string.widget_uv_malam), "UV", true,
                    )
                } else {
                    val k = UvHitung.kategori(uvi)
                    v.setTextColor(R.id.widget_uv_titik, WARNA_UV[k])
                    isiKartu(
                        v, besar, R.id.widget_uv_nilai, R.id.widget_uv_kategori,
                        uvi.roundToInt().toString(), namaUv(context, k), "UV", true,
                    )
                }
            } else {
                v.setViewVisibility(R.id.widget_kartu_uv, View.GONE)
            }

            // Kualitas udara: US AQI dari Open-Meteo (disegarkan pekerja).
            val aqi = data.getString("aqi", null)?.toIntOrNull()
            val adaUdara = aqi != null
            if (aqi != null) {
                val k = KategoriAqi.indeks(aqi)
                v.setTextColor(R.id.widget_aqi_titik, WARNA_AQI[k])
                isiKartu(
                    v, besar, R.id.widget_aqi_nilai, R.id.widget_aqi_kategori,
                    aqi.toString(), namaAqi(context, k), "AQI", false,
                )
            } else {
                v.setTextColor(R.id.widget_aqi_titik, Color.parseColor("#9FB8DC"))
                isiKartu(
                    v, besar, R.id.widget_aqi_nilai, R.id.widget_aqi_kategori,
                    "\u2013", context.getString(R.string.widget_aqi_kosong), "AQI", false,
                )
            }
            v.setViewVisibility(
                R.id.widget_kartu_aqi,
                if (lat != null && lon != null) View.VISIBLE else View.GONE,
            )

            val diperbarui = data.getString("diperbarui_ms", null)?.toLongOrNull()
            val jam = if (diperbarui == null) "" else SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(diperbarui))
            val basi = diperbarui != null && System.currentTimeMillis() - diperbarui > LAMA_BASI_MS
            val sumber = when {
                jam.isEmpty() -> context.getString(R.string.widget_sumber_kosong)
                basi -> context.getString(R.string.widget_sumber_lama, jam)
                adaUdara -> context.getString(R.string.widget_sumber_udara, jam)
                else -> context.getString(R.string.widget_sumber, jam)
            }
            v.setTextViewText(R.id.widget_sumber, sumber)
            return v
        }
    }
}
