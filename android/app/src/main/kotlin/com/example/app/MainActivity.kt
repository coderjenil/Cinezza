package djmixer.virtual.remixsong.remixsong

import android.media.AudioManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.app/volume"
    private var audioManager: AudioManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        
        // Register only the regular custom native ad factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "customAdFactory",
            NativeAdFactoryCustom(layoutInflater)
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideSystemUI" -> {
                        try {
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "customAdFactory")
    }
}
