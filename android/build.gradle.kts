
allprojects {
    repositories {
        flatDir {
            dirs(file("${project(":unityLibrary").projectDir}/libs"))
        }
        google()
        mavenCentral()
    }
}

subprojects {
    project.layout.buildDirectory.set(rootProject.layout.buildDirectory.dir("../../build/${project.name}"))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
