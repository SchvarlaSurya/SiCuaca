import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Plugin Google Services hanya dipasang bila google-services.json sudah ada,
// supaya aplikasi tetap bisa di-build sebelum proyek Firebase dibuat
// (notifikasi gempa nonaktif sampai berkas itu ditaruh di android/app/).
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

// Penandatanganan rilis: android/key.properties (TIDAK masuk git, dibuat oleh
// tool/buat_keystore.ps1; lihat docs/RILIS_ANDROID.md). Berisi storeFile,
// storePassword, keyAlias, keyPassword.
val keyProps = Properties().apply {
    val berkas = rootProject.file("key.properties")
    if (berkas.exists()) berkas.inputStream().use { load(it) }
}

// Build rilis TANPA key.properties harus gagal dengan pesan jelas, bukan
// diam-diam memakai kunci debug.
if (keyProps.isEmpty && gradle.startParameter.taskNames.any { it.contains("Release", ignoreCase = true) }) {
    throw GradleException(
        "android/key.properties belum ada, jadi APK rilis tidak bisa ditandatangani. " +
            "Jalankan: powershell -ExecutionPolicy Bypass -File tool/buat_keystore.ps1 " +
            "(lihat docs/RILIS_ANDROID.md).",
    )
}

android {
    namespace = "com.example.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Dibutuhkan flutter_local_notifications.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // Package name yang didaftarkan di Firebase. Harus sama persis dengan
        // "package_name" di google-services.json.
        applicationId = "com.sicuaca.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (!keyProps.isEmpty) {
                keyAlias = keyProps.getProperty("keyAlias")
                keyPassword = keyProps.getProperty("keyPassword")
                storeFile = file(keyProps.getProperty("storeFile"))
                storePassword = keyProps.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Perkecil dan acak kode (R8) serta buang sumber daya tak terpakai.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Pembaruan widget di latar belakang (PembaruWidgetWorker); versi sama
    // dengan yang dipakai paket home_widget.
    implementation("androidx.work:work-runtime-ktx:2.11.2")

    // Uji unit logika murni widget di JVM (android/app/src/test).
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.json:json:20240303")
}
