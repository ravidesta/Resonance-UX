// MARK: - Rich Visual Components — Luminous Journey™
// Spiral visualizations, developmental landscapes, body maps, season timelines,
// animated order transitions, progress rings, and organic blob generators.
// "Every data visualization should feel like looking at a living thing."

import SwiftUI

// MARK: - Developmental Spiral Visualization (Full Interactive)

struct DevelopmentalSpiralView: View {
    let assessments: [DevelopmentalAssessment.DomainAssessment]
    let currentSeason: SomaticSeason?
    @EnvironmentObject var theme: ThemeManager
    @State private var rotationAngle: Double = 0
    @State private var selectedOrder: DevelopmentalOrder?
    @State private var pulseScale: CGFloat = 1.0
    @State private var showLabels = true

    var body: some View {
        ZStack {
            // Ambient glow behind spiral
            ForEach(DevelopmentalOrder.allCases) { order in
                let angle = angleForOrder(order)
                let radius = radiusForOrder(order)
                Circle()
                    .fill((theme.orderColors[order] ?? theme.accent).opacity(0.08))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                    .offset(
                        x: cos(angle) * radius,
                        y: sin(angle) * radius
                    )
            }

            // Spiral path
            SpiralPath()
                .stroke(
                    LinearGradient(
                        colors: DevelopmentalOrder.allCases.map { theme.orderColors[$0] ?? theme.accent },
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    ),
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
                .frame(width: 280, height: 280)
                .opacity(0.4)

            // Order nodes
            ForEach(DevelopmentalOrder.allCases) { order in
                let angle = angleForOrder(order)
                let radius = radiusForOrder(order)
                let isActive = assessments.contains { $0.primaryOrder == order }
                let isSelected = selectedOrder == order

                OrderNode(
                    order: order,
                    isActive: isActive,
                    isSelected: isSelected,
                    showLabel: showLabels,
                    domainCount: assessments.filter { $0.primaryOrder == order }.count
                )
                .offset(
                    x: cos(angle) * radius,
                    y: sin(angle) * radius
                )
                .scaleEffect(isSelected ? 1.15 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                .onTapGesture { selectedOrder = selectedOrder == order ? nil : order }
            }

            // Connection lines between active orders
            ForEach(Array(assessments.enumerated()), id: \.offset) { index, assessment in
                if index < assessments.count - 1 {
                    let from = assessment.primaryOrder
                    let to = assessments[index + 1].primaryOrder
                    let fromAngle = angleForOrder(from)
                    let toAngle = angleForOrder(to)
                    let fromRadius = radiusForOrder(from)
                    let toRadius = radiusForOrder(to)

                    Path { path in
                        path.move(to: CGPoint(
                            x: 140 + cos(fromAngle) * fromRadius,
                            y: 140 + sin(fromAngle) * fromRadius
                        ))
                        path.addLine(to: CGPoint(
                            x: 140 + cos(toAngle) * toRadius,
                            y: 140 + sin(toAngle) * toRadius
                        ))
                    }
                    .stroke(theme.goldPrimary.opacity(0.2), lineWidth: 1)
                }
            }

            // Center: current season indicator
            if let season = currentSeason {
                VStack(spacing: 4) {
                    Circle()
                        .fill(theme.seasonColors[season] ?? theme.accent)
                        .frame(width: 32, height: 32)
                        .scaleEffect(pulseScale)
                        .overlay(
                            Image(systemName: seasonIcon(season))
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        )
                    Text(season.rawValue)
                        .font(.custom("Manrope", size: 10))
                        .foregroundColor(theme.textSecondary)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        pulseScale = 1.12
                    }
                }
            }
        }
        .frame(width: 280, height: 280)

        // Selected order detail
        if let order = selectedOrder {
            OrderDetailCard(order: order, domains: assessments.filter { $0.primaryOrder == order })
                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity))
        }
    }

    private func angleForOrder(_ order: DevelopmentalOrder) -> Double {
        let base = -Double.pi / 2 // Start from top
        let step = (2 * Double.pi) / 5.0
        return base + Double(order.rawValue - 1) * step + rotationAngle
    }

    private func radiusForOrder(_ order: DevelopmentalOrder) -> Double {
        return 40 + Double(order.rawValue) * 22
    }

    private func seasonIcon(_ season: SomaticSeason) -> String {
        switch season {
        case .compression: return "arrow.down.to.line"
        case .trembling:   return "waveform"
        case .emptiness:   return "circle.dashed"
        case .emergence:   return "leaf"
        case .integration: return "infinity"
        }
    }
}

