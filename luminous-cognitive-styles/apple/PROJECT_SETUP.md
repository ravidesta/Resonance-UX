# Luminous Cognitive Styles -- Xcode Project Setup

## Overview

This document describes how to create the Xcode project with targets for all four Apple platforms: iOS, macOS, watchOS, and visionOS. All platforms share a common codebase in the `Shared/` directory.

## Prerequisites

- Xcode 15.2 or later (Xcode 16+ recommended for visionOS 2.0)
- macOS 14 Sonoma or later
- Apple Developer account (for device testing and App Store submission)
- visionOS SDK (installed via Xcode > Settings > Platforms)

## Project Structure

```
apple/
  Package.swift               -- SPM package for shared code
  Shared/
    Models/
      CognitiveDimension.swift  -- 7 dimensions, profile struct
      Assessment.swift          -- DSR questions, scoring logic
      BookChapter.swift         -- 9 book chapters
    Views/
      RadarChartView.swift      -- Radar/spider chart (animated)
      DimensionScoreView.swift  -- Horizontal score bars
      CognitiveSignatureView.swift -- Full results view
    ViewModels/
      AssessmentViewModel.swift -- State management, persistence
    Theme/
      LCSTheme.swift            -- Colors, gradients, styles
    Utils/
      Scoring.swift             -- Profile naming, interpretation
  iOS/
    LuminousCognitiveStylesApp.swift
    Views/
      HomeView.swift
      QuickProfileView.swift
      FullAssessmentView.swift
      ResultsView.swift
      BookReaderView.swift
      CoachingView.swift
      ProfileView.swift
      Components/
        LCSSlider.swift
        DimensionCard.swift
      iPad/
        SplitAssessmentView.swift
        LargeRadarView.swift
  macOS/
    LuminousCognitiveStylesApp.swift
    Views/
      SidebarView.swift
      DashboardView.swift
      AssessmentView.swift
  watchOS/
    LuminousCognitiveStylesApp.swift
    Views/
      GlanceView.swift
      QuickCheckInView.swift
      ComplicationView.swift
    Widgets/
      CognitiveWidget.swift
  visionOS/
    LuminousCognitiveStylesApp.swift
    Views/
      ImmersiveProfileView.swift
      SpatialAssessmentView.swift
      CognitiveGardenView.swift
```

## Creating the Xcode Project

### Step 1: Create a Multi-Platform App

1. Open Xcode and select File > New > Project
2. Choose "Multiplatform" > "App"
3. Name: `LuminousCognitiveStyles`
4. Organization Identifier: `com.luminous.cognitivestyles`
5. Interface: SwiftUI
6. Language: Swift
7. Storage: None
8. Uncheck "Include Tests" (we will add tests via the SPM package)

### Step 2: Add Platform Targets

After creating the project, add additional targets:

**watchOS Target:**
1. File > New > Target
2. watchOS > App
3. Name: `LCS Watch`
4. Include Complication: Yes

**watchOS Widget Extension:**
1. File > New > Target
2. watchOS > Widget Extension
3. Name: `LCS Watch Widget`

**visionOS Target:**
1. File > New > Target
2. visionOS > App
3. Name: `LCS Vision`
4. Immersive Space: Mixed
5. Immersive Style: Mixed Reality

### Step 3: Add Shared Code as Local SPM Package

1. File > Add Package Dependencies
2. Click "Add Local..."
3. Navigate to the `apple/` directory and select `Package.swift`
4. Add `LCSShared` library to all targets

Alternatively, add all `Shared/` files directly to each target's build phases.

### Step 4: Configure Each Target

#### iOS Target
- Add all files from `iOS/` to the iOS target
- Deployment target: iOS 17.0
- Device families: iPhone, iPad
- Supported orientations: All
- Add shared files or link LCSShared package

#### macOS Target
- Add all files from `macOS/` to the macOS target
- Deployment target: macOS 14.0
- App Sandbox: Enabled
- Hardened Runtime: Enabled

