package com.example.nfccards

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Pass the NFC intent to Flutter when the app is created
        handleNfcIntent(intent)
    }

    override fun onResume() {
        super.onResume()
        // Setup foreground dispatch to prevent Android from handling NFC events
        val intent = Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)
        NfcAdapter.getDefaultAdapter(this)?.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        // Disable foreground dispatch when the app is paused
        NfcAdapter.getDefaultAdapter(this)?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle the NFC intent when the activity is resumed with a new intent
        handleNfcIntent(intent)
    }

    private fun handleNfcIntent(intent: Intent) {
        // This method passes the NFC intent to Flutter
        if (intent.action?.startsWith("android.nfc.action") == true) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                // Pass the NFC event to Flutter (could add more data if needed)
                MethodChannel(messenger, "nfc_channel").invokeMethod("onNfcDiscovered", null)
            }
        }
    }
}