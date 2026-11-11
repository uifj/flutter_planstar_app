import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// 生产签名（P1-03）
// 旧实现 release 复用 debug keystore：任何人都能用公开的 debug key 签同包名
// APK，造成覆盖安装 / 签名级权限被冒用。现在 release 只接受正式 keystore。
//
// 首次配置：
//   keytool -genkey -v -keystore <路径>/planstar-release.jks \
//     -keyalg RSA -keysize 2048 -validity 10000 -alias planstar
//   cp android/key.properties.example android/key.properties   # 填真实值
// key.properties / *.jks 已在 android/.gitignore 中，禁止提交。
// ---------------------------------------------------------------------------
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "com.planstar.app"
    // geolocator_android / geocoding_android / flutter_plugin_android_lifecycle /
    // flutter_secure_storage 等插件要求 compileSdk 36；targetSdk 仍留 35。
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

    signingConfigs {
        // 只有信息齐全才注册 release 签名；缺配置时绝不回退到 debug 签名。
        val storePath = keystoreProperties.getProperty("storeFile")
        if (!storePath.isNullOrBlank() &&
            !keystoreProperties.getProperty("storePassword").isNullOrBlank() &&
            !keystoreProperties.getProperty("keyAlias").isNullOrBlank() &&
            !keystoreProperties.getProperty("keyPassword").isNullOrBlank()
        ) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(storePath)
                storePassword = keystoreProperties.getProperty("storePassword")
                enableV1Signing = true
                enableV2Signing = true
                enableV3Signing = true
            }
        }
    }

    buildTypes {
        debug {
            // 调试运行使用 .debug 后缀，避免与正式包签名冲突。
            applicationIdSuffix = ".debug"
        }
        release {
            // null = 未配置正式签名 → 打 release 包时由下方门禁明确失败。
            signingConfig = signingConfigs.findByName("release")
            // 生产包启用代码压缩/混淆，避免业务逻辑与硬编码配置被直接反编译。
            // 规则见 app/proguard-rules.pro；首次接入后需做一次第三方 SDK 真机回归。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // 只在真正要产出 release 产物时校验，debug / analyze / test 不受影响。
    gradle.taskGraph.whenReady {
        val buildsRelease = gradle.taskGraph.allTasks.any { task ->
            val n = task.name
            n.contains("Release") && (n.startsWith("assemble") || n.startsWith("bundle"))
        }
        if (buildsRelease && signingConfigs.findByName("release") == null) {
            throw GradleException(
                "生产包缺少正式签名：请按 android/key.properties.example 配置 " +
                    "android/key.properties 与 keystore。release 构建禁止回退 debug 签名。"
            )
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
