package dev.beamlak.flixquest_v2

import android.app.UiModeManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import dev.beamlak.flixquest_v2.downloads.StreamDownloadsBridge
import dev.beamlak.flixquest_v2.downloads.StreamOfflinePlayerFactory

class MainActivity: FlutterActivity() {
    private var downloadsBridge: StreamDownloadsBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val bridge = StreamDownloadsBridge(
            this,
            flutterEngine.dartExecutor.binaryMessenger,
        )
        downloadsBridge = bridge
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "dev.beamlak.flixquest/offline_player",
                StreamOfflinePlayerFactory(bridge.store),
            )

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DEVICE_PRESENTATION_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTelevision" -> result.success(isTelevision())
                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (downloadsBridge?.onActivityResult(requestCode, resultCode, data) == true) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun isTelevision(): Boolean {
        val uiModeManager = getSystemService(Context.UI_MODE_SERVICE) as? UiModeManager
        return uiModeManager?.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION ||
            (uiModeManager == null &&
                packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK))
    }

    private companion object {
        const val DEVICE_PRESENTATION_CHANNEL =
            "dev.beamlak.flixquest/device_presentation"
    }
}