struct OrderNode: View {
    let order: DevelopmentalOrder
    let isActive: Bool
    let isSelected: Bool
    let showLabel: Bool
    let domainCount: Int
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer glow ring
                if isActive {
                    Circle()
                        .fill((theme.orderColors[order] ?? theme.accent).opacity(0.15))
                        .frame(width: 52, height: 52)
                }

                // Main node
                Circle()
                    .fill(isActive
                        ? (theme.orderColors[order] ?? theme.accent)
                        : theme.textMuted.opacity(0.2))
                    .frame(width: isActive ? 36 : 24, height: isActive ? 36 : 24)
                    .overlay(
                        Group {
                            if isActive && domainCount > 0 {
                                Text("\(domainCount)")
                                    .font(.custom("Manrope", size: 12).weight(.bold))
                                    .foregroundColor(.white)
                            }
                        }
                    )

                // Selection ring
                if isSelected {
                    Circle()
                        .stroke(theme.goldPrimary, lineWidth: 2)
                        .frame(width: 44, height: 44)
                }
            }

            if showLabel {
                Text(order.name.components(separatedBy: " ").first ?? "")
                    .font(.custom("Manrope", size: 9))
                    .foregroundColor(isActive ? theme.text : theme.textMuted)
            }
        }
    }
}

