package com.example.finix

import java.text.Normalizer
import java.util.Calendar
import java.util.Locale

/**
 * Lee el texto de un SMS / notificación del banco y extrae el movimiento.
 * Ejemplos soportados (Bancolombia, Nequi, etc.):
 *  - "Bancolombia: JUAN, recibiste una transferencia de NILVA LUNA por $30,000.00 ... el 26/11/26 a las 16:06"
 *  - "Bancolombia: Retiraste $1.160.000,00 en ALTAVISTUS1 de tu T.Deb **5392 el 25/10/2026 a las 14:02"
 *  - "Bancolombia: JUAN, transferiste $20,000.00 a la llave ... a EDGAR FERNANDO BARRIOS el 26/11/26 a las 16:07"
 */
object BankParser {

    data class Result(
        val amount: Long,      // siempre positivo
        val income: Boolean,
        val hint: String,      // nombre sugerido, p. ej. "Transferencia de Nilva Luna"
        val bank: String,
        val date: Long,        // fecha del movimiento (o ahora)
        val dateKey: String?,  // fecha/hora tal como viene en el mensaje (para no duplicar)
    )

    private val banks = listOf(
        "bancolombia" to "Bancolombia", "nequi" to "Nequi", "daviplata" to "DaviPlata",
        "davivienda" to "Davivienda", "bbva" to "BBVA", "banco de bogota" to "Banco de Bogotá",
        "bancodebogota" to "Banco de Bogotá", "occidente" to "Banco de Occidente",
        "banco popular" to "Banco Popular", "av villas" to "AV Villas", "scotiabank" to "Scotiabank",
        "colpatria" to "Colpatria", "itau" to "Itaú", "falabella" to "Falabella", "lulo" to "Lulo Bank",
        "nubank" to "Nu", "nu colombia" to "Nu", "caja social" to "Banco Caja Social", "movii" to "Movii",
        "rappipay" to "RappiPay", "bancoomeva" to "Bancoomeva", "banco agrario" to "Banco Agrario",
        "pibank" to "Pibank", "uala" to "Ualá", "dale!" to "Dale",
    )

    // Mensajes que mencionan dinero pero NO son un movimiento real.
    private val ignore = listOf(
        "rechazad", "no fue exitos", "no exitos", "fallid", "declinad", "no se pudo", "la mora",
        "en mora", "vence", "vencimiento", "recuerda", "clave dinamica", "codigo", "otp",
        "no compartas", "programad", "intento", "saldo insuficiente", "cupo disponible",
    )

    private val incomeWords = listOf(
        "recibiste", "te consignaron", "consignaron", "te abonaron", "abono a tu", "te enviaron",
        "te llego", "te transfirieron", "recibio un pago", "devolucion",
    )

    private val expenseWords = listOf(
        "compraste", "compra en", "compra por", "pagaste", "pago en", "pago de", "pago por",
        "transferiste", "enviaste", "retiraste", "retiro", "debitamos", "se debito", "debito de",
        "avance",
    )

    private val amountRe = Regex("""(?:\$|COP)\s*([0-9](?:[0-9.,]*[0-9])?)""", RegexOption.IGNORE_CASE)
    private val dateRe = Regex("""(\d{1,2})/(\d{1,2})/(\d{2,4})(?:\s*a las\s*(\d{1,2}):(\d{2}))?""")
    private const val NAME = """[A-ZÁÉÍÓÚÑ][A-ZÁÉÍÓÚÑ.]*(?: [A-ZÁÉÍÓÚÑ][A-ZÁÉÍÓÚÑ.]*)*"""
    private val fromRe = Regex("""\bde ($NAME)(?= por| el |,|\.|$)""")
    private val toRe = Regex("""\ba ($NAME)(?= el | desde| por|,|\.|$)""")
    private val atRe = Regex("""\ben ([A-Z0-9][A-Z0-9_*.\-]*(?: [A-Z0-9_*.\-]+)*)(?= de tu| con tu| el | desde| por|,|\.)""")

    private val es = Locale("es")

    fun plain(s: String): String =
        Normalizer.normalize(s, Normalizer.Form.NFD).replace(Regex("\\p{M}+"), "").lowercase(Locale.ROOT)

