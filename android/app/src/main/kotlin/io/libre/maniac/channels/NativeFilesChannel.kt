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

class NativeFilesChannel private constructor(private val registrar: Registrar) : MethodCallHandler, ActivityResultListener {
    private var pendingResult: Result? = null

    @Override
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "pickFile" -> {
                pendingResult = result
                val type = call.argument<String>("mimeType")!!
                val intent = Intent()
                intent.setAction(Intent.ACTION_GET_CONTENT)
                intent.addCategory(Intent.CATEGORY_OPENABLE)
                intent.setType(type)
                registrar.activity().startActivityForResult(intent, READ_REQUEST_CODE)
            }
            else -> result.notImplemented()
        }
    }

    @Override
    override fun onActivityResult(requestCode: Int, resultCode: Int, resultData: Intent?): Boolean {
        if (requestCode !== READ_REQUEST_CODE || resultCode !== Activity.RESULT_OK || resultData === null) {
            return false
        }

        try {
            val uri = resultData.getData()
            val input = registrar.activity().getContentResolver().openInputStream(uri)

            pendingResult?.success(input.readBytes())
        } catch (e: Exception) {
        }

        return true
    }

    companion object {
        private val READ_REQUEST_CODE = 42

        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "maniac.libre.io/native_files")
            val instance = NativeFilesChannel(registrar)
            registrar.addActivityResultListener(instance)
            channel?.setMethodCallHandler(instance)
        }
    }
}
