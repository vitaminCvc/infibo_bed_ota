package com.example.infibo_app

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest
import java.util.concurrent.Executors

class AndroidUpdateBridge(private val activity: Activity, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "infibo_app/ota")
    private val worker = Executors.newSingleThreadExecutor()
    private val initiallyAwake = activity.window.attributes.flags and WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON != 0
    init { channel.setMethodCallHandler(this) }

    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
    @Suppress("DEPRECATION")
    private fun installed(): PackageInfo = activity.packageManager.getPackageInfo(activity.packageName, 0)
    private fun cacheDirectory(): File = File(activity.cacheDir, "ota").apply { if (!exists() && !mkdirs()) error("Cannot create update cache") }
    private fun canInstall(): Boolean = Build.VERSION.SDK_INT < 26 || activity.packageManager.canRequestPackageInstalls()
    private fun background(result: MethodChannel.Result, action: () -> Any?) {
        worker.execute {
            try { val value = action(); activity.runOnUiThread { result.success(value) } }
            catch (error: Exception) { activity.runOnUiThread { result.error("OTA_ERROR", error.message, null) } }
        }
    }
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "installedApp" -> background(result) {
                val info = installed()
                mapOf("packageName" to activity.packageName, "version" to (info.versionName ?: ""), "versionCode" to versionCode(info))
            }
            "cacheDirectory" -> background(result) { cacheDirectory().canonicalPath }
            // 先询问系统的真实状态，不把授权状态缓存在 Dart，也不自行修改系统权限。
            "canInstallPackages" -> result.success(canInstall())
            "keepAwake" -> {
                if (call.argument<Boolean>("enabled") == true || initiallyAwake) activity.window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                else activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                result.success(null)
            }
            "openInstallPermission" -> {
                try {
                    if (Build.VERSION.SDK_INT >= 26 && !canInstall()) activity.startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:${activity.packageName}")))
                    result.success(null)
                } catch (error: Exception) { result.error("OTA_PERMISSION_ERROR", error.message, null) }
            }
            "installApk" -> {
                val path = call.argument<String>("path")
                val expectedCode = call.argument<Number>("versionCode")?.toLong()
                val expectedSize = call.argument<Number>("size")?.toLong()
                val expectedHash = call.argument<String>("sha256")
                worker.execute {
                    try {
                        require(path != null && expectedCode != null && expectedSize != null && expectedHash != null)
                        val file = validateApk(path, expectedCode, expectedSize, expectedHash)
                        activity.runOnUiThread {
                            try {
                                if (activity.isFinishing || activity.isDestroyed) error("Update activity is no longer active")
                                if (!canInstall()) result.success("needs_permission")
                                else {
                                    val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.ota_files", file)
                                    activity.startActivity(Intent(Intent.ACTION_VIEW).apply {
                                        setDataAndType(uri, "application/vnd.android.package-archive")
                                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                    })
                                    result.success("requested")
                                }
                            } catch (error: Exception) { result.error("OTA_INSTALL_ERROR", error.message, null) }
                        }
                    } catch (error: Exception) { activity.runOnUiThread { result.error("OTA_INVALID_APK", error.message, null) } }
                }
            }
            else -> result.notImplemented()
        }
    }
    @Suppress("DEPRECATION")
    private fun validateApk(path: String, expectedCode: Long, expectedSize: Long, expectedHash: String): File {
        val file = File(path).canonicalFile
        val root = cacheDirectory().canonicalFile
        require(file.path.startsWith(root.path + File.separator) && file.extension == "apk" && file.isFile) { "APK outside update cache" }
        require(expectedSize in 1..(512L * 1024 * 1024) && file.length() == expectedSize) { "APK size mismatch" }
        require(Regex("[0-9a-fA-F]{64}").matches(expectedHash)) { "Invalid APK hash" }
        val digest = MessageDigest.getInstance("SHA-256")
        file.inputStream().use { input -> val buffer = ByteArray(65536); var count = input.read(buffer); while (count >= 0) { digest.update(buffer, 0, count); count = input.read(buffer) } }
        val hash = digest.digest().joinToString("") { (it.toInt() and 255).toString(16).padStart(2,'0') }
        require(hash.equals(expectedHash, ignoreCase=true)) { "APK hash mismatch" }
        val flags = if (Build.VERSION.SDK_INT >= 28) PackageManager.GET_SIGNING_CERTIFICATES else PackageManager.GET_SIGNATURES
        val archive = activity.packageManager.getPackageArchiveInfo(file.path, flags) ?: error("Invalid APK archive")
        val current = activity.packageManager.getPackageInfo(activity.packageName, flags)
        // 上位机只允许更高编号覆盖安装，文件内容、包名、实际编号和签名照常校验。
        require(expectedCode in 1..Int.MAX_VALUE.toLong() && archive.packageName == activity.packageName && versionCode(archive) == expectedCode && expectedCode > versionCode(current)) { "APK package or version mismatch" }
        val compatible = if (Build.VERSION.SDK_INT >= 28) {
            val old = current.signingInfo?.apkContentsSigners?.toSet().orEmpty()
            val newInfo = archive.signingInfo
            val newer = if (newInfo?.hasMultipleSigners() == true) newInfo.apkContentsSigners?.toSet().orEmpty() else newInfo?.signingCertificateHistory?.toSet().orEmpty()
            old.isNotEmpty() && newer.containsAll(old)
        } else { current.signatures?.toSet() == archive.signatures?.toSet() && !current.signatures.isNullOrEmpty() }
        require(compatible) { "APK signing certificate mismatch" }
        return file
    }
    fun dispose() {
        channel.setMethodCallHandler(null)
        worker.shutdownNow()
        if (!initiallyAwake) activity.window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}
