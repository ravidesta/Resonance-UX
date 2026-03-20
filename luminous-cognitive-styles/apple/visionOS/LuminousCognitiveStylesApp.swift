// LuminousCognitiveStylesApp.swift
// Luminous Cognitive Styles™ — visionOS
// Vision Pro app with volumetric UI and immersive spaces

import SwiftUI

@main
struct LuminousCognitiveStylesVisionApp: App {
    @StateObject private var viewModel = AssessmentViewModel()
    @State private var immersionStyle: ImmersionStyle = .mixed

    var body: some Scene {
        // Main window
        WindowGroup {
            VisionHomeView()
                .environmentObject(viewModel)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 800)

        // Volumetric radar chart window
        WindowGroup(id: "radar-volume") {
            VolumetricRadarView()
                .environmentObject(viewModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)

        // Immersive cognitive garden
        ImmersiveSpace(id: "cognitive-garden") {
            CognitiveGardenView()
                .environmentObject(viewModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive)
    }
}

// MARK: - Vision Home View

struct VisionHomeView: View {
    @EnvironmentObject var viewModel: AssessmentViewModel
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @State private var selectedTab: VisionTab = .profile
    @State private var isGardenOpen = false

    enum VisionTab: String, CaseIterable {
        case profile = "Profile"
        case assessment = "Assessment"
        case explore = "Explore"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // Profile Tab
            VisionProfileTab()
                .tabItem { Label("Profile", systemImage: "brain.head.profile") }
                .tag(VisionTab.profile)

            // Assessment Tab
            SpatialAssessmentView()
                .tabItem { Label("Assessment", systemImage: "slider.horizontal.3") }
                .tag(VisionTab.assessment)

            // Explore Tab
            VisionExploreTab()
                .tabItem { Label("Explore", systemImage: "sparkles") }
                .tag(VisionTab.explore)
        }
        .ornament(visibility: .visible, attachmentAnchor: .scene(.bottom)) {
            HStack(spacing: 24) {
                Button {
                    openWindow(id: "radar-volume")
                } label: {
                    Label("3D Radar", systemImage: "cube")
                }
                .buttonStyle(.bordered)

                Button {
                    Task {
                        if isGardenOpen {
                            await dismissImmersiveSpace()
                        } else {
                            await openImmersiveSpace(id: "cognitive-garden")
                        }
                        isGardenOpen.toggle()
                    }
                } label: {
                    Label(isGardenOpen ? "Close Garden" : "Cognitive Garden", systemImage: "leaf.fill")
                }
                .buttonStyle(.bordered)
                .tint(isGardenOpen ? .red : .green)
            }
            .padding()
            .glassBackgroundEffect()
        }
    }
}

// MARK: - Vision Profile Tab

struct VisionProfileTab: View {
    @EnvironmentObject var viewModel: AssessmentViewModel

    var body: some View {
        HStack(spacing: 40) {
            // Left: Radar chart
            if let profile = viewModel.currentProfile {
                VStack(spacing: 24) {
                    Text(profile.profileTypeName)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.white)

                    RadarChartView(
                        profile: profile,
                        showLabels: true,
                        showAdaptiveRange: true,
                        animated: true,
                        size: 350
                    )

                    Text(profile.profileSummary)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                .frame(maxWidth: .infinity)

                // Right: Dimension details
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(CognitiveDimension.allCases) { dim in
                            VisionDimensionCard(
                                dimension: dim,
                                score: profile.score(for: dim)
                            )
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: 400)
            } else {
                // No profile
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 64))
                        .foregroundColor(LCSTheme.goldAccent)

                    Text("Discover Your\nCognitive Signature")
                        .font(.system(size: 40, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("Navigate to the Assessment tab to begin your journey.")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(40)
    }
}

// MARK: - Vision Dimension Card

struct VisionDimensionCard: View {
    let dimension: CognitiveDimension
    let score: Double
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: dimension.icon)
                    .font(.title3)
                    .foregroundColor(dimension.color)

                Text(dimension.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                Text(ScoreFormatter.formatted(score))
                    .font(.system(.title3, design: .monospaced).weight(.bold))
                    .foregroundColor(dimension.color)
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(dimension.color)
                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(score)))
                }
            }
            .frame(height: 6)

            HStack {
                Text(dimension.lowPole)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(dimension.highPole)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }

            if isHovered {
                Text(dimension.interpretation(for: score))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .hoverEffect(.lift)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Vision Explore Tab

struct VisionExploreTab: View {
    @EnvironmentObject var viewModel: AssessmentViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Text("Explore Cognitive Styles")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.white)

                // Dimension grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                ], spacing: 20) {
                    ForEach(CognitiveDimension.allCases) { dim in
                        VisionExploreTile(dimension: dim)
                    }
                }

                // Book teaser
                VStack(spacing: 16) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 40))
                        .foregroundColor(LCSTheme.goldAccent)

                    Text("Read the Book")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)

                    Text("9 chapters exploring each dimension of cognitive style in depth.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 400)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )

                Spacer(minLength: 60)
            }
            .padding(40)
        }
    }
}

struct VisionExploreTile: View {
    let dimension: CognitiveDimension
    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: dimension.icon)
                .font(.system(size: 32))
                .foregroundColor(dimension.color)

            Text(dimension.name)
                .font(.headline)
                .foregroundColor(.white)

            Text("\(dimension.lowPole) ↔ \(dimension.highPole)")
                .font(.caption)
                .foregroundColor(dimension.color.opacity(0.8))

            if isHovered {
                Text(dimension.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .transition(.opacity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isHovered ? dimension.color.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .hoverEffect(.highlight)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.25)) {
                isHovered = hovering
            }
        }
    }
}
