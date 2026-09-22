package com.example.infibo_app

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Exposes connected classic Bluetooth audio devices to Flutter.
 *
 * UniversalBle reports Android GATT connections only, so A2DP and HEADSET/HFP
 * are queried here through Android's Bluetooth profile proxies.
 */
class AndroidBluetoothProfileBridge(
    messenger: BinaryMessenger,
    context: Context,
) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val appContext = context.applicationContext
    private val mainHandler = Handler(Looper.getMainLooper())
    private val activeQueries = mutableSetOf<ConnectedProfilesQuery>()

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getConnectedClassicBluetoothDeviceNames" -> readConnectedDeviceNames(result)
            else -> result.notImplemented()
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
        activeQueries.toList().forEach(ConnectedProfilesQuery::cancel)
        activeQueries.clear()
    }

    private fun readConnectedDeviceNames(result: MethodChannel.Result) {
        val adapter = try {
            val manager = appContext.getSystemService(Context.BLUETOOTH_SERVICE)
                as? BluetoothManager
            manager?.adapter
        } catch (error: SecurityException) {
            null
        }

        if (adapter == null || !isBluetoothEnabled(adapter)) {
            result.success(emptyList<String>())
            return
        }

        lateinit var query: ConnectedProfilesQuery
        query = ConnectedProfilesQuery(
            context = appContext,
            adapter = adapter,
            mainHandler = mainHandler,
        ) { names ->
            activeQueries.remove(query)
            result.success(names)
        }
        activeQueries.add(query)
        query.start()
    }

    private fun isBluetoothEnabled(adapter: BluetoothAdapter): Boolean {
        return try {
            adapter.isEnabled
        } catch (error: SecurityException) {
            Log.w(TAG, "Missing permission while reading Bluetooth state", error)
            false
        }
    }

    private class ConnectedProfilesQuery(
        private val context: Context,
        private val adapter: BluetoothAdapter,
        private val mainHandler: Handler,
        private val onComplete: (List<String>) -> Unit,
    ) : BluetoothProfile.ServiceListener {
        private val pendingProfiles = PROFILE_IDS.toMutableSet()
        private val deviceNames = linkedSetOf<String>()
        private var finished = false

        private val timeout = Runnable {
            Log.w(TAG, "Timed out while reading classic Bluetooth profiles")
            finish()
        }

        fun start() {
            mainHandler.postDelayed(timeout, PROFILE_QUERY_TIMEOUT_MS)
            PROFILE_IDS.forEach { profileId ->
                val requested = try {
                    adapter.getProfileProxy(context, this, profileId)
                } catch (error: SecurityException) {
                    Log.w(TAG, "Missing permission for Bluetooth profile $profileId", error)
                    false
                }
                if (!requested) completeProfile(profileId)
            }
        }

        fun cancel() {
            if (finished) return
            finished = true
            mainHandler.removeCallbacks(timeout)
        }

        override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
            try {
                if (!finished) {
                    proxy.connectedDevices.forEach { device ->
                        val name = try {
                            // Android 11 及以上优先读取用户在系统设置中修改的设备别名。
                            val alias = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                                device.alias?.trim()
                            } else {
                                null
                            }

                            alias?.takeIf { it.isNotEmpty() }
                                ?: device.name?.trim().orEmpty()
                        } catch (error: SecurityException) {
                            Log.w(
                                TAG,
                                "Missing permission while reading Bluetooth device name",
                                error,
                            )
                            ""
                        }
                        if (name.isNotEmpty()) deviceNames.add(name)
                    }
                }
            } catch (error: SecurityException) {
                Log.w(TAG, "Missing permission while reading profile $profile", error)
            } finally {
                // Profile proxies are temporary system-service handles and must be closed.
                adapter.closeProfileProxy(profile, proxy)
                completeProfile(profile)
            }
        }

        override fun onServiceDisconnected(profile: Int) {
            completeProfile(profile)
        }

        private fun completeProfile(profile: Int) {
            if (finished) return
            pendingProfiles.remove(profile)
            if (pendingProfiles.isEmpty()) finish()
        }

        private fun finish() {
            if (finished) return
            finished = true
            mainHandler.removeCallbacks(timeout)
            onComplete(deviceNames.toList())
        }
    }

    private companion object {
        const val CHANNEL_NAME = "infibo_app/android_bluetooth_profiles"
        const val TAG = "BluetoothProfileBridge"
        const val PROFILE_QUERY_TIMEOUT_MS = 2_000L
        val PROFILE_IDS = setOf(BluetoothProfile.A2DP, BluetoothProfile.HEADSET)
    }
}
