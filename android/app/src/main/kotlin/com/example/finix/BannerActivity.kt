package com.example.finix

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.view.Gravity
import android.view.WindowInsets
import android.widget.FrameLayout

/** Mismo banner, abierto al tocar la notificación (cuando no hay permiso de superposición). */
class BannerActivity : Activity() {
    private lateinit var root: FrameLayout
    private var banner: BannerView? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BankBridge.cancelNotification(this)
        root = FrameLayout(this).apply {
            clipChildren = false
            setBackgroundColor(0x33000000)
            setOnApplyWindowInsetsListener { v, insets ->
                @Suppress("DEPRECATION")
                val bottom = if (Build.VERSION.SDK_INT >= 30) {
                    insets.getInsets(WindowInsets.Type.ime() or WindowInsets.Type.systemBars()).bottom
                } else insets.systemWindowInsetBottom
                v.setPadding(0, 0, 0, bottom)
                insets
            }
        }
        setContentView(root)
        showNext()
    }

    private fun showNext() {
        val item = BankStore.nextPending(this)
        if (item == null) {
            finish()
            return
        }
        var view: BannerView? = null
        view = BannerView(
            this, item,
            onResolved = { title ->
                BankStore.resolve(this, item.id, title)
                BankBridge.changed()
            },
            onFinished = {
                root.removeView(view)
                banner = null
                showNext()
            },
        )
        banner = view
        root.addView(view, FrameLayout.LayoutParams(-1, -2, Gravity.BOTTOM))
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        val b = banner
        if (b != null) b.dismiss() else @Suppress("DEPRECATION") super.onBackPressed()
    }

    override fun finish() {
        super.finish()
        @Suppress("DEPRECATION")
        overridePendingTransition(0, 0)
    }
}
