package com.example.infibo_app

import android.os.Handler
import android.os.Looper
import android_serialport_api.Device
import android_serialport_api.SerialPortManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean

class AndroidSerialPortBridge(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val mainHandler = Handler(Looper.getMainLooper())
    private val reading = AtomicBoolean(false)
    private val lock = Any()

    private var manager: SerialPortManager? = null
    private var readThread: Thread? = null
    private var currentPath: String? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "openSerialPort" -> {
                    val path = call.argument<String>("path")
                        ?.takeIf { it.isNotBlank() }
                        ?: DEFAULT_SERIAL_PATH
                    val baudRate = call.argument<Int>("baudRate") ?: DEFAULT_BAUD_RATE

                    openSerialPort(path, baudRate)
                    result.success(true)
                }

                "sendBytes" -> {
                    val bytes = extractBytes(call.argument<Any>("bytes"))
                    sendBytes(bytes)
                    result.success(bytes.size)
                }

                "closeSerialPort" -> {
                    closeSerialPort()
                    result.success(true)
                }

                else -> result.notImplemented()
            }
        } catch (error: Throwable) {
            emitError(error.message ?: error.javaClass.simpleName)
            result.error("SERIAL_PORT_ERROR", error.message, null)
        }
    }

    fun dispose() {
        closeSerialPort()
        channel.setMethodCallHandler(null)
    }

    private fun openSerialPort(path: String, baudRate: Int) {
        synchronized(lock) {
            closeSerialPort()

            val device = Device().apply {
                this.path = path
                speed = baudRate
                dataBits = 8
                stopBits = 1
                parity = 'n'
                block = false
            }

            manager = SerialPortManager(device)
            currentPath = path
            startReadLoop()
        }
    }

    private fun sendBytes(bytes: ByteArray) {
        val serialManager = manager ?: error("Serial port is not open.")
        serialManager.sendPacket(bytes)
    }

    private fun closeSerialPort() {
        synchronized(lock) {
            reading.set(false)
            readThread?.interrupt()
            readThread = null
            manager?.closeSerialPort()
            manager = null
            currentPath = null
        }
    }

    private fun startReadLoop() {
        reading.set(true)
        readThread = Thread {
            val buffer = ByteArray(256)

            while (reading.get()) {
                try {
                    val serialManager = manager ?: break
                    serialManager.readPacket(buffer) { recvBytes, length ->
                        if (length <= 0 || recvBytes == null) return@readPacket

                        val copy = recvBytes.copyOf(length)
                        emitReceive(copy)
                    }
                    Thread.sleep(50)
                } catch (interrupted: InterruptedException) {
                    break
                } catch (error: Throwable) {
                    if (reading.get()) {
                        emitError(error.message ?: error.javaClass.simpleName)
                    }
                    Thread.sleep(100)
                }
            }
        }.apply {
            name = "InfiboSerialReadThread"
            isDaemon = true
            start()
        }
    }

    private fun emitReceive(bytes: ByteArray) {
        val payload = mapOf(
            "path" to currentPath,
            "bytes" to bytes,
            "hex" to bytes.toHexString(),
        )
        mainHandler.post { channel.invokeMethod("onReceive", payload) }
    }

    private fun emitError(message: String) {
        mainHandler.post { channel.invokeMethod("onError", mapOf("message" to message)) }
    }

    private fun extractBytes(value: Any?): ByteArray {
        return when (value) {
            is ByteArray -> value
            is List<*> -> ByteArray(value.size) { index ->
                val item = value[index]
                when (item) {
                    is Number -> item.toInt().toByte()
                    else -> error("Invalid byte at index $index.")
                }
            }

            else -> error("bytes must be Uint8List or List<int>.")
        }
    }

    private fun ByteArray.toHexString(): String {
        return joinToString(" ") { byte ->
            String.format(Locale.US, "%02X", byte.toInt() and 0xFF)
        }
    }

    private companion object {
        const val CHANNEL_NAME = "infibo_app/android_serial_port"
        const val DEFAULT_SERIAL_PATH = "/dev/ttyS0"
        const val DEFAULT_BAUD_RATE = 115200
    }
}
