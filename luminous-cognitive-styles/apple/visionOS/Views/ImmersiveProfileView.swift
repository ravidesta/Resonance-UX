// ImmersiveProfileView.swift
// Luminous Cognitive Styles™ — visionOS
// 3D radar chart in volumetric space with floating dimension cards

import SwiftUI
import RealityKit

// MARK: - Volumetric Radar View

struct VolumetricRadarView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var rotationAngle: Double = 0
    @State private var selectedDimension: CognitiveDimension?

    var body: some View {
        ZStack {
            if let profile = viewModel.currentProfile {
                // 3D rotating radar visualization
                TimelineView(.animation) { context in
                    let time = context.date.timeIntervalSinceReferenceDate

                    ZStack {
                        // Central glowing orb
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [LCSTheme.goldAccent.opacity(0.4), Color.clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(1.0 + sin(time * 0.5) * 0.05)

                        // Rotating radar layers at different depths
                        ForEach(0..<3, id: \.self) { layer in
                            RadarChartLayer(
                                profile: profile,
                                layerIndex: layer,
                                time: time
                            )
                            .rotation3DEffect(
                                .degrees(Double(layer) * 15 + time * (5 + Double(layer) * 2)),
                                axis: (x: 0.1 * Double(layer), y: 1, z: 0.05 * Double(layer))
                            )
                            .opacity(layer == 0 ? 1.0 : 0.3 + Double(layer) * 0.1)
                        }

                        // Floating dimension labels
                        ForEach(CognitiveDimension.allCases) { dim in
                            let index = dim.rawValue
                            let angle = (Double(index) / 7.0) * 2 * .pi - .pi / 2
                            let radius: Double = 180
                            let x = cos(angle) * radius
                            let y = sin(angle) * radius

                            VStack(spacing: 4) {
                                Image(systemName: dim.icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(dim.color)
                                    .shadow(color: dim.color.opacity(0.6), radius: 8)

                                Text(dim.abbreviation)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(dim.color)

                                Text(ScoreFormatter.formatted(profile.score(for: dim)))
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            .offset(x: x, y: y)
                            .offset(z: sin(time * 0.3 + Double(index) * 0.8) * 20)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedDimension = selectedDimension == dim ? nil : dim
                                }
                            }
                        }

                        // Profile name at top
                        VStack {
                            Text(profile.profileTypeName)
                                .font(.system(size: 18, weight: .bold, design: .serif))
                                .foregroundColor(LCSTheme.goldAccent)
                                .shadow(color: LCSTheme.goldAccent.opacity(0.3), radius: 4)
                        }
                        .offset(y: -220)
                    }
                }

                // Selected dimension detail card
                if let dim = selectedDimension {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: dim.icon)
                                .foregroundColor(dim.color)
                            Text(dim.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Button {
                                withAnimation { selectedDimension = nil }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        Text(dim.interpretation(for: profile.score(for: dim)))
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))

                        HStack {
                            Text(dim.lowPole)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                            Spacer()
                            Text(ScoreFormatter.formatted(profile.score(for: dim)))
                                .font(.title2.weight(.bold))
                                .foregroundColor(dim.color)
                            Spacer()
                            Text(dim.highPole)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    .padding()
                    .frame(maxWidth: 300)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    .offset(y: 200)
                    .transition(.scale.combined(with: .opacity))
                }

            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 48))
                        .foregroundColor(LCSTheme.goldAccent)
                    Text("Complete an assessment\nto see your 3D profile")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

// MARK: - Radar Chart Layer

struct RadarChartLayer: View {
    let profile: CognitiveProfile
    let layerIndex: Int
    let time: Double

    var body: some View {
        let dimensions = CognitiveDimension.allCases
        let scores = dimensions.map { CGFloat(profile.score(for: $0) / 10.0) }
        let modifiedScores: [CGFloat] = scores.enumerated().map { index, score in
            let phase = time * 0.2 + Double(index) * 0.5 + Double(layerIndex)
            let wobble = CGFloat(sin(phase) * 0.03)
            return score + wobble
        }

        ZStack {
            if layerIndex == 0 {
                // Main filled radar
                RadarDataPolygon(values: modifiedScores, animationProgress: 1.0)
                    .fill(
                        AngularGradient(
                            colors: dimensions.map { $0.color.opacity(0.25) } + [dimensions.first!.color.opacity(0.25)],
                            center: .center
                        )
                    )
                    .frame(width: 280, height: 280)
            }

            RadarDataPolygon(values: modifiedScores, animationProgress: 1.0)
                .stroke(
                    AngularGradient(
                        colors: dimensions.map { $0.color.opacity(layerIndex == 0 ? 1.0 : 0.3) }
                            + [dimensions.first!.color.opacity(layerIndex == 0 ? 1.0 : 0.3)],
                        center: .center
                    ),
                    lineWidth: layerIndex == 0 ? 2 : 0.5
                )
                .frame(width: 280, height: 280)
        }
    }
}
