package com.github.justbehappii.e_learning_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.ar.core.ArCoreApk

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.csta.elearning/hardware_check"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkArAvailability" -> {
                    try {
                        checkArSupport(result, 0)
                    } catch (e: Exception) {
                        // Fallback if ARCore SDK isn't accessible
                        result.success("UNKNOWN_CHECKING")
                    }
                }
                "requestArInstall" -> {
                    try {
                        val installStatus = ArCoreApk.getInstance().requestInstall(this, true)
                        result.success(installStatus.name)
                    } catch (e: Exception) {
                        result.error("AR_INSTALL_ERROR", e.message, null)
                    }
                }
                "getDeviceInfo" -> {
                    val deviceInfo = mutableMapOf<String, Any>()
                    deviceInfo["model"] = android.os.Build.MODEL
                    deviceInfo["hardware"] = android.os.Build.HARDWARE
                    deviceInfo["sdkInt"] = android.os.Build.VERSION.SDK_INT
                    deviceInfo["manufacturer"] = android.os.Build.MANUFACTURER
                    result.success(deviceInfo)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkArSupport(result: MethodChannel.Result, retryCount: Int) {
        val availability = ArCoreApk.getInstance().checkAvailability(this)
        
        if (availability.isTransient && retryCount < 5) {
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                checkArSupport(result, retryCount + 1)
            }, 200)
            return
        }

        val status = when (availability) {
            ArCoreApk.Availability.SUPPORTED_INSTALLED -> "AR_SUPPORTED"
            ArCoreApk.Availability.SUPPORTED_NOT_INSTALLED -> "AR_SERVICES_NOT_INSTALLED"
            ArCoreApk.Availability.SUPPORTED_APK_TOO_OLD -> "AR_SERVICES_NEEDS_UPDATE"
            ArCoreApk.Availability.UNSUPPORTED_DEVICE_NOT_CAPABLE -> "AR_NOT_SUPPORTED"
            ArCoreApk.Availability.UNKNOWN_CHECKING -> "UNKNOWN_CHECKING"
            else -> "AR_NOT_SUPPORTED"
        }
        
        result.success(status)
    }
}
