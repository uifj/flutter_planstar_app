plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.planstar.app"
    // geolocator_android / geocoding_android / flutter_plugin_android_lifecycle /
    // flutter_secure_storage 等插件要求 compileSdk 36（targetSdk 仍留 35，与原项目一致）。
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // 应用标识 com.planstar.app；versionCode/versionName 取自 pubspec。
        applicationId = "com.planstar.app"
        minSdk = 24
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // jpush_flutter 插件自身清单引用 ${JPUSH_APPKEY}/${JPUSH_PKGNAME}/${JPUSH_CHANNEL}
        // 占位符；不在此提供会导致清单合并失败。JPUSH_PKGNAME 用基础 applicationId
        // （release = com.planstar.app）。
        manifestPlaceholders["JPUSH_PKGNAME"] = "com.planstar.app"
        manifestPlaceholders["JPUSH_APPKEY"] = "baeccd5e33d6af24b55804f7"
        manifestPlaceholders["JPUSH_CHANNEL"] = "developer-default"
    }

    buildTypes {
        debug {
            // 调试运行使用 .debug 后缀，避免与正式包签名冲突。
            applicationIdSuffix = ".debug"
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// 旧 com.android.support（如百度地图老 SDK 带入的 support-compat:26.1.0）与
// androidx.core 共存会在 checkDebugDuplicateClasses 报 Duplicate class；
// 统一排除旧 support 库组，强制走 androidx。
configurations.all {
    exclude(group = "com.android.support")
}

flutter {
    source = "../.."
}
