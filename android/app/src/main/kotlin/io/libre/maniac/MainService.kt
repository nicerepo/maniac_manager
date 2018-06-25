package io.libre.maniac

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build

import com.jaredrummler.android.shell.Shell

import java.io.File

class MainService : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", 0)
            if (!prefs.getBoolean("isUnattendedModeEnabled", false)) {
                return;
            }

            for (abi in Build.SUPPORTED_ABIS) {
                val path = context.getApplicationInfo().dataDir + "/private/utils/" + abi + "/maniacd"
                File(path).setExecutable(true)
                Shell.SU.run(path + " &")
            }
        }
    }
}