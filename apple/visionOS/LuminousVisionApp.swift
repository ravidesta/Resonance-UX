// LuminousVisionApp.swift
// Luminous Integral Architecture™ — visionOS Spatial App
//
// Immersive spatial reading environment with 3D quadrant visualization,
// volumetric book, spatial audio, coach avatar, and architectural AR mode.

import SwiftUI
#if os(visionOS)
import RealityKit
#endif

// MARK: - visionOS App Entry

@main
struct LuminousVisionApp: App {
    @StateObject private var appState = VisionAppState()

    var body: some Scene {
        // Main window group — 2D window in shared space
        WindowGroup("Luminous Integral Architecture", id: "main") {
            VisionMainView()
                .environmentObject(appState)
        }
        .windowStyle(.automatic)

        // Volumetric book window
        WindowGroup("Volumetric Book", id: "volumetric-book") {
            VolumetricBookView()
                .environmentObject(appState)
        }
        #if os(visionOS)
        .windowStyle(.volumetric)
        .defaultSize(width: 0.4, height: 0.5, depth: 0.1, in: .meters)
        #endif

        // Quadrant model — volumetric 3D visualization
        WindowGroup("Quadrant Model", id: "quadrant-model") {
            QuadrantModelView()
                .environmentObject(appState)
        }
        #if os(visionOS)
        .windowStyle(.volumetric)
        .defaultSize(width: 0.6, height: 0.6, depth: 0.6, in: .meters)
        #endif

        // Immersive reading space
        #if os(visionOS)
        ImmersiveSpace(id: "immersive-reading") {
            ImmersiveReadingEnvironment()
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .progressive)

        // Architectural visualization
        ImmersiveSpace(id: "architectural-visualization") {
            ArchitecturalVisualizationView()
                .environmentObject(appState)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        #endif
    }
}

// MARK: - Vision App State

@MainActor
final class VisionAppState: ObservableObject {
    @Published var selectedTab: VisionTab = .read
    @Published var isImmersiveReading = false
    @Published var isQuadrantModelVisible = false
    @Published var isVolumetricBookOpen = false
    @Published var isArchitecturalModeActive = false
    @Published var spatialAudioEnabled = true
    @Published var currentChapterIndex: Int = 1
    @Published var readingProgress: Double = 0.35

    enum VisionTab: String, CaseIterable {
        case read      = "Read"
        case listen    = "Listen"
        case learn     = "Learn"
        case coach     = "Coach"
        case community = "Community"

        var icon: String {
            switch self {
            case .read:      return "book.fill"
            case .listen:    return "headphones"
            case .learn:     return "graduationcap.fill"
            case .coach:     return "sparkles"
            case .community: return "person.3.fill"
            }
        }
    }
}

// MARK: - Vision Main View

struct VisionMainView: View {
    @EnvironmentObject private var appState: VisionAppState
    @Environment(\.openWindow) private var openWindow
    #if os(visionOS)
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    #endif

    var body: some View {
        NavigationSplitView {
            visionSidebar
        } detail: {
            visionDetailView
        }
        .ornament(attachmentAnchor: .scene(.bottom)) {
            spatialControls
        }
    }

    // MARK: Sidebar

