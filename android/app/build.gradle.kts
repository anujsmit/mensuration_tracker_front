plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    implementation("com.google.firebase:firebase-analytics")

    // ✅ Use required desugaring version (>= 2.1.4)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}

android {
    namespace = "com.anujkattel.mensurationtracker"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Enable core library desugaring
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.anujkattel.mensurationtracker"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        // Enable multidex support
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // TODO: Replace with your signing config for release builds
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