    fun parse(text: String): Result? {
        val p = plain(text)
        val bank = banks.firstOrNull { p.contains(it.first) }?.second ?: return null
        if (ignore.any { p.contains(it) }) return null

        val income = incomeWords.any { p.contains(it) }
        val expense = !income && expenseWords.any { p.contains(it) }
        if (!income && !expense) return null

        val amount = amountRe.find(text)?.groupValues?.get(1)?.let(::toPesos) ?: return null
        if (amount <= 0) return null

        val now = System.currentTimeMillis()
        var date = now
        var dateKey: String? = null
        val m = dateRe.find(text)
        if (m != null) {
            val g = m.groupValues
            val year = g[3].toInt().let { if (it < 100) 2000 + it else it }
            val cal = Calendar.getInstance().apply {
                set(year, g[2].toInt() - 1, g[1].toInt(), g[4].toIntOrNull() ?: 12, g[5].toIntOrNull() ?: 0, 0)
                set(Calendar.MILLISECOND, 0)
            }
            // Mensajes viejos (p. ej. notificaciones agrupadas) no se vuelven a agregar.
            if (now - cal.timeInMillis > 36L * 3600_000) return null
            if (cal.timeInMillis <= now + 3600_000) date = cal.timeInMillis
            dateKey = m.value
        }

        return Result(amount, income, hint(text, p, income, bank), bank, date, dateKey)
    }

    /** Apps de pago con el celular (no dicen el banco ni "compraste"). */
    val walletApps = mapOf(
        "com.google.android.apps.walletnfcrel" to "Billetera de Google",
        "com.samsung.android.spay" to "Samsung Wallet",
        "com.samsung.android.samsungpay.gear" to "Samsung Wallet",
    )

    /**
     * Notificación de la Billetera de Google:
     *   título "DISTRACOM MARRUECOS" · texto "COP 16,130.00 con Debito Mastercard Virtual ••2280"
     */
    fun parseWallet(title: String, body: String, appName: String): Result? {
        val all = "$title\n$body"
        val p = plain(all)
        if (ignore.any { p.contains(it) } || p.contains("declined") || p.contains("no se completo")) return null
        val inTitle = amountRe.find(title)
        val m = amountRe.find(body) ?: inTitle ?: return null
        val amount = toPesos(m.groupValues[1]) ?: return null
        if (amount <= 0) return null
        val income = listOf("reembolso", "devolucion", "refund", "recibiste").any { p.contains(it) }
        // El comercio es la línea que no tiene el valor.
        val merchant = (if (inTitle == null) title else body)
            .replace(amountRe, "").trim().trim(':', '-', '·').trim()
            .takeIf { it.length in 2..60 && !plain(it).startsWith("con ") }
            ?.let(::nice)
        val hint = when {
            income && merchant != null -> "Reembolso de $merchant"
            income -> "Reembolso"
            merchant != null -> "Compra en $merchant"
            else -> "Compra con tarjeta"
        }
        return Result(amount, income, hint, appName, System.currentTimeMillis(), null)
    }

    /** "$1.160.000,00" → 1160000 · "$23,000.00" → 23000 · "$ 26,380" → 26380 */
    fun toPesos(raw: String): Long? {
        val last = maxOf(raw.lastIndexOf('.'), raw.lastIndexOf(','))
        val intPart = if (last >= 0 && raw.length - last - 1 in 1..2) raw.substring(0, last) else raw
        return intPart.filter(Char::isDigit).toLongOrNull()
    }

    private fun nice(s: String) = s.trim().lowercase(es).split(' ').filter { it.isNotEmpty() }
        .joinToString(" ") { w -> w.replaceFirstChar { it.titlecase(es) } }
        .take(32)

    private fun hint(text: String, p: String, income: Boolean, bank: String): String {
        if (income) {
            val who = fromRe.find(text)?.groupValues?.get(1)?.let(::nice)
            val kind = if (p.contains("transfer")) "Transferencia" else "Ingreso"
            return if (who != null) "$kind de $who" else "$kind $bank"
        }
        val to = toRe.find(text)?.groupValues?.get(1)?.let(::nice)
        val at = atRe.find(text)?.groupValues?.get(1)?.let(::nice)
        return when {
            (p.contains("transferiste") || p.contains("enviaste")) && to != null -> "Transferencia a $to"
            p.contains("retir") -> if (at != null) "Retiro en $at" else "Retiro de efectivo"
            p.contains("compr") && at != null -> "Compra en $at"
            p.contains("pag") && at != null -> "Pago en $at"
            to != null -> "Pago a $to"
            else -> "Gasto $bank"
        }
    }
}