    private var visionSidebar: some View {
        List(selection: $appState.selectedTab) {
            Section("Experience") {
                ForEach(VisionAppState.VisionTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }

            Section("Spatial") {
                Button {
                    openWindow(id: "volumetric-book")
                    appState.isVolumetricBookOpen = true
                } label: {
                    Label("Volumetric Book", systemImage: "book.closed.fill")
                }
                .accessibilityLabel("Open volumetric book in space")

                Button {
                    openWindow(id: "quadrant-model")
                    appState.isQuadrantModelVisible = true
                } label: {
                    Label("3D Quadrant Model", systemImage: "cube.transparent")
                }
                .accessibilityLabel("Open three-dimensional quadrant model")

                Button {
                    Task {
                        #if os(visionOS)
                        await openImmersiveSpace(id: "immersive-reading")
                        appState.isImmersiveReading = true
                        #endif
                    }
                } label: {
                    Label("Immersive Reading", systemImage: "visionpro")
                }
                .accessibilityLabel("Enter immersive reading environment")

                Button {
                    Task {
                        #if os(visionOS)
                        await openImmersiveSpace(id: "architectural-visualization")
                        appState.isArchitecturalModeActive = true
                        #endif
                    }
                } label: {
                    Label("Architectural AR", systemImage: "building.2.fill")
                }
                .accessibilityLabel("View architectural visualizations in augmented reality")
            }

            Section("Audio") {
                Toggle("Spatial Audio", isOn: $appState.spatialAudioEnabled)
                    .tint(Color.resonanceGoldPrimary)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Luminous")
    }

    // MARK: Detail View

    @ViewBuilder
    private var visionDetailView: some View {
        switch appState.selectedTab {
        case .read:
            BookReaderView()
        case .listen:
            AudiobookPlayerView()
        case .learn:
            VisionLearnView()
        case .coach:
            VisionCoachView()
        case .community:
            EcosystemHubView()
        }
    }

    // MARK: Spatial Controls Ornament

    private var spatialControls: some View {
        HStack(spacing: 20) {
            ForEach(VisionAppState.VisionTab.allCases, id: \.self) { tab in
                Button {
                    appState.selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18))
                        Text(tab.rawValue)
                            .font(ResonanceTypography.sansCaption2())
                    }
                    .foregroundStyle(
                        appState.selectedTab == tab
                            ? Color.resonanceGoldPrimary
                            : .white.opacity(0.6)
                    )
                }
                .accessibilityLabel(tab.rawValue)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .glassPanel(cornerRadius: 24, padding: 0)
    }
}

// MARK: - Volumetric Book View

/// A 3D book representation that can be manipulated with gestures.
struct VolumetricBookView: View {
    @EnvironmentObject private var appState: VisionAppState
    @State private var rotation: Angle = .zero
    @State private var pageFlipProgress: Double = 0

    var body: some View {
        ZStack {
            // Book representation
            VStack(spacing: 0) {
                // Book cover / pages
                ZStack {
                    // Back cover
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.resonanceGreen800, Color.resonanceGreen900],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 280, height: 380)
                        .shadow(color: .black.opacity(0.3), radius: 10)

                    // Pages edge
                    Rectangle()
                        .fill(Color(hex: 0xF5F0E8))
                        .frame(width: 270, height: 370)
                        .offset(x: 2)

                    // Current page content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Luminous Integral Architecture")
                            .font(ResonanceTypography.serifTitle(size: 20))
                            .foregroundStyle(Color.resonanceGreen900)

                        ResonanceDivider()

                        Text(samplePageText)
                            .font(ResonanceTypography.serifBody(size: 14))
                            .foregroundStyle(Color.resonanceGreen900.opacity(0.8))
                            .lineSpacing(4)

                        Spacer()

                        HStack {
                            Spacer()
                            Text("Page \(Int(appState.readingProgress * 342))")
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(Color.resonanceGreen700)
                        }
                    }
                    .padding(24)
                    .frame(width: 260, height: 360)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(hex: 0xFAFAF8))
                    )

                    // Gold foil title on spine
                    HStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.resonanceGoldDark, Color.resonanceGoldPrimary, Color.resonanceGoldLight, Color.resonanceGoldPrimary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 3, height: 380)
                        Spacer()
                    }
                }
                .rotation3DEffect(rotation, axis: (x: 0, y: 1, z: 0))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            rotation = .degrees(Double(value.translation.width) * 0.3)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.5)) {
                                rotation = .zero
                            }
                        }
                )
                .accessibilityLabel("Volumetric book. Drag to rotate. Swipe to turn pages.")
                .accessibilityAddTraits(.allowsDirectInteraction)
            }
        }
    }

    private var samplePageText: String {
        "The integral approach begins with the recognition that every perspective holds a partial truth. No single view captures the fullness of reality."
    }
}

// MARK: - Quadrant Model View

/// 3D four-quadrant model visualization as spatial volumes.
struct QuadrantModelView: View {
    @EnvironmentObject private var appState: VisionAppState
    @State private var selectedQuadrant: String?
    @State private var modelRotation: Angle = .zero

    private let quadrants: [(name: String, label: String, color: Color, position: (x: CGFloat, y: CGFloat))] = [
        ("I",   "Interior Individual\n(Intentional)", Color.resonanceGreen700, (x: -1, y: 1)),
        ("It",  "Exterior Individual\n(Behavioral)",  Color.resonanceGreen500, (x: 1, y: 1)),
        ("We",  "Interior Collective\n(Cultural)",    Color.resonanceGoldPrimary, (x: -1, y: -1)),
        ("Its", "Exterior Collective\n(Social)",      Color.resonanceGoldDark, (x: 1, y: -1)),
    ]