#### watchOS Target
- Add all files from `watchOS/` to the watchOS target
- Deployment target: watchOS 10.0
- Add `CognitiveWidget.swift` to the Widget Extension target

#### visionOS Target
- Add all files from `visionOS/` to the visionOS target
- Deployment target: visionOS 1.0
- Required capabilities: Immersive Space
- Add Info.plist key: `UIApplicationPreferredDefaultSceneSessionRole` = `UIWindowSceneSessionRoleImmersiveSpaceApplication`

### Step 5: Signing and Capabilities

For each target:
1. Select the target in the project navigator
2. Go to "Signing & Capabilities"
3. Select your development team
4. Enable automatic signing

Required capabilities per target:
- **iOS**: None beyond default
- **macOS**: App Sandbox (with outgoing network connections for future coaching features)
- **watchOS**: HealthKit (optional, for future somatic integration features)
- **visionOS**: Immersive Space

## Deployment Targets

| Platform | Minimum Version | Recommended |
|----------|----------------|-------------|
| iOS      | 17.0           | 17.4+       |
| macOS    | 14.0           | 14.3+       |
| watchOS  | 10.0           | 10.2+       |
| visionOS | 1.0            | 2.0+        |

## Build Configuration

### Conditional Compilation

The shared code uses `#if os(...)` where platform-specific behavior is needed:

```swift
#if os(iOS)
// iOS-specific code
#elseif os(macOS)
// macOS-specific code
#elseif os(watchOS)
// watchOS-specific code
#elseif os(visionOS)
// visionOS-specific code
#endif
```

### App Icons

Create app icons for each platform:
- iOS: 1024x1024 (single icon, auto-scaled)
- macOS: 1024x1024 (with macOS-specific shape)
- watchOS: 1024x1024 (circular crop)
- visionOS: 1024x1024 (auto-cropped to circle)

Recommended icon design: A luminous, golden neural/star pattern on a deep navy (#0D1B2A) background.

### Launch Screens

- iOS: Use a SwiftUI-based launch screen with the LCS logo and gold gradient
- macOS: Not applicable (uses window appearance)
- watchOS: Not applicable
- visionOS: Uses default spatial launch

## Data Persistence

All platforms use `UserDefaults` for data persistence via `AssessmentViewModel`. Keys are prefixed with `lcs_` to avoid collisions. For shared data between Apple Watch and iPhone, consider implementing WatchConnectivity framework in a future update.

## App Store Submission Notes

### App Store Metadata

- **Category**: Education / Health & Fitness
- **Content Rating**: 4+ (no objectionable content)
- **Privacy**: No data collected (all processing on-device)

### Privacy Nutrition Labels

- Data Not Collected: This app does not collect any data

### Review Notes

- The app is a cognitive style assessment tool based on the Luminous Cognitive Styles framework
- All assessments and data remain on the user's device
- The coaching features with pricing shown are UI mockups for future implementation
- No network requests are made in this version

### Screenshots Required

- iPhone 6.7" (4 screenshots minimum)
- iPhone 6.1" (4 screenshots minimum)
- iPad 12.9" (4 screenshots minimum)
- Apple Watch (optional)
- Apple Vision Pro (optional)
- Mac (optional, if submitting Mac version separately)

## Testing

Run the SPM test target:
```bash
cd apple/
swift test
```

For UI testing, create XCUITest targets for each platform in Xcode.

## Future Enhancements

1. **CloudKit sync** -- Sync profiles across devices using CloudKit
2. **WatchConnectivity** -- Real-time sync between Watch and iPhone
3. **HealthKit integration** -- Correlate cognitive patterns with health data
4. **Widget Extensions** -- iOS home screen widgets
5. **App Intents** -- Siri integration for quick check-ins
6. **SharePlay** -- Collaborative assessment sessions
7. **StoreKit 2** -- In-app purchases for coaching subscriptions