struct OrderDetailCard: View {
    let order: DevelopmentalOrder
    let domains: [DevelopmentalAssessment.DomainAssessment]
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(theme.orderColors[order] ?? theme.accent)
                    .frame(width: 16, height: 16)
                Text(order.name)
                    .font(.custom("Cormorant Garamond", size: 22))
                    .foregroundColor(theme.text)
            }

            Text(order.description)
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.textSecondary)
                .lineSpacing(3)

            // Gifts
            HStack(spacing: 6) {
                ForEach(order.gifts, id: \.self) { gift in
                    Text(gift)
                        .font(.custom("Manrope", size: 11))
                        .foregroundColor(theme.goldPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(theme.goldPrimary.opacity(0.08)))
                }
            }

            // Active domains
            if !domains.isEmpty {
                Text("Active in:")
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(theme.textMuted)
                ForEach(domains) { domain in
                    HStack(spacing: 6) {
                        Circle().fill(theme.accent).frame(width: 6, height: 6)
                        Text(domain.domain.rawValue)
                            .font(.custom("Manrope", size: 13))
                            .foregroundColor(theme.text)
                        if let edge = domain.growingEdge {
                            Text("· \(edge)")
                                .font(.custom("Manrope", size: 12))
                                .foregroundColor(theme.textSecondary)
                        }
                    }
                }
            }

            // Shadow
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "eye")
                    .font(.system(size: 12))
                    .foregroundColor(theme.textMuted)
                Text("Shadow: \(order.shadow)")
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(theme.textMuted)
                    .italic()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke((theme.orderColors[order] ?? theme.accent).opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Spiral Path Shape

struct SpiralPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let turns: Double = 2.5
        let maxRadius = min(rect.width, rect.height) / 2

        for i in stride(from: 0.0, to: turns * 2 * .pi, by: 0.05) {
            let radius = (i / (turns * 2 * .pi)) * maxRadius
            let x = center.x + cos(i - .pi / 2) * radius
            let y = center.y + sin(i - .pi / 2) * radius
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}

// MARK: - Interactive Body Map

struct InteractiveBodyMap: View {
    @Binding var selectedLocations: [JournalEntry.BodyLocation]
    @EnvironmentObject var theme: ThemeManager
    @State private var activeArea: String?
    @State private var showIntensityPicker = false
    @State private var currentSensation: String = ""

    let bodyAreas: [(String, CGPoint, CGSize)] = [
        ("Head",       CGPoint(x: 0.5,  y: 0.08), CGSize(width: 60, height: 60)),
        ("Jaw",        CGPoint(x: 0.5,  y: 0.14), CGSize(width: 40, height: 25)),
        ("Throat",     CGPoint(x: 0.5,  y: 0.19), CGSize(width: 35, height: 25)),
        ("Shoulders",  CGPoint(x: 0.5,  y: 0.24), CGSize(width: 120, height: 30)),
        ("Chest",      CGPoint(x: 0.5,  y: 0.33), CGSize(width: 80, height: 60)),
        ("Heart",      CGPoint(x: 0.45, y: 0.33), CGSize(width: 40, height: 40)),
        ("Upper Back", CGPoint(x: 0.5,  y: 0.30), CGSize(width: 80, height: 40)),
        ("Belly",      CGPoint(x: 0.5,  y: 0.45), CGSize(width: 70, height: 60)),
        ("Solar Plexus", CGPoint(x: 0.5, y: 0.40), CGSize(width: 50, height: 30)),
        ("Pelvis",     CGPoint(x: 0.5,  y: 0.55), CGSize(width: 80, height: 40)),
        ("Hands",      CGPoint(x: 0.5,  y: 0.50), CGSize(width: 120, height: 30)),
        ("Thighs",     CGPoint(x: 0.5,  y: 0.65), CGSize(width: 80, height: 50)),
        ("Knees",      CGPoint(x: 0.5,  y: 0.75), CGSize(width: 60, height: 30)),
        ("Feet",       CGPoint(x: 0.5,  y: 0.92), CGSize(width: 60, height: 30)),
    ]

    let sensations = [
        "Tightness", "Warmth", "Tingling", "Heaviness", "Lightness",
        "Trembling", "Numbness", "Pulsing", "Pressure", "Openness",
        "Buzzing", "Aching", "Flowing", "Frozen", "Expansive"
    ]

    var body: some View {
        VStack(spacing: 16) {
            Text("Somatic Body Map")
                .font(.custom("Manrope", size: 13).weight(.semibold))
                .foregroundColor(theme.goldPrimary)
                .textCase(.uppercase)
                .tracking(0.5)

            Text("Tap to mark where you notice sensation")
                .font(.custom("Manrope", size: 13))
                .foregroundColor(theme.textSecondary)

            // Body silhouette with interactive zones
            GeometryReader { geo in
                ZStack {
                    // Body outline silhouette
                    BodySilhouette()
                        .fill(theme.forestBase.opacity(0.04))
                        .overlay(
                            BodySilhouette()
                                .stroke(theme.forestBase.opacity(0.12), lineWidth: 1)
                        )

                    // Interactive zones
                    ForEach(bodyAreas, id: \.0) { area, position, size in
                        let isSelected = selectedLocations.contains { $0.area == area }
                        let isActive = activeArea == area
                        let location = selectedLocations.first { $0.area == area }

                        ZStack {
                            // Glow for selected areas
                            if isSelected, let loc = location {
                                Circle()
                                    .fill(intensityColor(loc.intensity).opacity(0.3))
                                    .frame(width: size.width * 1.5, height: size.height * 1.5)
                                    .blur(radius: 10)
                            }

                            // Tap zone
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected
                                    ? intensityColor(location?.intensity ?? 0.5).opacity(0.15)
                                    : Color.clear)
                                .frame(width: size.width, height: size.height)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isActive
                                            ? theme.goldPrimary
                                            : (isSelected ? intensityColor(location?.intensity ?? 0.5).opacity(0.3) : Color.clear),
                                            lineWidth: isActive ? 2 : 1)
                                )

                            // Label
                            if isSelected || isActive {
                                VStack(spacing: 2) {
                                    Text(area)
                                        .font(.custom("Manrope", size: 10).weight(.semibold))
                                        .foregroundColor(theme.text)
                                    if let loc = location {
                                        Text(loc.sensation)
                                            .font(.custom("Manrope", size: 9))
                                            .foregroundColor(theme.textSecondary)
                                    }
                                }
                            }
                        }
                        .position(
                            x: position.x * geo.size.width,
                            y: position.y * geo.size.height
                        )
                        .onTapGesture {
                            activeArea = area
                            showIntensityPicker = true
                        }
                    }
                }
            }
            .frame(height: 420)

            // Active selections
            if !selectedLocations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedLocations, id: \.area) { location in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(intensityColor(location.intensity))
                                    .frame(width: 10, height: 10)
                                Text("\(location.area): \(location.sensation)")
                                    .font(.custom("Manrope", size: 12))
                                    .foregroundColor(theme.text)
                                Button(action: {
                                    selectedLocations.removeAll { $0.area == location.area }
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 10))
                                        .foregroundColor(theme.textMuted)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(theme.forestBase.opacity(0.06)))
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showIntensityPicker) {
            if let area = activeArea {
                SensationPicker(
                    area: area,
                    sensations: sensations,
                    onSelect: { sensation, intensity in
                        selectedLocations.removeAll { $0.area == area }
                        selectedLocations.append(JournalEntry.BodyLocation(
                            area: area, sensation: sensation, intensity: intensity
                        ))
                        showIntensityPicker = false
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    private func intensityColor(_ intensity: Double) -> Color {
        if intensity < 0.3 { return Color(hex: "5A8AB0") }       // Mild — blue
        if intensity < 0.6 { return Color(hex: "C5A059") }       // Moderate — gold
        if intensity < 0.8 { return Color(hex: "B07A5A") }       // Strong — amber
        return Color(hex: "C45A5A")                                // Intense — warm red
    }
}

struct SensationPicker: View {
    let area: String
    let sensations: [String]
    let onSelect: (String, Double) -> Void
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedSensation: String?
    @State private var intensity: Double = 0.5

    var body: some View {
        VStack(spacing: 20) {
            Text(area)
                .font(.custom("Cormorant Garamond", size: 24))
                .foregroundColor(theme.text)
            Text("What sensation do you notice here?")
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.textSecondary)

            // Sensation grid
            FlowLayout(spacing: 8) {
                ForEach(sensations, id: \.self) { sensation in
                    Button(action: { selectedSensation = sensation }) {
                        Text(sensation)
                            .font(.custom("Manrope", size: 13))
                            .foregroundColor(selectedSensation == sensation ? theme.cream : theme.text)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selectedSensation == sensation ? theme.forestBase : theme.forestBase.opacity(0.06))
                            )
                    }
                }
            }

            // Intensity slider
            VStack(spacing: 8) {
                Text("Intensity")
                    .font(.custom("Manrope", size: 12))
                    .foregroundColor(theme.textSecondary)
                HStack {
                    Text("Subtle")
                        .font(.custom("Manrope", size: 11))
                        .foregroundColor(theme.textMuted)
                    Slider(value: $intensity, in: 0...1)
                        .tint(theme.goldPrimary)
                    Text("Intense")
                        .font(.custom("Manrope", size: 11))
                        .foregroundColor(theme.textMuted)
                }
            }

            Button(action: {
                if let sensation = selectedSensation {
                    onSelect(sensation, intensity)
                }
            }) {
                Text("Add")
                    .font(.custom("Manrope", size: 15).weight(.semibold))
                    .foregroundColor(theme.cream)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(theme.forestBase)
                    .clipShape(Capsule())
            }
            .disabled(selectedSensation == nil)
        }
        .padding(24)
    }
}

