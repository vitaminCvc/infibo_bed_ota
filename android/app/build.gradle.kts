plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.infibo_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    flavorDimensions += "market"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.infibo_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        create("global") {
            dimension = "market"
            applicationId = "com.infibo.app.global"
            resValue("string", "app_name", "Infibo")
        }
        create("india") {
            dimension = "market"
            applicationId = "com.infibo.app.india"
            resValue("string", "app_name", "Infibo India")
        }
        create("spain") {
            dimension = "market"
            applicationId = "com.infibo.app.spain"
            resValue("string", "app_name", "Infibo Spain")
        }
        create("turkey") {
            dimension = "market"
            applicationId = "com.infibo.app.turkey"
            resValue("string", "app_name", "Infibo Turkey")
        }
        create("america") {
            dimension = "market"
            applicationId = "com.infibo.app.america"
            resValue("string", "app_name", "Infibo America")
        }
        create("britain") {
            dimension = "market"
            applicationId = "com.infibo.app.britain"
            resValue("string", "app_name", "Infibo Britain")
        }
        create("australia") {
            dimension = "market"
            applicationId = "com.infibo.app.australia"
            resValue("string", "app_name", "Infibo Australia")
        }
        create("uaeBiohackn") {
            dimension = "market"
            applicationId = "com.infibo.app.uae.biohackn"
            resValue("string", "app_name", "Biohackn")
        }
    }   

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(files("libs/mcSerialPort.aar"))
}
