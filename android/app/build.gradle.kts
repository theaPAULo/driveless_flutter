plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.driveless_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Changed to Java 17
        targetCompatibility = JavaVersion.VERSION_17  // Changed to Java 17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()  // Changed to Java 17
    }

    defaultConfig {
        applicationId = "com.example.driveless_flutter"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Apply Google Services plugin for Firebase
apply(plugin = "com.google.gms.google-services")