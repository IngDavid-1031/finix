package com.example.finix

import android.Manifest
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.service.notification.NotificationListenerService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ch = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "finix/bank")
        channel = ch
        BankBridge.onChanged = { ch.invokeMethod("changed", null) }

        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "status" -> result.success(status())
                "setEnabled" -> {
                    BankStore.setEnabled(this, call.arguments as? Boolean ?: true)
                    result.success(null)
                }
                "openNotificationAccess" -> open(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS), result)
                "openOverlay" -> open(
                    Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName")), result,
                )
                "openAppSettings" -> open(
                    Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:$packageName")), result,
                )
                "requestPermissions" -> {
                    val perms = mutableListOf(Manifest.permission.RECEIVE_SMS)
                    if (Build.VERSION.SDK_INT >= 33) perms += Manifest.permission.POST_NOTIFICATIONS
                    requestPermissions(perms.toTypedArray(), 77)
                    result.success(null)
                }
                "takeReady" -> result.success(BankStore.ready(this))
                "ack" -> {
                    @Suppress("UNCHECKED_CAST")
                    BankStore.ack(this, (call.arguments as? List<String>).orEmpty())
                    result.success(null)
                }
                "test" -> {
                    BankBridge.handle(this, BankBridge.SAMPLE, test = true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Si Android detuvo el servicio, lo vuelve a conectar.
        if (notificationAccess()) {
            NotificationListenerService.requestRebind(ComponentName(this, BankNotificationListener::class.java))
        }
        // Banners que quedaron pendientes (p. ej. se dio el permiso después).
        if (Settings.canDrawOverlays(this)) BannerOverlay.showNext(this)
    }

    private fun open(intent: Intent, result: MethodChannel.Result) {
        try {
            startActivity(intent)
        } catch (_: Exception) {
            startActivity(Intent(Settings.ACTION_SETTINGS))
        }
        result.success(null)
    }

    private fun notificationAccess(): Boolean {
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners") ?: return false
        return flat.split(':').any { ComponentName.unflattenFromString(it)?.packageName == packageName }
    }

    private fun status() = mapOf(
        "enabled" to BankStore.isEnabled(this),
        "notifications" to notificationAccess(),
        "sms" to (checkSelfPermission(Manifest.permission.RECEIVE_SMS) == PackageManager.PERMISSION_GRANTED),
        "overlay" to Settings.canDrawOverlays(this),
    )

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        channel?.invokeMethod("changed", null)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        BankBridge.onChanged = null
        channel = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
