package io.libre.maniac

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;

import com.jaredrummler.android.shell.Shell

import java.io.File

class CLIReceiver : BroadcastReceiver() {

    // adb shell "am broadcast -n io.libre.maniac/.CLIReceiver --es command install --es path /tmp/test.zip"
    override fun onReceive(context: Context, intent: Intent) {
        if (intent == null) {
            return;
        }

        val command = intent.getStringExtra("command");

        when (command) {
            "install" -> {
                // TODO
            }
            else -> return
        }
    }

}