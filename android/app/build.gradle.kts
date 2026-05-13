import java.util.Properties
import org.gradle.api.GradleException
import kotlin.io.path.readText

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Apply the cross-platform UI engine plugin after Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    // UTF-8 + strip BOM so Windows editors don’t break the first key.
    val text = keystorePropertiesFile.toPath().readText().trimStart('\uFEFF')
    keystoreProperties.load(text.reader())
}

android {
    namespace = "app.inktime"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.inktime"
        // You can update the following values to match your application needs.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                    ?: error("key.properties must define keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                    ?: error("key.properties must define keyPassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                    ?: error("key.properties must define storeFile")
                storeFile = rootProject.file(storeFilePath)
                require(storeFile!!.exists()) {
                    "Keystore not found: ${storeFile!!.absolutePath} (storeFile in key.properties is relative to android/)"
                }
                storePassword = keystoreProperties.getProperty("storePassword")
                    ?: error("key.properties must define storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
        }
    }
}

// Do not produce a release artifact without production signing material.
afterEvaluate {
    listOf("bundleRelease", "assembleRelease").forEach { taskName ->
        tasks.findByName(taskName)?.doFirst {
            if (!keystorePropertiesFile.exists()) {
                throw GradleException(
                    "Release builds require android/key.properties (see android/key.properties.example)."
                )
            }
        }
    }
}

flutter {
    source = "../.."
}
