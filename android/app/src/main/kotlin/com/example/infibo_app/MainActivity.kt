package com.example.infibo_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var updateBridge: AndroidUpdateBridge? = null
    private var serialPortBridge: AndroidSerialPortBridge? = null
    private var bluetoothProfileBridge: AndroidBluetoothProfileBridge? = null
    private var wifiInfoBridge: AndroidWifiInfoBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        updateBridge = AndroidUpdateBridge(this, flutterEngine.dartExecutor.binaryMessenger)
        serialPortBridge = AndroidSerialPortBridge(flutterEngine.dartExecutor.binaryMessenger)
        bluetoothProfileBridge = AndroidBluetoothProfileBridge(
            flutterEngine.dartExecutor.binaryMessenger,
            this,
        )
        wifiInfoBridge = AndroidWifiInfoBridge(
            flutterEngine.dartExecutor.binaryMessenger,
            this,
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        wifiInfoBridge?.onRequestPermissionsResult(requestCode, grantResults)
    }

    override fun onDestroy() {
        updateBridge?.dispose()
        updateBridge = null
        wifiInfoBridge?.dispose()
        wifiInfoBridge = null
        bluetoothProfileBridge?.dispose()
        bluetoothProfileBridge = null
        serialPortBridge?.dispose()
        serialPortBridge = null
        super.onDestroy()
    }
}
