package io.libre.maniac.channels

import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.io.FileOutputStream
import java.io.IOException
import java.io.FileNotFoundException
import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.provider.OpenableColumns

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

import com.jaredrummler.android.shell.Shell

class NativeShellChannel private constructor(private val registrar: Registrar) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "runCommand" -> {
                Shell.SU.run(call.argument("command") as String)
                result.success(null)
            }
            "setExecutable" -> {
                File(call.argument("path") as String).setExecutable(true)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "maniac.libre.io/native_shell")
            val instance = NativeShellChannel(registrar)
            channel?.setMethodCallHandler(instance)
        }
    }
}
