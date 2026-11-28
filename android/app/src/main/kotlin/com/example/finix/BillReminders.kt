package com.example.finix

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

/**
 * Recordatorios de pagos fijos. Una alarma diaria (9:00 a. m.) revisa los pagos
 * y notifica los que están por vencer, aunque Finix esté cerrada.
 */
object BillReminders {
    private const val PREFS = "finix_bills"
    private const val CHANNEL = "finix_bills"
    private const val ACTION_CHECK = "com.example.finix.CHECK_BILLS"

    private fun prefs(c: Context) = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    /** Guarda la lista que manda Flutter y programa la alarma diaria. */
    fun sync(c: Context, enabled: Boolean, bills: List<Map<String, Any?>>) {
        val arr = JSONArray()
        bills.forEach { arr.put(JSONObject(it)) }
        prefs(c).edit().putBoolean("enabled", enabled).putString("bills", arr.toString()).apply()
        schedule(c)
        check(c)
    }

    fun schedule(c: Context) {
        val am = c.getSystemService(AlarmManager::class.java) ?: return
        val pi = PendingIntent.getBroadcast(
            c, 0, Intent(c, BillReminderReceiver::class.java).setAction(ACTION_CHECK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val at = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 9)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            if (timeInMillis <= System.currentTimeMillis()) add(Calendar.DAY_OF_YEAR, 1)
        }
        // Inexacta: no necesita permisos especiales y gasta menos batería.
        am.setInexactRepeating(AlarmManager.RTC_WAKEUP, at.timeInMillis, AlarmManager.INTERVAL_DAY, pi)
    }

    private fun key(y: Int, m0: Int) = "%04d-%02d".format(y, m0 + 1)

    /** Días que faltan para el próximo vencimiento sin pagar (negativo = vencido). */
    fun daysLeft(dueDay: Int, paidMonth: String, today: Calendar = Calendar.getInstance()): Int {
        val t = (today.clone() as Calendar).apply {
            set(Calendar.HOUR_OF_DAY, 0); set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
        }
        val m = t.clone() as Calendar
        m.set(Calendar.DAY_OF_MONTH, 1)
        repeat(24) {
            if (paidMonth.isEmpty() || key(m.get(Calendar.YEAR), m.get(Calendar.MONTH)) > paidMonth) {
                val due = m.clone() as Calendar
                due.set(Calendar.DAY_OF_MONTH, minOf(dueDay, m.getActualMaximum(Calendar.DAY_OF_MONTH)))
                return Math.round((due.timeInMillis - t.timeInMillis) / 86_400_000.0).toInt()
            }
            m.add(Calendar.MONTH, 1)
        }
        return 999
    }

    /** Revisa los pagos y avisa (máximo una vez al día por pago). */
    fun check(c: Context) {
        val p = prefs(c)
        if (!p.getBoolean("enabled", true)) return
        val arr = JSONArray(p.getString("bills", "[]"))
        val today = Calendar.getInstance().let { key(it.get(Calendar.YEAR), it.get(Calendar.MONTH)) +
            "-%02d".format(it.get(Calendar.DAY_OF_MONTH)) }
        val nm = c.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL, "Recordatorios de pagos", NotificationManager.IMPORTANCE_HIGH),
            )
        }
        val edit = p.edit()
        for (i in 0 until arr.length()) {
            val b = arr.getJSONObject(i)
            val id = b.optString("id")
            val days = daysLeft(b.optInt("dueDay", 1), b.optString("paidMonth"))
            val remind = b.optInt("remindDays", 3)
            if (days > remind || days < -5) continue
            if (p.getString("notified_$id", "") == today) continue

            val title = "${b.optString("emoji")} ${b.optString("title")} " + when {
                days < 0 -> "venció hace ${-days} ${if (days == -1) "día" else "días"}"
                days == 0 -> "vence hoy"
                days == 1 -> "vence mañana"
                else -> "vence en $days días"
            }
            val text = "${Money.format(b.optLong("amount"))} · Toca para marcarlo como pagado"
            val open = PendingIntent.getActivity(
                c, id.hashCode(),
                c.packageManager.getLaunchIntentForPackage(c.packageName)
                    ?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    ?.putExtra("open", "bills"),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
            @Suppress("DEPRECATION")
            val builder = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(c, CHANNEL) else Notification.Builder(c)
            val n = builder.setSmallIcon(R.drawable.ic_bell)
                .setContentTitle(title)
                .setContentText(text)
                .setColor(0xFF1FB86A.toInt())
                .setContentIntent(open)
                .setAutoCancel(true)
                .build()
            try {
                nm.notify(5000 + (id.hashCode() and 0xFFFF), n)
                edit.putString("notified_$id", today)
            } catch (_: SecurityException) {
                // Sin permiso de notificaciones.
            }
        }
        edit.apply()
    }
}

/** Se ejecuta con la alarma diaria y al reiniciar el celular. */
class BillReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> BillReminders.schedule(context)
            else -> BillReminders.check(context)
        }
    }
}
