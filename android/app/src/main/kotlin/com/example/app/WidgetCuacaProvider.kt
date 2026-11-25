package com.example.app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import java.util.concurrent.TimeUnit

/**
 * Widget layar utama "Cuaca SiCuaca": suhu, kondisi, wilayah, dan jam data.
 *
 * Datanya dari prakiraan BMKG yang disimpan aplikasi ke
 * SharedPreferences ("HomeWidgetPreferences", lewat paket home_widget).
 * Selama widget terpasang, [PembaruWidgetWorker] menyegarkan data dari
 * BMKG tiap jam di latar belakang, jadi widget tidak bergantung pada
 * aplikasi dibuka.
 *
 * Widget selalu menampilkan "Sumber: BMKG"; SiCuaca bukan aplikasi resmi
 * BMKG (dinyatakan di deskripsi widget dan di dalam aplikasi).
 */
class WidgetCuacaProvider : HomeWidgetProvider() {

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        jadwalkanPembaruan(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        WorkManager.getInstance(context).cancelUniqueWork(NAMA_KERJA)
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        // Pastikan pembaruan latar belakang terjadwal (aman dipanggil ulang).
        jadwalkanPembaruan(context)
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buatTampilan(context, widgetData))
        }
    }

    companion object {
        const val NAMA_KERJA = "widget_cuaca_pembaruan"
        private const val LAMA_BASI_MS = 6L * 60 * 60 * 1000

        fun jadwalkanPembaruan(context: Context) {
            val permintaan = PeriodicWorkRequestBuilder<PembaruWidgetWorker>(60, TimeUnit.MINUTES)
                .setConstraints(
                    Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build()
                )
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                NAMA_KERJA,
                ExistingPeriodicWorkPolicy.KEEP,
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
                manager.updateAppWidget(id, buatTampilan(context, data))
            }
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

        private fun buatTampilan(context: Context, data: SharedPreferences): RemoteViews {
            val v = RemoteViews(context.packageName, R.layout.widget_cuaca)
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
            }.joinToString(" · ")
            v.setTextViewText(R.id.widget_detail, detail)

            val diperbarui = data.getString("diperbarui_ms", null)?.toLongOrNull()
            val jam = if (diperbarui == null) "" else SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(diperbarui))
            val basi = diperbarui != null && System.currentTimeMillis() - diperbarui > LAMA_BASI_MS
            val sumber = if (jam.isEmpty()) {
                context.getString(R.string.widget_sumber_kosong)
            } else if (basi) {
                context.getString(R.string.widget_sumber_lama, jam)
            } else {
                context.getString(R.string.widget_sumber, jam)
            }
            v.setTextViewText(R.id.widget_sumber, sumber)
            return v
        }
    }
}
