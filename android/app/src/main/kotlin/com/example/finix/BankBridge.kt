package com.example.finix

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings

/** Punto central: recibe textos (SMS o notificaciones), detecta movimientos y muestra el banner. */
object BankBridge {
    private val main = Handler(Looper.getMainLooper())
    private const val CHANNEL = "finix_bank"
    private const val NOTIF_ID = 4201

    /** Lo asigna MainActivity para avisarle a Flutter que hay movimientos listos. */
    @Volatile
    var onChanged: (() -> Unit)? = null

    const val SAMPLE =
        "Bancolombia: JUAN, recibiste una transferencia de NILVA LUNA CARTAGENA por \$30,000.00 en tu cuenta *6625"

    /** true mientras Finix está en pantalla (lo actualiza MainActivity). */
    @Volatile
    var appVisible = false

    fun handle(ctx: Context, text: String, test: Boolean = false) {
        val r = BankParser.parse(text) ?: return
        handleResult(ctx, r, test)
    }

    fun handleResult(ctx: Context, r: BankParser.Result, test: Boolean = false) {
        val app = ctx.applicationContext
        if (!test && !BankStore.isEnabled(app)) return
        if (!test && !BankStore.markSeen(app, r)) return
        BankStore.add(app, r, test)
        main.post { showBanner(app) }
    }

    fun showBanner(ctx: Context) {
        val canOverlay = Settings.canDrawOverlays(ctx)
        // En Xiaomi, sin "ventanas emergentes en segundo plano" el banner queda oculto
        // hasta abrir la app: mejor avisar con una notificación que lo abre.
        val blocked = !appVisible && Miui.popupsAllowed(ctx) == false
        if (canOverlay && !blocked) BannerOverlay.showNext(ctx) else notifyFallback(ctx)
    }

    fun changed() = main.post { onChanged?.invoke() }

    /** Notificación (emergente) que abre el banner al tocarla. */
    fun notifyFallback(ctx: Context) {
        val item = BankStore.nextPending(ctx) ?: return
        val nm = ctx.getSystemService(NotificationManager::class.java) ?: return
        if (Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel(CHANNEL, "Movimientos detectados", NotificationManager.IMPORTANCE_HIGH),
            )
        }
        val pi = PendingIntent.getActivity(
            ctx, 0,
            Intent(ctx, BannerActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val kind = if (item.income) "un ingreso" else "un gasto"
        @Suppress("DEPRECATION")
        val b = if (Build.VERSION.SDK_INT >= 26) Notification.Builder(ctx, CHANNEL) else Notification.Builder(ctx)
        val n = b.setSmallIcon(R.drawable.ic_send)
            .setContentTitle("Finix detectó $kind de ${Money.format(item.amount)}")
            .setContentText("${item.hint} · Toca para ponerle nombre")
            .setContentIntent(pi)
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_REMINDER)
            .apply {
                @Suppress("DEPRECATION")
                if (Build.VERSION.SDK_INT < 26) setPriority(Notification.PRIORITY_HIGH)
            }
            .build()
        try {
            nm.notify(NOTIF_ID, n)
        } catch (_: SecurityException) {
            // Sin permiso de notificaciones: se guardará solo con el nombre sugerido.
        }
    }

    fun cancelNotification(ctx: Context) {
        ctx.getSystemService(NotificationManager::class.java)?.cancel(NOTIF_ID)
    }
}

object Money {
    /** 30000 → "$30.000" */
    fun format(v: Long): String {
        val s = kotlin.math.abs(v).toString().reversed().chunked(3).joinToString(".").reversed()
        return "$$s"
    }
}
