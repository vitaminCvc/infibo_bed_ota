# ProGuard / R8 rules for Infibo App

# Keep serial port API classes - accessed via JNI from native code
-keep class android_serialport_api.** { *; }

# Google Play Core - not used, suppress warnings
-dontwarn com.google.android.play.core.**

# Keep Flutter plugin channel classes
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep data classes that may be accessed via reflection
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Keep Kotlin serialization
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class kotlinx.serialization.json.** { kotlinx.serialization.KSerializer serializer(...); }
