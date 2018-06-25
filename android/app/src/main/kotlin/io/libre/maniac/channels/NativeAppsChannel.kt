package io.libre.maniac.channels

import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.FileNotFoundException
import android.app.Activity
import android.content.pm.PackageInfo
import android.content.pm.ApplicationInfo
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.database.Cursor
import android.provider.OpenableColumns

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

class NativeAppsChannel private constructor(private val registrar: Registrar) : MethodCallHandler {
    private var pendingResult: Result? = null

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "run" -> {
                runApp(call.argument("applicationId") as String)
                result.success(null)
            }
            "getIcon" -> result.success(getAppIcon(call.argument("applicationId") as String))
            "getAllInstalled" -> result.success(getAllInstalledApps())
            else -> result.notImplemented()
        }
    }

    private fun runApp(applicationId: String) {
        var intent = registrar.activity().getPackageManager().getLaunchIntentForPackage(applicationId)

        if (intent == null)
            intent = registrar.activity().getPackageManager().getLeanbackLaunchIntentForPackage(applicationId)

        if (intent != null)
            registrar.activity().startActivity(intent)
    }

    private fun getAllInstalledApps(): List<Object> {
        val packages = registrar.activity().getPackageManager().getInstalledPackages(0)
        val json = ArrayList<Object>(packages.size)

        for (info in packages) {
            val map = HashMap<String, Any>()
            map.put("applicationName", info.applicationInfo.loadLabel(registrar.activity().getPackageManager()).toString())
            map.put("applicationId", info.packageName)
            map.put("versionName", info.versionName)
            map.put("versionCode", info.versionCode)
            map.put("isSystem", info.applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM !== 0)
            json.add(map as Object)
        }

        return json
    }

    fun drawableToBitmap(drawable: Drawable): Bitmap? {
        var bitmap: Bitmap? = null

        if (drawable is BitmapDrawable) {
            val bitmapDrawable = drawable as BitmapDrawable
            if (bitmapDrawable.getBitmap() != null) {
                return bitmapDrawable.getBitmap()
            }
        }

        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_8888)
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight(), Bitmap.Config.ARGB_8888)
        }

        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight())
        drawable.draw(canvas)

        return bitmap
    }

    private fun getAppIcon(applicationId: String): ByteArray? {
        try {
            val drawable = registrar.activity().getPackageManager().getApplicationIcon(applicationId);
            val bitmap = drawableToBitmap(drawable)
            val stream = java.io.ByteArrayOutputStream()

            bitmap?.compress(Bitmap.CompressFormat.PNG, 100, stream)

            return stream.toByteArray()
        } catch (e: Exception) {
            return null
        }

    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "maniac.libre.io/native_apps")
            val instance = NativeAppsChannel(registrar)
            channel?.setMethodCallHandler(instance)
        }
    }
}
