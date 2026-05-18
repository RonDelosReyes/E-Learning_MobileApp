
allprojects {
    repositories {
        flatDir {
            dirs(file("${project(":unityLibrary").projectDir}/libs"))
        }

        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Fix for "Namespace not specified" and "JVM Target Mismatch"
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library") || project.plugins.hasPlugin("com.android.application")) {
            val androidExtension = project.extensions.findByName("android")
            if (androidExtension != null) {
                // 1. Fix Namespace
                var hasNamespace = false
                try {
                    val getMethod = androidExtension.javaClass.getMethod("getNamespace")
                    if (getMethod.invoke(androidExtension) != null) {
                        hasNamespace = true
                    }
                } catch (e: Exception) {}

                if (!hasNamespace) {
                    try {
                        val method = androidExtension.javaClass.getMethod("setNamespace", String::class.java)
                        if (project.name == "flutter_unity_widget") {
                            method.invoke(androidExtension, "com.xraph.plugin.flutter_unity_widget")
                        } else if (project.name == "unityLibrary" || project.name == "xrmanifest.androidlib") {
                            method.invoke(androidExtension, "com.unity3d.player")
                        }
                    } catch (e: Exception) {}
                }

                // 2. Fix compileSdkVersion (Must be 36+ for androidx.activity)
                try {
                    val setCompileSdkVersion = androidExtension.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    setCompileSdkVersion.invoke(androidExtension, 36) // Update to 36
                } catch (e: Exception) {
                    // Fallback for different AGP versions
                    try {
                        val setCompileSdk = androidExtension.javaClass.getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                        setCompileSdk.invoke(androidExtension, 36)
                    } catch (e2: Exception) {}
                }

                // 3. Fix JVM Target Mismatch (Force all tasks to use Java 17)
                try {
                    val compileOptions = androidExtension.javaClass.getMethod("getCompileOptions").invoke(androidExtension)
                    val setSourceCompatibility = compileOptions.javaClass.getMethod("setSourceCompatibility", org.gradle.api.JavaVersion::class.java)
                    val setTargetCompatibility = compileOptions.javaClass.getMethod("setTargetCompatibility", org.gradle.api.JavaVersion::class.java)
                    
                    setSourceCompatibility.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                    setTargetCompatibility.invoke(compileOptions, org.gradle.api.JavaVersion.VERSION_17)
                } catch (e: Exception) {}
            }

            // Also force Kotlin tasks to use JVM 17
            tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                kotlinOptions {
                    jvmTarget = "17"
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
