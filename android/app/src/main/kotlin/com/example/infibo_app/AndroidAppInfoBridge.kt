package com.example.infibo_app

import android.content.Context
import android.os.Build
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * 给设置页提供已安装 APK 的真实版本。
 * PackageManager 使用当前 applicationId，因此 global/india/spain 等渠道均能正确读取。
 * 不能用源码常量代替：Flutter 构建参数可以覆盖 pubspec 中的版本。
 */
class AndroidAppInfoBridge(context: Context, messenger: BinaryMessenger) {
    private val channel = MethodChannel(messenger, "infibo_app/app_info")

    init {
        channel.setMethodCallHandler { call, result ->
            if (call.method != "getVersion") {
                result.notImplemented()
            } else {
                try {
                    @Suppress("DEPRECATION")
                    val info = context.packageManager.getPackageInfo(context.packageName, 0)
                    @Suppress("DEPRECATION")
                    val code = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
                    result.success(mapOf("versionName" to info.versionName, "versionCode" to code))
                } catch (error: Exception) {
                    result.error("APP_INFO_UNAVAILABLE", error.message, null)
                }
            }
        }
    }

    // Activity 结束时解除回调，避免旧 Activity 被持有。
    fun dispose() { channel.setMethodCallHandler(null) }
}
