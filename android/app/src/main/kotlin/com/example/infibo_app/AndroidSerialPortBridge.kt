package com.example.infibo_app

import android.os.Handler
import android.os.Looper
import android_serialport_api.Device
import android_serialport_api.SerialPortManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
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

                "transceiveBytes" -> {
                    val path = call.argument<String>("path")
                        ?.takeIf { it.isNotBlank() }
                        ?: DEFAULT_SERIAL_PATH
                    val baudRate = call.argument<Int>("baudRate") ?: DEFAULT_BAUD_RATE
                    val timeoutMs = call.argument<Int>("timeoutMs") ?: DEFAULT_TIMEOUT_MS
                    val bytes = extractBytes(call.argument<Any>("bytes"))

                    val response = transceiveBytes(path, baudRate, bytes, timeoutMs)
                    result.success(response)
                }

                "writeBytesOnce" -> {
                    val path = call.argument<String>("path")
                        ?.takeIf { it.isNotBlank() }
                        ?: DEFAULT_SERIAL_PATH
                    val baudRate = call.argument<Int>("baudRate") ?: DEFAULT_BAUD_RATE
                    val bytes = extractBytes(call.argument<Any>("bytes"))

                    writeBytesOnce(path, baudRate, bytes)
                    result.success(bytes.size)
                }

                "writeModbusQueue" -> {
                    val path = call.argument<String>("path")
                        ?.takeIf { it.isNotBlank() }
                        ?: DEFAULT_SERIAL_PATH
                    val baudRate = call.argument<Int>("baudRate") ?: DEFAULT_BAUD_RATE
                    val timeoutMs = call.argument<Int>("timeoutMs") ?: DEFAULT_TIMEOUT_MS
                    val delayMs = call.argument<Int>("delayMs") ?: DEFAULT_DELAY_MS
                    val maxRetries = call.argument<Int>("maxRetries") ?: DEFAULT_MAX_RETRIES
                    val frames = extractFrames(call.argument<Any>("frames"))

                    val responses = writeModbusQueue(
                        path,
                        baudRate,
                        frames,
                        timeoutMs,
                        delayMs,
                        maxRetries,
                    )
                    result.success(responses)
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

    private fun openSerialPort(path: String, baudRate: Int, startReader: Boolean = true) {
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
            if (startReader) {
                startReadLoop()
            }
        }
    }

    private fun sendBytes(bytes: ByteArray) {
        val serialManager = manager ?: error("Serial port is not open.")
        serialManager.sendPacket(bytes)
    }

    private fun closeSerialPort() {
        synchronized(lock) {
            android.util.Log.i("SerialPortManager", "closeSerialPort requested")
            reading.set(false)
            readThread?.interrupt()
            readThread = null
            manager?.closeSerialPort()
            manager = null
            currentPath = null
            android.util.Log.i("SerialPortManager", "closeSerialPort finished")
        }
    }

    private fun transceiveBytes(
        path: String,
        baudRate: Int,
        bytes: ByteArray,
        timeoutMs: Int,
    ): ByteArray {
        synchronized(lock) {
            try {
                openSerialPort(path, baudRate, startReader = false)
                val serialManager = manager ?: error("Serial port is not open.")

                drainInput(serialManager)
                serialManager.sendPacket(bytes)

                val response = readModbusResponse(serialManager, timeoutMs)
                android.util.Log.i("SerialPortManager", "transceive RX: ${response.toHexString()}")
                return response
            } finally {
                closeSerialPort()
            }
        }
    }

    private fun writeBytesOnce(path: String, baudRate: Int, bytes: ByteArray) {
        synchronized(lock) {
            try {
                openSerialPort(path, baudRate, startReader = false)
                val serialManager = manager ?: error("Serial port is not open.")
                serialManager.sendPacket(bytes)
            } finally {
                closeSerialPort()
            }
        }
    }

    private fun writeModbusQueue(
        path: String,
        baudRate: Int,
        frames: List<ByteArray>,
        timeoutMs: Int,
        delayMs: Int,
        maxRetries: Int,
    ): List<ByteArray> {
        synchronized(lock) {
            try {
                android.util.Log.i(
                    "SerialPortManager",
                    "queue open path=$path baudRate=$baudRate count=${frames.size}",
                )
                openSerialPort(path, baudRate, startReader = false)
                val serialManager = manager ?: error("Serial port is not open.")
                val responses = mutableListOf<ByteArray>()
                val queueStartMs = System.currentTimeMillis()

                frames.forEachIndexed { index, frame ->
                    responses.add(
                        writeModbusFrameWithRetry(
                            serialManager = serialManager,
                            frame = frame,
                            index = index,
                            timeoutMs = timeoutMs,
                            delayMs = delayMs,
                            maxRetries = maxRetries,
                        ),
                    )
                }
                val totalMs = System.currentTimeMillis() - queueStartMs
                android.util.Log.i("SerialPortManager", "queue complete total=${totalMs}ms")
                android.util.Log.i("SerialPortManager", "queue complete, close after success")
                return responses
            } finally {
                android.util.Log.i("SerialPortManager", "queue finally closeSerialPort")
                closeSerialPort()
            }
        }
    }

    private fun writeModbusFrameWithRetry(
        serialManager: SerialPortManager,
        frame: ByteArray,
        index: Int,
        timeoutMs: Int,
        delayMs: Int,
        maxRetries: Int,
    ): ByteArray {
        val addressText = modbusAddressText(frame)
        val value = modbusValue(frame)
        var lastError: Throwable? = null

        for (attempt in 0..maxRetries.coerceAtLeast(0)) {
            val startMs = System.currentTimeMillis()
            try {
                drainInput(serialManager)
                android.util.Log.i(
                    "SerialPortManager",
                    "queue TX[${index + 1}] attempt ${attempt + 1}: ${frame.toHexString()}",
                )
                serialManager.sendPacket(frame)

                val response = readModbusResponse(serialManager, timeoutMs)
                android.util.Log.i(
                    "SerialPortManager",
                    "queue RX[${index + 1}]: ${response.toHexString()}",
                )
                validateWriteSingleRegisterResponse(frame, response)
                android.util.Log.i(
                    "SerialPortManager",
                    "Native response validate success: $addressText",
                )
                val costMs = System.currentTimeMillis() - startMs
                android.util.Log.i(
                    "SerialPortManager",
                    "TX[${index + 1}] address=$addressText value=$value cost=${costMs}ms success",
                )

                if (delayMs > 0) Thread.sleep(delayMs.toLong())
                return response
            } catch (error: Throwable) {
                val costMs = System.currentTimeMillis() - startMs
                android.util.Log.e(
                    "SerialPortManager",
                    "TX[${index + 1}] address=$addressText value=$value cost=${costMs}ms failed attempt=${attempt + 1}: ${error.message}",
                )
                lastError = error
                if (attempt < maxRetries) {
                    Thread.sleep(delayMs.coerceAtLeast(30).toLong())
                }
            }
        }

        val reason = if (lastError?.message?.contains("timeout", ignoreCase = true) == true) {
            "写入超时"
        } else {
            lastError?.message ?: "写入失败"
        }
        error("参数下发失败：寄存器 $addressText $reason")
    }

    private fun drainInput(serialManager: SerialPortManager) {
        val input = serialManager.mInputStream ?: return
        val buffer = ByteArray(256)

        repeat(8) {
            val available = input.available()
            if (available <= 0) return
            val length = input.read(buffer, 0, minOf(buffer.size, available))
            if (length <= 0) return
        }
    }

    private fun readModbusResponse(
        serialManager: SerialPortManager,
        timeoutMs: Int,
    ): ByteArray {
        val input = serialManager.mInputStream ?: error("Serial input stream is not open.")
        val output = ByteArrayOutputStream()
        val buffer = ByteArray(256)
        val deadline = System.currentTimeMillis() + timeoutMs.coerceAtLeast(100)
        android.util.Log.i("SerialPortManager", "Native wait RX timeoutMs=$timeoutMs")

        while (System.currentTimeMillis() < deadline) {
            val available = input.available()
            val length = if (available > 0) {
                input.read(buffer, 0, minOf(buffer.size, available))
            } else {
                input.read(buffer)
            }

            if (length > 0) {
                output.write(buffer, 0, length)
                val bytes = output.toByteArray()
                android.util.Log.i("SerialPortManager", "Native RX: ${bytes.toHexString()}")
                val expectedLength = expectedModbusResponseLength(bytes)
                if (expectedLength != null && bytes.size >= expectedLength) {
                    val response = bytes.copyOf(expectedLength)
                    android.util.Log.i(
                        "SerialPortManager",
                        "Native RX complete: ${response.toHexString()}",
                    )
                    return response
                }
            } else {
                Thread.sleep(5)
            }
        }

        android.util.Log.e("SerialPortManager", "Native RX timeout after ${timeoutMs}ms")
        error("Serial read timeout after ${timeoutMs}ms.")
    }

    private fun expectedModbusResponseLength(bytes: ByteArray): Int? {
        if (bytes.size < 2) return null
        val function = bytes[1].toInt() and 0xFF
        if ((function and 0x80) != 0) return 5

        return when (function) {
            0x03 -> if (bytes.size < 3) null else (bytes[2].toInt() and 0xFF) + 5
            0x06 -> 8
            else -> 8
        }
    }

    private fun validateWriteSingleRegisterResponse(request: ByteArray, response: ByteArray) {
        if (request.size < 8) error("Invalid request frame length: ${request.size}.")
        if (response.size >= 2 && (response[1].toInt() and 0xFF) == 0x86) {
            if (response.size != 5) error("exception response length error: ${response.size}.")
            validateCrc(response, 3)
            error("异常响应 code=${response[2].toInt() and 0xFF}")
        }

        if (response.size != 8) error("response length error: ${response.size}.")
        validateCrc(response, 6)

        for (index in 0..5) {
            if (response[index] != request[index]) {
                error(
                    "echo mismatch: request=${request.toHexString()}, response=${response.toHexString()}",
                )
            }
        }
    }

    private fun validateCrc(frame: ByteArray, dataLength: Int) {
        if (frame.size < dataLength + 2) error("CRC frame length error: ${frame.size}.")
        val actual = (frame[dataLength].toInt() and 0xFF) or
            ((frame[dataLength + 1].toInt() and 0xFF) shl 8)
        val expected = crc16(frame, dataLength)
        if (actual != expected) {
            error(
                "CRC mismatch: response=0x${actual.toString(16)}, expected=0x${expected.toString(16)}",
            )
        }
    }

    private fun crc16(bytes: ByteArray, length: Int): Int {
        var crc = 0xFFFF
        for (index in 0 until length) {
            crc = crc xor (bytes[index].toInt() and 0xFF)
            repeat(8) {
                val lsbSet = (crc and 0x0001) != 0
                crc = crc ushr 1
                if (lsbSet) crc = crc xor 0xA001
            }
        }
        return crc and 0xFFFF
    }

    private fun modbusAddressText(frame: ByteArray): String {
        if (frame.size < 4) return "<unknown>"
        val address = ((frame[2].toInt() and 0xFF) shl 8) or (frame[3].toInt() and 0xFF)
        return "0x${address.toString(16).uppercase(Locale.US).padStart(4, '0')}"
    }

    private fun modbusValue(frame: ByteArray): Int {
        if (frame.size < 6) return 0
        return ((frame[4].toInt() and 0xFF) shl 8) or (frame[5].toInt() and 0xFF)
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

    private fun extractFrames(value: Any?): List<ByteArray> {
        val items = value as? List<*> ?: error("frames must be List<Uint8List>.")
        return items.map { extractBytes(it) }
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
        const val DEFAULT_TIMEOUT_MS = 1000
        const val DEFAULT_DELAY_MS = 40
        const val DEFAULT_MAX_RETRIES = 2
    }
}
