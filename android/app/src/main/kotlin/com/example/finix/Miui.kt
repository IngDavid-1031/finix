package com.example.finix

import android.app.AppOpsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Process

/**
 * Xiaomi / Redmi / POCO (MIUI y HyperOS) tienen permisos propios que Android no muestra:
 * "Mostrar ventanas emergentes mientras se ejecuta en segundo plano" bloquea el banner
 * cuando Finix está cerrada.
 */
object Miui {
    private const val OP_BACKGROUND_START_ACTIVITY = 10021

    val isXiaomi: Boolean
        get() = Build.MANUFACTURER.lowercase() in setOf("xiaomi", "redmi", "poco") ||
            Build.BRAND.lowercase() in setOf("xiaomi", "redmi", "poco")

    /** true/false si se pudo leer el permiso; null si no es Xiaomi o no se sabe. */
    fun popupsAllowed(c: Context): Boolean? {
        if (!isXiaomi) return null
        return try {
            val ops = c.getSystemService(AppOpsManager::class.java) ?: return null
            val m = AppOpsManager::class.java.getMethod(
                "checkOpNoThrow", Int::class.javaPrimitiveType, Int::class.javaPrimitiveType, String::class.java,
            )
            (m.invoke(ops, OP_BACKGROUND_START_ACTIVITY, Process.myUid(), c.packageName) as Int) ==
                AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) {
            null
        }
    }

    /** Abre la pantalla "Otros permisos" de Finix en el Centro de seguridad. */
    fun permissionsIntents(pkg: String): List<Intent> = listOf(
        Intent("miui.intent.action.APP_PERM_EDITOR").setClassName(
            "com.miui.securitycenter", "com.miui.permcenter.permissions.PermissionsEditorActivity",
        ).putExtra("extra_pkgname", pkg),
        Intent("miui.intent.action.APP_PERM_EDITOR").setClassName(
            "com.miui.securitycenter", "com.miui.permcenter.permissions.AppPermissionsEditorActivity",
        ).putExtra("extra_pkgname", pkg),
        Intent("miui.intent.action.APP_PERM_EDITOR").putExtra("extra_pkgname", pkg),
    )
}
