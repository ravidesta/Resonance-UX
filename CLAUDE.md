# Luminous Integral Architecture

## Project Overview

Luminous Integral Architecture (LIA) is a multiplatform ecosystem delivering a unified experience across Apple platforms (iOS, iPadOS, macOS, watchOS, visionOS), Android, and Desktop. The project uses Kotlin Multiplatform (KMP) for shared business logic and platform-native UI frameworks: SwiftUI for Apple platforms and Jetpack Compose / Compose Multiplatform for Android and Desktop.

The ecosystem is built around the Resonance UX design system, which defines shared design tokens, interaction patterns, and accessibility principles across all platforms.

## Architecture

```
shared/           KMP shared module (Kotlin) - models, services, content, design tokens
android/          Android app (Jetpack Compose + Material3)
desktop/          Desktop app (Compose Multiplatform for Linux/Windows/macOS)
apple/            Apple platforms (SwiftUI)
  iOS/            iPhone-specific UI
  iPadOS/         iPad-specific UI
  macOS/          macOS-specific UI (SwiftUI preferred over Compose)
  watchOS/        watchOS companion
  visionOS/       visionOS spatial experience
  Shared/         Shared Swift code across Apple platforms
```

### Shared Module (`shared/`)

The KMP shared module contains platform-agnostic code consumed by all targets:

- `shared/model/` - Data models and domain entities
- `shared/service/` - Business logic, repositories, use cases
- `shared/content/` - Content definitions and structured data
- `shared/design/` - Design tokens (colors, typography, spacing) in Kotlin

Source sets: `commonMain`, `androidMain`, `iosMain`, `desktopMain`

### Design System: Resonance UX

Resonance UX tokens and principles are defined in `shared/design/` and translated to each platform's native design language. The system emphasizes:

- Adaptive layouts that respond to device context
- Consistent color, typography, and spacing tokens
- Night mode / daily flow theming
- Accessibility as a first-class concern

## Build Commands

### Android
```bash
./gradlew :android:assembleDebug          # Debug APK
./gradlew :android:assembleRelease        # Release APK
./gradlew :android:installDebug           # Install on connected device
```

### Desktop
```bash
./gradlew :desktop:run                    # Run desktop app
./gradlew :desktop:packageDeb             # Linux .deb package
./gradlew :desktop:packageRpm             # Linux .rpm package
./gradlew :desktop:packageMsi             # Windows .msi installer
./gradlew :desktop:packageDmg             # macOS .dmg (Compose Desktop)
```

### Shared Module
```bash
./gradlew :shared:build                   # Build all targets
./gradlew :shared:allTests                # Run tests on all targets
./gradlew :shared:linkDebugFrameworkIosArm64   # Build iOS framework
```

### Apple (Xcode)
Open the Xcode project or use `xcodebuild` from the `apple/` directory. The shared KMP framework is linked as a binary dependency. Swift Package Manager handles Apple-only shared code via `apple/Package.swift`.

## Content Structure

The root-level content files define the application's narrative and interaction models:

- `Daily Flow with Night Mode` - Theming and flow-state interaction design
- `Resonance 1`, `Resonance 3` - Core Resonance UX specifications
- `Writer`, `Writer Commentary` - Audiobook and reader content structure
- `iPAD` - iPad-specific interaction and layout definitions
- `To Do` - Feature planning and task tracking

## Key Conventions

- Kotlin 2.0.21 with Compose Multiplatform 1.7.1
- Android compileSdk/targetSdk 35, minSdk 26
- Swift 5.9+ with strict concurrency
- Apple platform minimums: iOS 17, macOS 14, watchOS 10, tvOS 17, visionOS 1
- Hilt for Android dependency injection
- Media3/ExoPlayer for audiobook playback on Android
- All UI is platform-native: no cross-platform UI rendering compromise
