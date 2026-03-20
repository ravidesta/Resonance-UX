import org.jetbrains.compose.desktop.application.dsl.TargetFormat

plugins {
    kotlin("jvm")
    id("org.jetbrains.compose")
    id("org.jetbrains.kotlin.plugin.compose")
}

dependencies {
    implementation(project(":shared"))

    implementation(compose.desktop.currentOs)
    implementation(compose.material3)
    implementation(compose.components.resources)

    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-swing:1.9.0")
}

compose.desktop {
    application {
        mainClass = "com.luminous.resonance.desktop.MainKt"

        nativeDistributions {
            targetFormats(
                TargetFormat.Deb,
                TargetFormat.Rpm,
                TargetFormat.Msi,
                TargetFormat.Exe,
                TargetFormat.Dmg,
            )

            packageName = "LuminousIntegralArchitecture"
            packageVersion = "1.0.0"
            description = "Luminous Integral Architecture - Desktop"
            vendor = "Luminous Resonance"

            linux {
                iconFile.set(project.file("src/main/resources/icon.png"))
                debMaintainer = "luminous@resonance.dev"
            }

            windows {
                iconFile.set(project.file("src/main/resources/icon.ico"))
                menuGroup = "Luminous Integral Architecture"
                upgradeUuid = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
            }

            macOS {
                iconFile.set(project.file("src/main/resources/icon.icns"))
                bundleID = "com.luminous.resonance.lia.desktop"
            }
        }
    }
}