// MARK: - Body Silhouette Shape

struct BodySilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Simplified human silhouette
        // Head
        path.addEllipse(in: CGRect(x: w * 0.38, y: h * 0.02, width: w * 0.24, height: h * 0.1))
        // Neck
        path.addRect(CGRect(x: w * 0.44, y: h * 0.11, width: w * 0.12, height: h * 0.04))
        // Torso
        path.addRoundedRect(in: CGRect(x: w * 0.3, y: h * 0.15, width: w * 0.4, height: h * 0.35), cornerSize: CGSize(width: 20, height: 20))
        // Left arm
        path.addRoundedRect(in: CGRect(x: w * 0.15, y: h * 0.18, width: w * 0.14, height: h * 0.28), cornerSize: CGSize(width: 10, height: 10))
        // Right arm
        path.addRoundedRect(in: CGRect(x: w * 0.71, y: h * 0.18, width: w * 0.14, height: h * 0.28), cornerSize: CGSize(width: 10, height: 10))
        // Left leg
        path.addRoundedRect(in: CGRect(x: w * 0.32, y: h * 0.5, width: w * 0.16, height: h * 0.42), cornerSize: CGSize(width: 10, height: 10))
        // Right leg
        path.addRoundedRect(in: CGRect(x: w * 0.52, y: h * 0.5, width: w * 0.16, height: h * 0.42), cornerSize: CGSize(width: 10, height: 10))

        return path
    }
}

