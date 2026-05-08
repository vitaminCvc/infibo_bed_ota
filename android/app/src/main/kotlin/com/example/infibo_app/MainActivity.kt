package com.example.infibo_app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var serialPortBridge: AndroidSerialPortBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        serialPortBridge = AndroidSerialPortBridge(flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        serialPortBridge?.dispose()
        serialPortBridge = null
        super.onDestroy()
    }
}
