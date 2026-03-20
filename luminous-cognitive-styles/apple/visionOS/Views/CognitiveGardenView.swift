// CognitiveGardenView.swift
// Luminous Cognitive Styles™ — visionOS
// 3D immersive visualization where each dimension is a garden element

import SwiftUI
import RealityKit

struct CognitiveGardenView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @State private var selectedElement: CognitiveDimension?
    @State private var animationPhase: Double = 0

    // Garden element mapping for each dimension
    private let gardenElements: [(dimension: CognitiveDimension, element: GardenElement)] = [
        (.perceptualMode, GardenElement(name: "Crystal Lens", icon: "diamond.fill", description: "A crystal that refracts light into its component colors, or focuses it into a unified beam.")),
        (.processingRhythm, GardenElement(name: "Flowing Stream", icon: "water.waves", description: "Water that moves in deliberate, measured flows or rushes in spontaneous cascades.")),
        (.generativeOrientation, GardenElement(name: "Branching Tree", icon: "tree.fill", description: "A tree whose branches converge toward the sky or diverge in wild, creative patterns.")),
        (.representationalChannel, GardenElement(name: "Story Stone", icon: "text.book.closed.fill", description: "A stone etched with words on one side and vivid imagery on the other.")),
        (.relationalOrientation, GardenElement(name: "Garden Bridge", icon: "figure.2.arms.open", description: "A bridge between solitary contemplation gardens and communal gathering spaces.")),
        (.somaticIntegration, GardenElement(name: "Living Sculpture", icon: "figure.mind.and.body", description: "A sculpture that breathes and moves, integrating form and feeling.")),
        (.complexityTolerance, GardenElement(name: "Paradox Flower", icon: "sparkle", description: "A flower that blooms in certainty's light or thrives in mystery's shadow.")),
    ]

    var body: some View {
        RealityView { content in
            // Create a simple anchor entity for the garden
            let anchor = AnchorEntity(.head)
            anchor.position = [0, 0, -2] // 2 meters in front

            // Add ambient lighting
            let lightEntity = Entity()
            var pointLight = PointLightComponent()
            pointLight.intensity = 5000
            pointLight.color = .white
            lightEntity.components.set(pointLight)
            lightEntity.position = [0, 2, 0]
            anchor.addChild(lightEntity)

            content.add(anchor)
        } update: { content in
            // Updates handled by SwiftUI overlays
        }
        .overlay {
            gardenOverlay
        }
    }

    // MARK: - Garden Overlay (SwiftUI layer)

    private var gardenOverlay: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            ZStack {
                // Atmospheric particles
                ForEach(0..<20, id: \.self) { i in
                    let phase = time * 0.1 + Double(i) * 0.5
                    let x = sin(phase * 0.3 + Double(i)) * 400
                    let y = cos(phase * 0.2 + Double(i) * 1.3) * 300
                    Circle()
                        .fill(LCSTheme.dimensionColors[i % 7].opacity(0.15))
                        .frame(width: CGFloat(8 + i % 5 * 3), height: CGFloat(8 + i % 5 * 3))
                        .blur(radius: 2)
                        .offset(x: x, y: y)
                }

                if let profile = viewModel.currentProfile {
                    // Garden elements arranged in a circle
                    ForEach(gardenElements, id: \.dimension) { item in
                        let index = item.dimension.rawValue
                        let score = profile.score(for: item.dimension)
                        let angle = (Double(index) / 7.0) * 2 * .pi - .pi / 2
                        let radius: Double = 280
                        let x = cos(angle) * radius
                        let y = sin(angle) * radius
                        let floatOffset = sin(time * 0.3 + Double(index) * 0.8) * 8

                        GardenElementView(
                            element: item.element,
                            dimension: item.dimension,
                            score: score,
                            isSelected: selectedElement == item.dimension,
                            floatOffset: floatOffset
                        )
                        .offset(x: x, y: y)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4)) {
                                selectedElement = selectedElement == item.dimension ? nil : item.dimension
                            }
                        }
                    }

                    // Center: profile name
                    VStack(spacing: 8) {
                        Text(profile.profileTypeName)
                            .font(.system(size: 24, weight: .bold, design: .serif))
                            .foregroundColor(LCSTheme.goldAccent)
                            .shadow(color: LCSTheme.goldAccent.opacity(0.3), radius: 8)

                        // Mini radar in center
                        CompactRadarChartView(profile: profile, size: 80)
                            .opacity(0.8)
                    }
                    .offset(y: sin(time * 0.15) * 5)

                    // Detail panel for selected element
                    if let dim = selectedElement,
                       let element = gardenElements.first(where: { $0.dimension == dim }) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: element.element.icon)
                                    .font(.title2)
                                    .foregroundColor(dim.color)
                                Text(element.element.name)
                                    .font(.title3.weight(.bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    withAnimation { selectedElement = nil }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            Text(element.element.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))

                            Divider().background(Color.white.opacity(0.1))

                            DimensionScoreView(
                                dimension: dim,
                                score: profile.score(for: dim),
                                showInterpretation: true,
                                animated: false
                            )
                        }
                        .padding(20)
                        .frame(maxWidth: 350)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                        )
                        .offset(y: 300)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                } else {
                    // No profile - garden is sparse
                    VStack(spacing: 20) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.green.opacity(0.6))
                            .offset(y: sin(time * 0.2) * 10)

                        Text("Your Cognitive Garden")
                            .font(.title.weight(.bold))
                            .foregroundColor(.white)

                        Text("Complete an assessment to\ngrow your garden elements.")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
    }
}

// MARK: - Garden Element Model

struct GardenElement {
    let name: String
    let icon: String
    let description: String
}

// MARK: - Garden Element View

struct GardenElementView: View {
    let element: GardenElement
    let dimension: CognitiveDimension
    let score: Double
    let isSelected: Bool
    let floatOffset: Double

    private var elementScale: Double {
        0.5 + (score / 10.0) * 0.8
    }

    var body: some View {
        VStack(spacing: 8) {
            // Glowing orb behind icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [dimension.color.opacity(0.4), dimension.color.opacity(0.0)],
                            center: .center,
                            startRadius: 5,
                            endRadius: 40 * elementScale
                        )
                    )
                    .frame(width: 80 * elementScale, height: 80 * elementScale)
                    .blur(radius: 4)

                Image(systemName: element.icon)
                    .font(.system(size: 28 * elementScale))
                    .foregroundColor(dimension.color)
                    .shadow(color: dimension.color.opacity(0.6), radius: isSelected ? 12 : 6)
            }
            .scaleEffect(isSelected ? 1.2 : 1.0)

            Text(element.name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(dimension.color)

            Text(ScoreFormatter.formatted(score))
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            // Score visualization: small growing bars
            HStack(spacing: 2) {
                ForEach(0..<Int(score.rounded()), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(dimension.color.opacity(0.6))
                        .frame(width: 3, height: 8)
                }
            }
        }
        .offset(y: floatOffset)
    }
}