// MARK: - Season Timeline

struct SeasonTimelineView: View {
    let entries: [(Date, SomaticSeason)]
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Season Timeline")
                .font(.custom("Manrope", size: 13).weight(.semibold))
                .foregroundColor(theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            GeometryReader { geo in
                let width = geo.size.width
                let segmentWidth = entries.count > 1 ? width / CGFloat(entries.count - 1) : width

                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 3)
                        .fill(theme.forestBase.opacity(0.06))
                        .frame(height: 6)

                    // Colored segments
                    HStack(spacing: 0) {
                        ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                            Rectangle()
                                .fill(theme.seasonColors[entry.1] ?? theme.accent)
                                .frame(width: segmentWidth, height: 6)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 3))

                    // Node dots
                    ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                        Circle()
                            .fill(theme.seasonColors[entry.1] ?? theme.accent)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(theme.surface, lineWidth: 2))
                            .offset(x: CGFloat(index) * segmentWidth - 7)
                    }
                }
                .frame(height: 14)

                // Labels
                HStack(spacing: 0) {
                    ForEach(Array(entries.enumerated()), id: \.offset) { index, entry in
                        VStack(spacing: 2) {
                            Text(entry.1.rawValue)
                                .font(.custom("Manrope", size: 9))
                                .foregroundColor(theme.textSecondary)
                            Text(entry.0.formatted(.dateTime.month(.abbreviated).day()))
                                .font(.custom("Manrope", size: 8))
                                .foregroundColor(theme.textMuted)
                        }
                        .frame(width: segmentWidth)
                    }
                }
                .offset(y: 20)
            }
            .frame(height: 50)
        }
    }
}

// MARK: - Progress Ring (Practice streaks, reading progress, etc.)

struct ProgressRing: View {
    let progress: Double      // 0.0 - 1.0
    let color: Color
    let lineWidth: CGFloat
    let size: CGFloat
    let label: String?
    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.12), lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.6), color],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Center label
            if let label = label {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))%")
                        .font(.custom("Manrope", size: size * 0.2).weight(.bold))
                    Text(label)
                        .font(.custom("Manrope", size: size * 0.08))
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Animated Organic Blob Generator

struct OrganicBlob: View {
    let color: Color
    let size: CGFloat
    @State private var phase: CGFloat = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                let baseRadius = size / 2 * 0.7
                var path = Path()

                let points = 120
                for i in 0..<points {
                    let angle = (Double(i) / Double(points)) * 2 * .pi
                    let noise1 = sin(angle * 3 + time * 0.4) * 0.12
                    let noise2 = cos(angle * 5 + time * 0.3) * 0.08
                    let noise3 = sin(angle * 7 + time * 0.2) * 0.05
                    let radius = baseRadius * (1 + noise1 + noise2 + noise3)

                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius

                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                path.closeSubpath()

                context.fill(path, with: .color(color))
            }
        }
        .frame(width: size, height: size)
        .blur(radius: size * 0.15)
    }
}

