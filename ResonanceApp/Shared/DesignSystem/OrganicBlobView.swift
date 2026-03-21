// OrganicBlobView.swift
// Resonance — Design for the Exhale
//
// Soft, breathing organic blobs that create the ambient biophilic background.

import SwiftUI

struct OrganicBlobView: View {
    let theme: ResonanceTheme
    let blobSet: BlobSet

    enum BlobSet {
        case primary
        case secondary
        case subtle
    }

    var body: some View {
        ZStack {
            switch blobSet {
            case .primary:
                primaryBlobs
            case .secondary:
                secondaryBlobs
            case .subtle:
                subtleBlobs
            }
        }
        .allowsHitTesting(false)
    }

    private var primaryBlobs: some View {
        ZStack {
            // Large green blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.green200.opacity(0.4),
                            theme.green100.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .blur(radius: 70)
                .breathe(intensity: 0.05, duration: 15)
                .offset(x: -60, y: -100)

            // Gold accent blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.goldLight.opacity(0.25),
                            theme.goldPrimary.opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .breathe(intensity: 0.04, duration: 18)
                .offset(x: 80, y: 120)

            // Small deep green blob
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.green700.opacity(0.15),
                            theme.green200.opacity(0.02)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .breathe(intensity: 0.06, duration: 20)
                .offset(x: 40, y: -200)
        }
    }

    private var secondaryBlobs: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.goldPrimary.opacity(0.15),
                            theme.goldLight.opacity(0.03)
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .breathe(intensity: 0.03, duration: 12)
                .offset(x: 100, y: -60)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            theme.green100.opacity(0.3),
                            theme.green200.opacity(0.05)
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .blur(radius: 60)
                .breathe(intensity: 0.05, duration: 16)
                .offset(x: -80, y: 100)
        }
    }

    private var subtleBlobs: some View {
        ZStack {
            Circle()
                .fill(theme.green100.opacity(0.2))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .breathe(intensity: 0.03, duration: 14)
                .offset(x: -30, y: -40)

            Circle()
                .fill(theme.goldLight.opacity(0.1))
                .frame(width: 150, height: 150)
                .blur(radius: 50)
                .breathe(intensity: 0.04, duration: 17)
                .offset(x: 50, y: 60)
        }
    }
}

// MARK: - Paper Texture Overlay

struct PaperTextureView: View {
    let opacity: Double

    var body: some View {
        Canvas { context, size in
            // Create subtle noise pattern
            for _ in 0..<2000 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let gray = CGFloat.random(in: 0.3...0.7)
                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(Color(white: gray, opacity: opacity))
                )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Ambient Background

struct AmbientBackground: View {
    let theme: ResonanceTheme
    var showTexture: Bool = true

    var body: some View {
        ZStack {
            theme.bgBase
                .ignoresSafeArea()

            OrganicBlobView(theme: theme, blobSet: .primary)
                .opacity(0.7)

            if showTexture {
                PaperTextureView(opacity: 0.035)
                    .ignoresSafeArea()
            }
        }
    }
}
