package run.records.openbike

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // BlePermissionHandler picks the Bluetooth permissions to request
        // from the API level.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "run.records.openbike/platform")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "androidSdkInt" -> result.success(Build.VERSION.SDK_INT)
                    else -> result.notImplemented()
                }
            }
    }
}
