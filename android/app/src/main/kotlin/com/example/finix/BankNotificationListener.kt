package com.example.finix

import android.app.Notification
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

/**
 * Android mantiene este servicio vivo en segundo plano (aunque Finix esté cerrada)
 * y le pasa cada notificación: SMS del banco, app de Bancolombia, Nequi, etc.
 */
class BankNotificationListener : NotificationListenerService() {

    private val skip = setOf(
        "com.whatsapp", "com.whatsapp.w4b", "org.telegram.messenger", "com.facebook.orca",
        "com.instagram.android", "com.google.android.gm",
    )

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName || sbn.packageName in skip) return
        val n = sbn.notification ?: return
        if (n.flags and Notification.FLAG_GROUP_SUMMARY != 0) return
        val ex = n.extras ?: return

        val texts = mutableListOf<String>()
        val now = System.currentTimeMillis()

        // Apps de mensajes (estilo conversación): solo los mensajes recientes.
        @Suppress("DEPRECATION")
        val messages = ex.getParcelableArray(Notification.EXTRA_MESSAGES)
        if (!messages.isNullOrEmpty()) {
            for (m in messages) {
                val b = m as? Bundle ?: continue
                val text = b.getCharSequence("text")?.toString() ?: continue
                val time = b.getLong("time", 0L)
                if (time == 0L || now - time < 30 * 60_000L) texts += text
            }
        } else {
            val title = ex.getCharSequence(Notification.EXTRA_TITLE)?.toString().orEmpty()
            val body = (ex.getCharSequence(Notification.EXTRA_BIG_TEXT)
                ?: ex.getCharSequence(Notification.EXTRA_TEXT))?.toString() ?: return
            texts += "$title: $body"
        }
        texts.forEach { BankBridge.handle(this, it) }
    }
}
