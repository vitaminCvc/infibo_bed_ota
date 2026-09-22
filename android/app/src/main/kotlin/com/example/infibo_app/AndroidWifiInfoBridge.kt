package com.example.infibo_app

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes the currently connected Wi-Fi SSID to Flutter.
 *
 * Android treats the SSID as location-sensitive information. On Android 6+
 * this bridge requests fine-location permission only when the settings panel
 * actually asks for the name. A denied request returns null; Wi-Fi connectivity
 * is still determined independently in Flutter and therefore remains accurate.
 */
class AndroidWifiInfoBridge(
    messenger: BinaryMessenger,
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val pendingResults = mutableListOf<MethodChannel.Result>()
    private var permissionRequestInFlight = false

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getConnectedWifiName" -> readWifiNameWithPermission(result)
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ): Boolean {
        if (requestCode != LOCATION_PERMISSION_REQUEST_CODE) return false

        permissionRequestInFlight = false
        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        val wifiName = if (granted) readConnectedWifiName() else null
        completePendingResults(wifiName)
        return true
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        // Engine teardown can happen while the permission dialog is visible.
        // Complete pending Flutter calls instead of leaving their Futures open.
        completePendingResults(null)
    }

    private fun readWifiNameWithPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M || hasLocationPermission()) {
            result.success(readConnectedWifiName())
            return
        }

        pendingResults.add(result)
        if (permissionRequestInFlight) return

        permissionRequestInFlight = true
        activity.requestPermissions(
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION),
            LOCATION_PERMISSION_REQUEST_CODE,
        )
    }

    private fun hasLocationPermission(): Boolean {
        return activity.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
    }

    @Suppress("DEPRECATION")
    private fun readConnectedWifiName(): String? {
        return try {
            val wifiManager = activity.applicationContext
                .getSystemService(Context.WIFI_SERVICE) as? WifiManager
            val ssid = wifiManager?.connectionInfo?.ssid?.trim().orEmpty()
            ssid.takeIf { it.isNotEmpty() && it != WifiManager.UNKNOWN_SSID }
        } catch (error: SecurityException) {
            Log.w(TAG, "Missing permission while reading Wi-Fi SSID", error)
            null
        } catch (error: RuntimeException) {
            Log.w(TAG, "Unable to read Wi-Fi SSID", error)
            null
        }
    }

    private fun completePendingResults(value: String?) {
        val results = pendingResults.toList()
        pendingResults.clear()
        results.forEach { it.success(value) }
    }

    private companion object {
        const val CHANNEL_NAME = "infibo_app/android_wifi_info"
        const val TAG = "AndroidWifiInfoBridge"
        const val LOCATION_PERMISSION_REQUEST_CODE = 5_201
    }
}
