package djmixer.virtual.remixsong.remixsong // Change this to your package name

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.media.AudioManager
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.app/volume"
    private var audioManager: AudioManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hideSystemUI" -> {
                    // This prevents system volume UI from showing
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
