package com.example.finix

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID

/** Un movimiento detectado que espera nombre y/o ser guardado por la app. */
data class BankItem(
    val id: String,
    val amount: Long,          // negativo = gasto, positivo = ingreso
    val hint: String,
    val bank: String,
    val date: Long,
    val createdAt: Long,
    val title: String? = null, // null = todavía no tiene nombre
    val test: Boolean = false,
) {
    val income get() = amount > 0

    fun toJson(): JSONObject = JSONObject()
        .put("id", id).put("amount", amount).put("hint", hint).put("bank", bank)
        .put("date", date).put("createdAt", createdAt).put("title", title ?: JSONObject.NULL)
        .put("test", test)

    companion object {
        fun from(o: JSONObject) = BankItem(
            id = o.getString("id"), amount = o.getLong("amount"), hint = o.optString("hint"),
            bank = o.optString("bank"), date = o.getLong("date"), createdAt = o.getLong("createdAt"),
            title = if (o.isNull("title")) null else o.optString("title"), test = o.optBoolean("test"),
        )
    }
}

/**
 * Cola local (SharedPreferences). Funciona aunque la app esté cerrada:
 * cuando Finix se abre, toma los movimientos listos y los sube a Supabase.
 */
object BankStore {
    private const val PREFS = "finix_bank"
    private const val ITEMS = "items"
    private const val SEEN = "seen"
    private const val ENABLED = "enabled"

    /** Si nadie le pone nombre en este tiempo, se guarda con el nombre sugerido. */
    private const val AUTO_NAME_MS = 30 * 60_000L

    private fun prefs(c: Context) = c.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun isEnabled(c: Context) = prefs(c).getBoolean(ENABLED, true)
    fun setEnabled(c: Context, v: Boolean) = prefs(c).edit().putBoolean(ENABLED, v).apply()

    @Synchronized
    private fun items(c: Context): MutableList<BankItem> {
        val arr = JSONArray(prefs(c).getString(ITEMS, "[]"))
        return MutableList(arr.length()) { BankItem.from(arr.getJSONObject(it)) }
    }

    @Synchronized
    private fun save(c: Context, list: List<BankItem>) {
        val arr = JSONArray().apply { list.forEach { put(it.toJson()) } }
        prefs(c).edit().putString(ITEMS, arr.toString()).commit()
    }

    /** true si es la primera vez que vemos este movimiento (el SMS y su notificación llegan los dos). */
    @Synchronized
    fun markSeen(c: Context, r: BankParser.Result): Boolean {
        val now = System.currentTimeMillis()
        val seen = JSONObject(prefs(c).getString(SEEN, "{}"))
        seen.keys().asSequence().toList().forEach {
            if (now - seen.getLong(it) > 3 * 86_400_000L) seen.remove(it)
        }
        val sign = if (r.income) "+" else "-"
        val base = "$sign${r.amount}"
        val window = 10 * 60_000L
        fun recent(k: String) = seen.has(k) && now - seen.getLong(k) < window
        // Una misma compra puede llegar por la Billetera de Google (sin fecha) y por el
        // SMS del banco (con fecha): si el valor coincide en pocos minutos, es la misma.
        val dup = if (r.dateKey != null) {
            seen.has("$base@${r.dateKey}") || recent("u$base")
        } else {
            recent("a$base")
        }
        if (dup) return false
        if (r.dateKey != null) seen.put("$base@${r.dateKey}", now) else seen.put("u$base", now)
        seen.put("a$base", now)
        prefs(c).edit().putString(SEEN, seen.toString()).commit()
        return true
    }

    @Synchronized
    fun add(c: Context, r: BankParser.Result, test: Boolean = false): BankItem {
        val item = BankItem(
            id = UUID.randomUUID().toString(),
            amount = if (r.income) r.amount else -r.amount,
            hint = r.hint, bank = r.bank, date = r.date,
            createdAt = System.currentTimeMillis(), test = test,
        )
        save(c, items(c) + item)
        return item
    }

    @Synchronized
    fun nextPending(c: Context): BankItem? = items(c).firstOrNull { it.title == null }

    /** Guarda el nombre elegido. Los de prueba simplemente se descartan. */
    @Synchronized
    fun resolve(c: Context, id: String, title: String) {
        val list = items(c)
        val i = list.indexOfFirst { it.id == id }
        if (i < 0) return
        if (list[i].test) list.removeAt(i)
        else list[i] = list[i].copy(title = title.trim().ifEmpty { list[i].hint })
        save(c, list)
    }

    /** Movimientos listos para subir a la base de datos (JSON para Dart). */
    @Synchronized
    fun ready(c: Context): String {
        val now = System.currentTimeMillis()
        val arr = JSONArray()
        items(c).filter { !it.test }.forEach {
            val title = it.title ?: if (now - it.createdAt > AUTO_NAME_MS) it.hint else null
            if (title != null) arr.put(it.copy(title = title).toJson())
        }
        return arr.toString()
    }

    /** Dart confirma que ya los guardó en Supabase. */
    @Synchronized
    fun ack(c: Context, ids: Collection<String>) = save(c, items(c).filter { it.id !in ids })
}