    var body: some View {
        VStack {
            Text("The Four Quadrants")
                .font(ResonanceTypography.serifTitle())
                .foregroundStyle(.white)
                .padding(.top, 16)

            // 3D quadrant grid
            ZStack {
                // Axis lines
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 300)
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 300, height: 1)

                // Axis labels
                Text("Interior")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(x: -130, y: 0)
                Text("Exterior")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(x: 130, y: 0)
                Text("Individual")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(x: 0, y: -155)
                Text("Collective")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.4))
                    .offset(x: 0, y: 155)

                // Quadrant volumes
                ForEach(Array(quadrants.enumerated()), id: \.element.name) { _, quadrant in
                    quadrantVolume(quadrant)
                        .offset(
                            x: quadrant.position.x * 70,
                            y: quadrant.position.y * -70
                        )
                }
            }
            .rotation3DEffect(modelRotation, axis: (x: 0.2, y: 1, z: 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        modelRotation = .degrees(Double(value.translation.width) * 0.5)
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.5)) {
                            modelRotation = .zero
                        }
                    }
            )
            .accessibilityLabel("Three-dimensional four quadrant model. Drag to rotate.")

            // Selected quadrant detail
            if let selected = selectedQuadrant,
               let q = quadrants.first(where: { $0.name == selected }) {
                VStack(spacing: 4) {
                    Text(q.label)
                        .font(ResonanceTypography.sansBody())
                        .foregroundStyle(q.color)
                        .multilineTextAlignment(.center)
                    Text(quadrantDescription(for: q.name))
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(12)
                .glassPanel(cornerRadius: 12)
                .transition(.opacity)
            }
        }
    }

    private func quadrantVolume(_ quadrant: (name: String, label: String, color: Color, position: (x: CGFloat, y: CGFloat))) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                selectedQuadrant = selectedQuadrant == quadrant.name ? nil : quadrant.name
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(quadrant.color.opacity(selectedQuadrant == quadrant.name ? 0.5 : 0.25))
                    .frame(width: 120, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(quadrant.color.opacity(0.5), lineWidth: 1)
                    )
                    .shadow(color: quadrant.color.opacity(0.3), radius: selectedQuadrant == quadrant.name ? 15 : 5)

                VStack(spacing: 4) {
                    Text(quadrant.name)
                        .font(ResonanceTypography.sansTitle())
                        .foregroundStyle(quadrant.color)
                    Text(quadrant.label)
                        .font(ResonanceTypography.sansCaption2())
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(quadrant.label) quadrant")
        .scaleEffect(selectedQuadrant == quadrant.name ? 1.1 : 1.0)
        .animation(.spring(response: 0.3), value: selectedQuadrant)
    }

    private func quadrantDescription(for name: String) -> String {
        switch name {
        case "I":   return "Thoughts, feelings, intentions, awareness — the subjective interior of the individual."
        case "It":  return "Brain states, behaviors, observable actions — the objective exterior of the individual."
        case "We":  return "Shared meanings, values, worldviews, culture — the intersubjective interior of the collective."
        case "Its": return "Systems, institutions, environments, structures — the interobjective exterior of the collective."
        default:    return ""
        }
    }
}

// MARK: - Immersive Reading Environment

struct ImmersiveReadingEnvironment: View {
    @EnvironmentObject private var appState: VisionAppState

    var body: some View {
        ZStack {
            // Ambient environment — organic particles and soft lighting
            #if os(visionOS)
            RealityView { content in
                // Create ambient lighting entity
                let ambientLight = Entity()
                ambientLight.components.set(
                    PointLightComponent(
                        color: .init(Color.resonanceGoldLight),
                        intensity: 200,
                        attenuationRadius: 5
                    )
                )
                ambientLight.position = [0, 2, -1]
                content.add(ambientLight)

                // Create a subtle ground plane
                let ground = ModelEntity(
                    mesh: .generatePlane(width: 10, depth: 10),
                    materials: [SimpleMaterial(color: .init(white: 0.02, alpha: 0.5), isMetallic: false)]
                )
                ground.position = [0, -0.5, 0]
                content.add(ground)
            }
            #endif

            // Floating reading panel
            VStack {
                BookReaderView()
                    .frame(width: 700, height: 900)
                    .glassPanel(cornerRadius: 24)
            }
        }
        .accessibilityLabel("Immersive reading environment")
    }
}

// MARK: - Architectural Visualization

struct ArchitecturalVisualizationView: View {
    @EnvironmentObject private var appState: VisionAppState
    @State private var selectedStructure: String?

