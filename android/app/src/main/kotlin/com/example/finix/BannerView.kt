package com.example.finix

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.Keyframe
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Color
import android.graphics.Outline
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.LayerDrawable
import android.text.InputType
import android.text.TextUtils
import android.view.Gravity
import android.view.KeyEvent
import android.view.View
import android.view.ViewOutlineProvider
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView

/**
 * Banner "¿Qué nombre le damos?" que aparece abajo con rebote.
 * Al tocar Enviar, el avioncito despega y sale volando por la derecha.
 */
@SuppressLint("ViewConstructor", "SetTextI18n")
class BannerView(
    ctx: Context,
    private val item: BankItem,
    private val onResolved: (String) -> Unit,
    private val onFinished: () -> Unit,
) : FrameLayout(ctx) {

    private val card = FrameLayout(ctx)
    private val input = EditText(ctx)
    private val plane = ImageView(ctx)
    private val sendLabel = TextView(ctx)
    private var busy = false

    private fun dp(v: Float) = v * resources.displayMetrics.density
    private fun dp(v: Int) = dp(v.toFloat()).toInt()

    init {
        clipChildren = false
        clipToPadding = false
        // Espacio arriba para el rebote y el vuelo del avión.
        setPadding(dp(14), dp(56), dp(14), dp(14))
        isFocusableInTouchMode = true

        card.apply {
            clipChildren = false
            clipToPadding = false
            background = cardBackground()
            elevation = dp(18f)
            alpha = 0f
        }
        addView(card, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT, Gravity.BOTTOM))

        val col = LinearLayout(ctx).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            clipChildren = false
            clipToPadding = false
            setPadding(dp(22), dp(22), dp(22), dp(20))
        }
        card.addView(col, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT))

        // Botón cerrar (arriba a la derecha)
        val close = ImageView(ctx).apply {
            setImageResource(R.drawable.ic_close)
            setColorFilter(Color.WHITE)
            background = shape(0x33FFFFFF, oval = true)
            setPadding(dp(8), dp(8), dp(8), dp(8))
            contentDescription = "Cerrar"
            setOnClickListener { dismiss() }
        }
        card.addView(close, LayoutParams(dp(36), dp(36), Gravity.TOP or Gravity.END).apply {
            setMargins(0, dp(14), dp(14), 0)
        })

        // Logo + nombre
        val logo = ImageView(ctx).apply {
            setImageResource(R.drawable.finix_logo)
            scaleType = ImageView.ScaleType.CENTER_CROP
            outlineProvider = object : ViewOutlineProvider() {
                override fun getOutline(v: View, o: Outline) = o.setRoundRect(0, 0, v.width, v.height, dp(16f))
            }
            clipToOutline = true
        }
        col.addView(logo, LinearLayout.LayoutParams(dp(60), dp(60)))
        col.addView(label("Finix", 28f, Typeface.BOLD, Color.WHITE), wrap(top = 4))

        // Monto e indicador de ingreso / gasto
        val sign = if (item.income) "+ " else "− "
        col.addView(label(sign + Money.format(item.amount), 32f, Typeface.BOLD, Color.WHITE), wrap(top = 2))
        val chip = label(
            if (item.income) "↓  Ingreso" else "↑  Gasto", 13f, Typeface.BOLD,
            if (item.income) 0xFF7CF5B5.toInt() else 0xFFFFB08A.toInt(),
        ).apply {
            background = shape(if (item.income) 0x3322C55E else 0x40F97316)
            setPadding(dp(16), dp(5), dp(16), dp(6))
        }
        col.addView(chip, wrap(top = 6))

        col.addView(label("¿Qué nombre le damos?", 16f, Typeface.BOLD, Color.WHITE), wrap(top = 14))
        col.addView(
            label("${item.bank} · ${item.hint}", 12.5f, Typeface.NORMAL, 0xB3FFFFFF.toInt()).apply {
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
            },
            wrap(top = 2),
        )

        // Campo para escribir el nombre
        val field = LinearLayout(ctx).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            background = shape(0x1FFFFFFF, stroke = 0x55FFFFFF)
            setPadding(dp(18), 0, dp(14), 0)
        }
        field.addView(ImageView(ctx).apply {
            setImageResource(R.drawable.ic_edit)
            setColorFilter(Color.WHITE)
            alpha = 0.85f
        }, LinearLayout.LayoutParams(dp(20), dp(20)))
        input.apply {
            background = null
            hint = item.hint
            setHintTextColor(0x99FFFFFF.toInt())
            setTextColor(Color.WHITE)
            textSize = 15f
            isSingleLine = true
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
            imeOptions = EditorInfo.IME_ACTION_SEND
            setPadding(dp(12), 0, 0, 0)
            setOnEditorActionListener { _, action, _ ->
                if (action == EditorInfo.IME_ACTION_SEND) { send(); true } else false
            }
        }
        field.addView(input, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.MATCH_PARENT, 1f))
        col.addView(field, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(54)).apply {
            topMargin = dp(16)
        })

        // Botón Enviar con el avioncito
        val button = FrameLayout(ctx).apply {
            clipChildren = false
            clipToPadding = false
            background = GradientDrawable(
                GradientDrawable.Orientation.LEFT_RIGHT,
                intArrayOf(0xFF45F2AA.toInt(), 0xFF12B76A.toInt()),
            ).apply { cornerRadius = dp(28f) }
            elevation = dp(6f)
            isClickable = true
            contentDescription = "Enviar"
            setOnClickListener { send() }
        }
        val row = LinearLayout(ctx).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            clipChildren = false
            clipToPadding = false
        }
        plane.apply {
            setImageResource(R.drawable.ic_send)
            setColorFilter(Color.WHITE)
            rotation = -28f
        }
        row.addView(plane, LinearLayout.LayoutParams(dp(24), dp(24)))
        sendLabel.apply {
            text = "Enviar"
            textSize = 17f
            setTypeface(typeface, Typeface.BOLD)
            setTextColor(Color.WHITE)
        }
        row.addView(sendLabel, LinearLayout.LayoutParams(-2, -2).apply { marginStart = dp(10) })
        button.addView(row, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT, Gravity.CENTER))
        col.addView(button, LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(56)).apply {
            topMargin = dp(12)
        })

        post { enter() }
    }

    /* ───────────── Animaciones ───────────── */

    /** Entra desde abajo con rebote. */
    private fun enter() {
        val from = (height - card.top).toFloat() + dp(40f)
        card.translationY = from
        card.alpha = 1f
        val y = PropertyValuesHolder.ofKeyframe(
            View.TRANSLATION_Y,
            Keyframe.ofFloat(0f, from),
            Keyframe.ofFloat(0.48f, -dp(28f)).apply { interpolator = DecelerateInterpolator(1.4f) },
            Keyframe.ofFloat(0.68f, dp(12f)).apply { interpolator = AccelerateDecelerateInterpolator() },
            Keyframe.ofFloat(0.84f, -dp(5f)).apply { interpolator = AccelerateDecelerateInterpolator() },
            Keyframe.ofFloat(1f, 0f).apply { interpolator = AccelerateDecelerateInterpolator() },
        )
        val sx = PropertyValuesHolder.ofKeyframe(
            View.SCALE_X,
            Keyframe.ofFloat(0f, 0.94f), Keyframe.ofFloat(0.48f, 1.01f),
            Keyframe.ofFloat(0.68f, 0.99f), Keyframe.ofFloat(1f, 1f),
        )
        ObjectAnimator.ofPropertyValuesHolder(card, y, sx).setDuration(950).start()
    }

    /** Enviar: el avión retrocede un poco, despega y desaparece por la derecha. */
    fun send() {
        if (busy) return
        busy = true
        hideKeyboard()
        input.isEnabled = false
        onResolved(input.text.toString().trim().ifEmpty { item.hint })

        sendLabel.animate().alpha(0f).translationX(dp(24f)).setDuration(200).start()

        val loc = IntArray(2)
        plane.getLocationOnScreen(loc)
        val dx = (resources.displayMetrics.widthPixels - loc[0]).toFloat() + dp(60f)

        val windUp = AnimatorSet().apply {
            playTogether(
                ObjectAnimator.ofFloat(plane, View.TRANSLATION_X, 0f, -dp(16f)),
                ObjectAnimator.ofFloat(plane, View.TRANSLATION_Y, 0f, dp(4f)),
                ObjectAnimator.ofFloat(plane, View.ROTATION, -28f, -8f),
                ObjectAnimator.ofFloat(plane, View.SCALE_X, 1f, 0.85f),
                ObjectAnimator.ofFloat(plane, View.SCALE_Y, 1f, 0.85f),
            )
            duration = 200
            interpolator = DecelerateInterpolator()
        }
        val fly = AnimatorSet().apply {
            playTogether(
                ObjectAnimator.ofFloat(plane, View.TRANSLATION_X, -dp(16f), dx),
                ObjectAnimator.ofFloat(plane, View.TRANSLATION_Y, dp(4f), -dp(14f), -dp(46f), -dp(80f)),
                ObjectAnimator.ofFloat(plane, View.ROTATION, -8f, -34f, -42f),
                ObjectAnimator.ofFloat(plane, View.SCALE_X, 0.85f, 1.4f),
                ObjectAnimator.ofFloat(plane, View.SCALE_Y, 0.85f, 1.4f),
                ObjectAnimator.ofFloat(plane, View.ALPHA, 1f, 1f, 1f, 0f),
            )
            duration = 700
            interpolator = AccelerateInterpolator(1.5f)
        }
        AnimatorSet().apply {
            playSequentially(windUp, fly)
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    sendLabel.text = "¡Guardado!"
                    sendLabel.translationX = -dp(17f) // centra el texto sin el avión
                    sendLabel.animate().alpha(1f).setDuration(180).start()
                    postDelayed({ exit() }, 650)
                }
            })
            start()
        }
    }

    /** Cerrar con la X: se guarda con el nombre sugerido. */
    fun dismiss() {
        if (busy) return
        busy = true
        hideKeyboard()
        onResolved(item.hint)
        exit()
    }

    private fun exit() {
        card.animate()
            .translationY(card.height + dp(80f))
            .alpha(0f)
            .setInterpolator(AccelerateInterpolator())
            .setDuration(320)
            .withEndAction { onFinished() }
            .start()
    }

    private fun hideKeyboard() {
        context.getSystemService(InputMethodManager::class.java)
            ?.hideSoftInputFromWindow(input.windowToken, 0)
    }

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (event.keyCode == KeyEvent.KEYCODE_BACK) {
            if (event.action == KeyEvent.ACTION_UP) dismiss()
            return true
        }
        return super.dispatchKeyEvent(event)
    }

    /* ───────────── Estilos ───────────── */

    private fun cardBackground(): LayerDrawable {
        val r = dp(30f)
        val base = GradientDrawable(
            GradientDrawable.Orientation.TL_BR,
            intArrayOf(0xF50B2A2B.toInt(), 0xF50E4A40.toInt(), 0xF515956B.toInt()),
        ).apply {
            cornerRadius = r
            setStroke(dp(1), 0x6646E8A8)
        }
        fun glow(cx: Float, cy: Float, color: Int, radius: Float) = GradientDrawable().apply {
            gradientType = GradientDrawable.RADIAL_GRADIENT
            colors = intArrayOf(color, color and 0x00FFFFFF)
            setGradientCenter(cx, cy)
            gradientRadius = radius
            cornerRadius = r
        }
        return LayerDrawable(
            arrayOf(
                base,
                glow(1f, 0f, 0x6634E89E, dp(230f)),
                glow(0f, 1f, 0x4434E89E, dp(200f)),
            ),
        )
    }

    private fun shape(color: Int, oval: Boolean = false, stroke: Int? = null) = GradientDrawable().apply {
        if (oval) shape = GradientDrawable.OVAL else cornerRadius = dp(100f)
        setColor(color)
        if (stroke != null) setStroke(dp(1), stroke)
    }

    private fun label(text: String, size: Float, style: Int, color: Int) = TextView(context).apply {
        this.text = text
        textSize = size
        setTypeface(Typeface.create("sans-serif", style))
        setTextColor(color)
        gravity = Gravity.CENTER
    }

    private fun wrap(top: Int) = LinearLayout.LayoutParams(-2, -2).apply { topMargin = dp(top) }
}