// MARK: - Developmental Landscape Chart (Radar/Spider)

struct DevelopmentalLandscapeChart: View {
    let assessments: [DevelopmentalAssessment.DomainAssessment]
    @EnvironmentObject var theme: ThemeManager

    private let domains = LifeDomain.allCases
    private let maxOrder: Double = 5

    var body: some View {
        VStack(spacing: 16) {
            Text("Developmental Landscape")
                .font(.custom("Manrope", size: 13).weight(.semibold))
                .foregroundColor(theme.textSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - 40

                ZStack {
                    // Grid rings
                    ForEach(1...5, id: \.self) { level in
                        RadarGridRing(
                            sides: domains.count,
                            radius: radius * CGFloat(level) / 5,
                            center: center
                        )
                        .stroke(theme.forestBase.opacity(0.06), lineWidth: 1)
                    }

                    // Axis lines
                    ForEach(Array(domains.enumerated()), id: \.offset) { index, _ in
                        let angle = angleForIndex(index, total: domains.count)
                        Path { path in
                            path.move(to: center)
                            path.addLine(to: CGPoint(
                                x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius
                            ))
                        }
                        .stroke(theme.forestBase.opacity(0.06), lineWidth: 1)
                    }

                    // Data polygon
                    RadarDataPolygon(
                        values: domains.map { domain in
                            let assessment = assessments.first { $0.domain == domain }
                            return Double(assessment?.primaryOrder.rawValue ?? 0) / maxOrder
                        },
                        center: center,
                        radius: radius
                    )
                    .fill(theme.goldPrimary.opacity(0.12))
                    .overlay(
                        RadarDataPolygon(
                            values: domains.map { domain in
                                let assessment = assessments.first { $0.domain == domain }
                                return Double(assessment?.primaryOrder.rawValue ?? 0) / maxOrder
                            },
                            center: center,
                            radius: radius
                        )
                        .stroke(theme.goldPrimary, lineWidth: 2)
                    )

                    // Data points
                    ForEach(Array(domains.enumerated()), id: \.offset) { index, domain in
                        let assessment = assessments.first { $0.domain == domain }
                        let value = Double(assessment?.primaryOrder.rawValue ?? 0) / maxOrder
                        let angle = angleForIndex(index, total: domains.count)
                        let pointRadius = radius * value

                        Circle()
                            .fill(theme.goldPrimary)
                            .frame(width: 8, height: 8)
                            .position(
                                x: center.x + cos(angle) * pointRadius,
                                y: center.y + sin(angle) * pointRadius
                            )
                    }

                    // Domain labels
                    ForEach(Array(domains.enumerated()), id: \.offset) { index, domain in
                        let angle = angleForIndex(index, total: domains.count)
                        Text(domain.rawValue)
                            .font(.custom("Manrope", size: 11))
                            .foregroundColor(theme.textSecondary)
                            .position(
                                x: center.x + cos(angle) * (radius + 28),
                                y: center.y + sin(angle) * (radius + 28)
                            )
                    }
                }
            }
            .frame(height: 280)
        }
    }

    private func angleForIndex(_ index: Int, total: Int) -> Double {
        let start = -Double.pi / 2
        return start + (Double(index) / Double(total)) * 2 * .pi
    }
}

struct RadarGridRing: Shape {
    let sides: Int
    let radius: CGFloat
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for i in 0...sides {
            let angle = -Double.pi / 2 + (Double(i) / Double(sides)) * 2 * .pi
            let point = CGPoint(
                x: center.x + cos(angle) * Double(radius),
                y: center.y + sin(angle) * Double(radius)
            )
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        return path
    }
}

struct RadarDataPolygon: Shape {
    let values: [Double]
    let center: CGPoint
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for (index, value) in values.enumerated() {
            let angle = -Double.pi / 2 + (Double(index) / Double(values.count)) * 2 * .pi
            let r = Double(radius) * value
            let point = CGPoint(x: Double(center.x) + cos(angle) * r, y: Double(center.y) + sin(angle) * r)
            if index == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}
