import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}


val keystoreProperties = Properties().apply {
    load(File(rootDir, "keystore.properties").inputStream())
}

android {
    namespace = "com.widgetsandco.scribble"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.widgetsandco.scribble"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true 
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

tasks.register("printAndroidConfig") {
    doLast {
        println("compileSdk: ${android.compileSdk}")
        println("minSdk: ${android.defaultConfig.minSdk}")
        println("targetSdk: ${android.defaultConfig.targetSdk}")
        println("versionCode: ${android.defaultConfig.versionCode}")
        println("versionName: ${android.defaultConfig.versionName}")
    }
}