    private let structures = [
        ("Integral Tower", "A building embodying all four quadrants in its architecture", "building.2.fill"),
        ("Meditation Pavilion", "Open structure designed for spatial attunement practice", "house.lodge.fill"),
        ("Community Hub", "Interconnected spaces fostering integral community", "building.columns.fill"),
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Architectural Visualization")
                .font(ResonanceTypography.serifTitle())
                .foregroundStyle(.white)

            Text("Described buildings from the text rendered in your space")
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(.white.opacity(0.5))

            // Structure selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(structures, id: \.0) { name, description, icon in
                        Button {
                            selectedStructure = name
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(
                                        selectedStructure == name
                                            ? Color.resonanceGoldPrimary
                                            : .white.opacity(0.6)
                                    )

                                Text(name)
                                    .font(ResonanceTypography.sansCaption())
                                    .foregroundStyle(.white)

                                Text(description)
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.white.opacity(0.5))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 150)
                            .glassPanel(cornerRadius: 14)
                        }
                        .accessibilityLabel("\(name): \(description)")
                    }
                }
                .padding(.horizontal, 20)
            }

            #if os(visionOS)
            // RealityKit content for selected structure
            if let selected = selectedStructure {
                RealityView { content in
                    // Placeholder geometry representing the architectural structure
                    let base = ModelEntity(
                        mesh: .generateBox(width: 0.3, height: 0.4, depth: 0.3, cornerRadius: 0.02),
                        materials: [SimpleMaterial(
                            color: .init(Color.resonanceGreen700),
                            isMetallic: false
                        )]
                    )
                    base.position = [0, 0, -1]
                    content.add(base)

                    // Gold accent element
                    let accent = ModelEntity(
                        mesh: .generateSphere(radius: 0.03),
                        materials: [SimpleMaterial(
                            color: .init(Color.resonanceGoldPrimary),
                            isMetallic: true
                        )]
                    )
                    accent.position = [0, 0.25, -1]
                    content.add(accent)
                }
                .frame(height: 300)
                .accessibilityLabel("Three-dimensional model of \(selected)")
            }
            #else
            // Fallback for non-visionOS previews
            if let selected = selectedStructure {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.resonanceGreen800.opacity(0.3))
                        .frame(height: 200)

                    VStack {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 48))
                            .foregroundStyle(Color.resonanceGoldPrimary)
                        Text("3D View: \(selected)")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.6))
                        Text("Available on Apple Vision Pro")
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
                .padding(.horizontal, 20)
            }
            #endif
        }
    }
}

// MARK: - Vision Learn View

struct VisionLearnView: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Spatial Learning")
                        .font(ResonanceTypography.serifDisplay())
                        .foregroundStyle(.white)
                    Text("Interactive exercises in your space")
                        .font(ResonanceTypography.sansBody())
                        .foregroundStyle(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ResonanceDivider()

                // Spatial exercises
                Button {
                    openWindow(id: "quadrant-model")
                } label: {
                    HStack {
                        Image(systemName: "cube.transparent")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.resonanceGoldPrimary)
                        VStack(alignment: .leading) {
                            Text("Explore the Four Quadrants in 3D")
                                .font(ResonanceTypography.sansHeadline())
                                .foregroundStyle(.white)
                            Text("Interact with a spatial model of the AQAL framework")
                                .font(ResonanceTypography.sansCaption())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .glassPanel(cornerRadius: 16)
                }

                QuadrantMappingCard(title: "Map your experience across the four quadrants")

                ReflectionQuestionCard(
                    question: "How does spatial awareness change your reading experience?",
                    prompt: "Notice the difference between reading on a flat screen and reading in spatial context."
                )

                SomaticPracticeCard(
                    title: "Spatial Attunement in Mixed Reality",
                    instruction: "With your environment visible around you, expand your awareness to hold both the virtual and physical space simultaneously.",
                    durationSeconds: 180
                )
            }
            .padding(32)
        }
        .resonanceBackground()
    }
}

// MARK: - Vision Coach View

struct VisionCoachView: View {
    var body: some View {
        HStack(spacing: 0) {
            // Coach avatar area
            VStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.resonanceGreen600, Color.resonanceGreen900],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .breathingAnimation(duration: 5)

                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.resonanceGoldPrimary)
                }

                Text("Integral Coach")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)

                Text("Spatial Presence Mode")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .padding(.top, 2)

                Spacer()

                Text("On Vision Pro, the coach avatar appears\nas a spatial presence in your shared space.")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(20)
            }
            .frame(width: 250)
            .padding(.top, 40)
            .accessibilityLabel("Coach avatar in shared space")

            Divider()

            // Chat interface
            CoachTutorView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct LuminousVisionApp_Previews: PreviewProvider {
    static var previews: some View {
        VisionMainView()
            .environmentObject(VisionAppState())
            .previewDisplayName("Vision Main")

        QuadrantModelView()
            .environmentObject(VisionAppState())
            .previewDisplayName("Quadrant Model")
            .preferredColorScheme(.dark)
            .frame(width: 500, height: 600)
    }
}
#endif
