plugins {
    id("com.android.application")
    // Kotlin plugin zaroori hai (aapke file me missing tha)
    id("org.jetbrains.kotlin.android")
    // Flutter Gradle Plugin must be applied after Android & Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.my_app" // <-- apna actual package yahan set karna
    compileSdk = 36                  // <-- REQUIRED for flutter_compress

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.my_app" // <-- apna actual applicationId
        minSdk = 24                          // <-- REQUIRED for flutter_compress
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
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