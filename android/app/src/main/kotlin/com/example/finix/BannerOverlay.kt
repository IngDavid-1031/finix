package com.example.finix

import android.content.Context
import android.graphics.PixelFormat
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.ContextThemeWrapper
import android.view.Gravity
import android.view.View
import android.view.WindowInsets
import android.view.WindowManager

/** Muestra el banner encima de cualquier app (permiso "Mostrar sobre otras apps"). */
object BannerOverlay {
    private var current: BannerView? = null

    fun showNext(ctx: Context) {
        if (current != null) return // al terminar el actual se muestra el siguiente
        val app = ctx.applicationContext
        val item = BankStore.nextPending(app) ?: return
        BankBridge.cancelNotification(app)

        val wm = app.getSystemService(WindowManager::class.java) ?: return
        val themed = ContextThemeWrapper(app, android.R.style.Theme_Material_Light_NoActionBar)
        var view: BannerView? = null
        view = BannerView(
            themed, item,
            onResolved = { title ->
                BankStore.resolve(app, item.id, title)
                BankBridge.changed()
            },
            onFinished = {
                try { wm.removeView(view) } catch (_: Exception) {}
                current = null
                showNext(app)
            },
        )

        @Suppress("DEPRECATION")
        val type = if (Build.VERSION.SDK_INT >= 26) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else WindowManager.LayoutParams.TYPE_PHONE
        val lp = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            // Los toques fuera del banner siguen llegando a la app de atrás.
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            PixelFormat.TRANSLUCENT,
        ).apply {
            gravity = Gravity.BOTTOM
            softInputMode = WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE or
                WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN
            if (Build.VERSION.SDK_INT >= 30) {
                // Queda encima de la barra de navegación y sube con el teclado.
                fitInsetsTypes = WindowInsets.Type.systemBars() or WindowInsets.Type.ime()
            }
        }
        try {
            wm.addView(view, lp)
            current = view
        } catch (_: Exception) {
            // Sin permiso real: avisamos con una notificación que abre el banner.
            BankBridge.notifyFallback(app)
            return
        }

        // Algunos celulares (Xiaomi) aceptan la ventana pero no la muestran si Finix
        // está en segundo plano. Si no se ve, la quitamos y avisamos con notificación.
        val shown = view
        main.postDelayed({
            if (current !== shown || BankBridge.appVisible) return@postDelayed
            val visible = shown.isAttachedToWindow && shown.windowVisibility == View.VISIBLE &&
                shown.height > 0
            if (!visible) {
                try { wm.removeViewImmediate(shown) } catch (_: Exception) {}
                current = null
                BankBridge.notifyFallback(app)
            }
        }, 1500)
    }

    private val main = Handler(Looper.getMainLooper())
}
