try {
    val processEnv = Class.forName("java.lang.ProcessEnvironment")
    val theEnvironmentField = processEnv.getDeclaredField("theEnvironment")
    theEnvironmentField.isAccessible = true
    val env = theEnvironmentField.get(null) as MutableMap<String, String>
    env.remove("ANDROID_PREFS_ROOT")
    val theCaseInsensitiveEnvironmentField = processEnv.getDeclaredField("theCaseInsensitiveEnvironment")
    theCaseInsensitiveEnvironmentField.isAccessible = true
    val caseInsensitiveEnv = theCaseInsensitiveEnvironmentField.get(null) as MutableMap<String, String>
    caseInsensitiveEnv.remove("ANDROID_PREFS_ROOT")
} catch (e: Throwable) {}

pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("com.android.library") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

include(":unityLibrary")
project(":unityLibrary").projectDir = file("./unityLibrary")

include(":unityLibrary:xrmanifest.androidlib")
project(":unityLibrary:xrmanifest.androidlib").projectDir = file("./unityLibrary/xrmanifest.androidlib")
