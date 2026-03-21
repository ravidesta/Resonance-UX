// ResonanceApp_visionOS.swift
// Resonance — Design for the Exhale
//
// Vision Pro entry point — spatial glass panels, volumetric blobs,
// immersive writing, and ornament-based navigation.

import SwiftUI

#if os(visionOS)
@main
struct ResonanceApp_visionOS: App {
    @State private var themeManager = ThemeManager()
    @State private var showImmersiveWriter = false

    var body: some Scene {
        // Main window
        WindowGroup("Resonance", id: "main") {
            ContentView(themeManager: themeManager)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // Volumetric breathing orb
        WindowGroup("Breathing Orb", id: "breathing-orb") {
            VolumetricBreathingView(theme: themeManager.currentTheme)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.4, height: 0.4, depth: 0.4, in: .meters)

        // Immersive writing space
        ImmersiveSpace(id: "immersive-writer") {
            ImmersiveWriterEnvironment(theme: themeManager.currentTheme)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}

// MARK: - Volumetric Breathing View

struct VolumetricBreathingView: View {
    let theme: ResonanceTheme
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            // Outer orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.goldLight.opacity(0.3),
                            theme.goldPrimary.opacity(0.1),
                            theme.green200.opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .scaleEffect(isBreathing ? 1.15 : 0.85)
                .blur(radius: 20)

            // Inner orb
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.goldPrimary.opacity(0.4),
                            theme.goldLight.opacity(0.15)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(isBreathing ? 1.1 : 0.9)

            // Core
            Circle()
                .fill(theme.goldPrimary.opacity(0.6))
                .frame(width: 20, height: 20)
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathing)
        .onAppear { isBreathing = true }
    }
}

// MARK: - Immersive Writer Environment

struct ImmersiveWriterEnvironment: View {
    let theme: ResonanceTheme

    var body: some View {
        ZStack {
            // Ambient organic blobs in space
            OrganicBlobView(theme: theme, blobSet: .primary)
                .scaleEffect(3.0)
                .opacity(0.4)
                .offset(z: -200)

            OrganicBlobView(theme: theme, blobSet: .secondary)
                .scaleEffect(2.0)
                .opacity(0.3)
                .offset(x: 200, z: -150)

            // Floating particles
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .fill(theme.goldPrimary.opacity(0.15))
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(
                        x: CGFloat.random(in: -300...300),
                        y: CGFloat.random(in: -200...200)
                    )
                    .offset(z: CGFloat.random(in: -100...50))
                    .breathe(intensity: 0.1, duration: Double.random(in: 8...16))
            }
        }
    }
}
#endif
