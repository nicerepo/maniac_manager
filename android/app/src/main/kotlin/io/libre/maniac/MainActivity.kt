package io.libre.maniac

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant

import io.libre.maniac.channels.NativeAppsChannel
import io.libre.maniac.channels.NativeFilesChannel
import io.libre.maniac.channels.NativeShellChannel

class MainActivity() : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        // Custom
        NativeAppsChannel.registerWith(this.registrarFor("io.libre.maniac.channels.NativeAppsChannel"))
        NativeFilesChannel.registerWith(this.registrarFor("io.libre.maniac.channels.NativeFilesChannel"))
        NativeShellChannel.registerWith(this.registrarFor("io.libre.maniac.channels.NativeShellChannel"))
    }
}
