// EcosystemHubView.swift
// Luminous Integral Architecture™ — Ecosystem Hub & Community Dashboard
//
// Connects all Luminous Prosperity ecosystem apps: study groups, practice circles,
// community feed, cross-app navigation, profile, and network visualization.

import SwiftUI

// MARK: - Models

struct EcosystemApp: Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let color: Color
    let isInstalled: Bool

    init(id: String = UUID().uuidString, name: String, icon: String, description: String,
         color: Color = .resonanceGreen700, isInstalled: Bool = true) {
        self.id = id
        self.name = name
        self.icon = icon
        self.description = description
        self.color = color
        self.isInstalled = isInstalled
    }
}

struct StudyGroup: Identifiable {
    let id: String
    let name: String
    let memberCount: Int
    let nextSessionDate: Date?
    let currentChapter: String
    let isActive: Bool
}

struct PracticeCircle: Identifiable {
    let id: String
    let name: String
    let practiceType: String
    let memberCount: Int
    let frequency: String
}

struct CommunityPost: Identifiable {
    let id: String
    let authorName: String
    let authorInitials: String
    let content: String
    let timestamp: Date
    let likeCount: Int
    let replyCount: Int
    let postType: PostType

    enum PostType: String {
        case reflection, insight, question, practice
    }
}

struct DevelopmentMilestone: Identifiable {
    let id: String
    let title: String
    let description: String
    let date: Date
    let icon: String
    let category: String
}

// MARK: - Ecosystem Hub View Model

@MainActor
final class EcosystemHubViewModel: ObservableObject {
    @Published var selectedSection: HubSection = .dashboard
    @Published var showProfile = false

    enum HubSection: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case groups = "Groups"
        case community = "Community"
        case apps = "Apps"
        var id: String { rawValue }
    }

    let ecosystemApps: [EcosystemApp] = [
        EcosystemApp(name: "Luminous Reader", icon: "book.fill", description: "Interactive ebook experience", color: .resonanceGreen700, isInstalled: true),
        EcosystemApp(name: "Luminous Audio", icon: "headphones", description: "Audiobook player", color: .resonanceGoldPrimary, isInstalled: true),
        EcosystemApp(name: "Luminous Coach", icon: "sparkles", description: "AI-guided integral coaching", color: .resonanceGreen500, isInstalled: true),
        EcosystemApp(name: "Luminous Practice", icon: "figure.mind.and.body", description: "Somatic & meditation practices", color: .resonanceGreen400, isInstalled: false),
        EcosystemApp(name: "Luminous Journal", icon: "square.and.pencil", description: "Integral reflection journal", color: .resonanceGoldDark, isInstalled: false),
        EcosystemApp(name: "Luminous Community", icon: "person.3.fill", description: "Study groups & circles", color: .resonanceGreen600, isInstalled: true),
    ]

    let studyGroups: [StudyGroup] = [
        StudyGroup(id: "sg1", name: "Integral Beginners Circle", memberCount: 12, nextSessionDate: Calendar.current.date(byAdding: .day, value: 2, to: .now), currentChapter: "Chapter 2: Four Quadrants", isActive: true),
        StudyGroup(id: "sg2", name: "Advanced Practitioners", memberCount: 7, nextSessionDate: Calendar.current.date(byAdding: .day, value: 5, to: .now), currentChapter: "Chapter 6: Spatial Attunement", isActive: true),
        StudyGroup(id: "sg3", name: "ILP Weekly Check-in", memberCount: 15, nextSessionDate: nil, currentChapter: "Chapter 7: Integral Life Practice", isActive: false),
    ]

    let practiceCircles: [PracticeCircle] = [
        PracticeCircle(id: "pc1", name: "Morning Spatial Attunement", practiceType: "Somatic", memberCount: 23, frequency: "Daily"),
        PracticeCircle(id: "pc2", name: "Quadrant Journaling", practiceType: "Reflection", memberCount: 18, frequency: "3x/week"),
        PracticeCircle(id: "pc3", name: "Integral Meditation", practiceType: "Contemplative", memberCount: 31, frequency: "Daily"),
    ]

    let communityPosts: [CommunityPost] = [
        CommunityPost(id: "cp1", authorName: "Maya R.", authorInitials: "MR", content: "Just finished the Four Quadrants chapter. The exercise of mapping my current relationship challenge across all four quadrants was incredibly revealing. I could see patterns I had been blind to.", timestamp: Calendar.current.date(byAdding: .hour, value: -3, to: .now) ?? .now, likeCount: 14, replyCount: 5, postType: .insight),
        CommunityPost(id: "cp2", authorName: "David L.", authorInitials: "DL", content: "Has anyone else found that the Spatial Attunement practice changes how they experience architecture? I walk through buildings differently now.", timestamp: Calendar.current.date(byAdding: .hour, value: -8, to: .now) ?? .now, likeCount: 22, replyCount: 8, postType: .question),
        CommunityPost(id: "cp3", authorName: "Aisha K.", authorInitials: "AK", content: "Day 30 of the morning attunement practice. Something shifted today — I felt the space between my thoughts as a kind of architecture. Beautiful.", timestamp: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now, likeCount: 31, replyCount: 12, postType: .practice),
    ]

    let milestones: [DevelopmentMilestone] = [
        DevelopmentMilestone(id: "m1", title: "First Integral Map", description: "Completed your first four-quadrant analysis", date: Calendar.current.date(byAdding: .day, value: -14, to: .now) ?? .now, icon: "map.fill", category: "Cognitive"),
        DevelopmentMilestone(id: "m2", title: "Somatic Explorer", description: "Completed 7 consecutive days of practice", date: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now, icon: "figure.mind.and.body", category: "Somatic"),
        DevelopmentMilestone(id: "m3", title: "Community Contributor", description: "Shared your first reflection", date: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now, icon: "person.2.fill", category: "Interpersonal"),
    ]

    var overallProgress: Double { 0.35 }
    var readingStreak: Int { 12 }
    var practiceStreak: Int { 7 }
}

// MARK: - Ecosystem Hub View

struct EcosystemHubView: View {
    @StateObject private var viewModel = EcosystemHubViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color.resonanceBgBaseDark
                .ignoresSafeArea()
            OrganicBlobView()
                .ignoresSafeArea()
                .opacity(0.4)

            #if os(watchOS)
            watchHubLayout
            #else
            fullHubLayout
            #endif
        }
    }

    // MARK: Full Layout

    #if !os(watchOS)
    private var fullHubLayout: some View {
        VStack(spacing: 0) {
            hubHeader

            // Section picker
            Picker("Section", selection: $viewModel.selectedSection) {
                ForEach(EcosystemHubViewModel.HubSection.allCases) { section in
                    Text(section.rawValue).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)

            ScrollView {
                switch viewModel.selectedSection {
                case .dashboard: dashboardSection
                case .groups:    groupsSection
                case .community: communitySection
                case .apps:      appsSection
                }
            }
        }
        .sheet(isPresented: $viewModel.showProfile) {
            profileSheet
        }
    }
    #endif

    // MARK: Watch Layout

    #if os(watchOS)
    private var watchHubLayout: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Luminous Hub")
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)

                // Quick stats
                HStack {
                    VStack {
                        Text("\(viewModel.readingStreak)")
                            .font(ResonanceTypography.sansTitle())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                        Text("Day streak")
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Spacer()
                    ResonanceProgressRing(progress: viewModel.overallProgress, size: 36, lineWidth: 3)
                }

                // Active group
                if let group = viewModel.studyGroups.first(where: { $0.isActive }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(group.name)
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white)
                        Text(group.currentChapter)
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.resonanceGreen800.opacity(0.6))
                    )
                }
            }
            .padding(8)
        }
    }
    #endif

    // MARK: Hub Header

    #if !os(watchOS)
    private var hubHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Luminous Ecosystem")
                    .font(ResonanceTypography.sansTitle())
                    .foregroundStyle(.white)
                Text("Your integral development hub")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Button {
                viewModel.showProfile = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.resonanceGreen600, Color.resonanceGreen800],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Text("JD")
                        .font(ResonanceTypography.sansCaption())
                        .foregroundStyle(Color.resonanceGoldLight)
                }
            }
            .accessibilityLabel("Profile")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
    #endif

    // MARK: Dashboard Section

    #if !os(watchOS)
    private var dashboardSection: some View {
        VStack(spacing: 20) {
            // Welcome card
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome back")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Your Integral Journey")
                            .font(ResonanceTypography.serifTitle())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    ResonanceProgressRing(progress: viewModel.overallProgress, size: 56, lineWidth: 4)
                }

                HStack(spacing: 20) {
                    statCard(value: "\(viewModel.readingStreak)", label: "Day Streak", icon: "flame.fill")
                    statCard(value: "\(viewModel.practiceStreak)", label: "Practice Days", icon: "leaf.fill")
                    statCard(value: "\(Int(viewModel.overallProgress * 100))%", label: "Progress", icon: "chart.line.uptrend.xyaxis")
                }
            }
            .glassPanel(cornerRadius: 20)
            .padding(.horizontal, 20)

            // Continue where you left off
            VStack(alignment: .leading, spacing: 12) {
                Text("CONTINUE")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .tracking(2)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        continueCard(title: "Reading", subtitle: "Chapter 2: Four Quadrants", progress: 0.45, icon: "book.fill", color: .resonanceGreen700)
                        continueCard(title: "Audiobook", subtitle: "Chapter 1: Integral Vision", progress: 0.78, icon: "headphones", color: .resonanceGoldPrimary)
                        continueCard(title: "Coaching", subtitle: "Quadrant mapping session", progress: 0.3, icon: "sparkles", color: .resonanceGreen500)
                    }
                    .padding(.horizontal, 20)
                }
            }

            // Network visualization
            networkVisualization
                .padding(.horizontal, 20)

            // Recent milestones
            VStack(alignment: .leading, spacing: 12) {
                Text("RECENT MILESTONES")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .tracking(2)
                    .padding(.horizontal, 20)

                ForEach(viewModel.milestones) { milestone in
                    milestoneRow(milestone)
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 16)
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.resonanceGoldPrimary)
            Text(value)
                .font(ResonanceTypography.sansTitle())
                .foregroundStyle(.white)
            Text(label)
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func continueCard(title: String, subtitle: String, progress: Double, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(title)
                .font(ResonanceTypography.sansHeadline())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(ResonanceTypography.sansCaption2())
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)

            ResonanceProgressBar(progress: progress, height: 3)
        }
        .frame(width: 160)
        .glassPanel(cornerRadius: 14)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(subtitle), \(Int(progress * 100)) percent complete")
    }

    private var networkVisualization: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("YOUR NETWORK")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .tracking(2)
                Spacer()
                Text("42 connections")
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
            }

            // Network graph visualization
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let nodeCount = 12
                var nodes: [CGPoint] = [center]

                // Generate node positions in concentric rings
                for i in 1..<nodeCount {
                    let ring = i <= 4 ? 1 : 2
                    let countInRing = ring == 1 ? 4 : 7
                    let indexInRing = ring == 1 ? i - 1 : i - 5
                    let angle = (CGFloat(indexInRing) / CGFloat(countInRing)) * .pi * 2 - .pi / 2
                    let radius: CGFloat = CGFloat(ring) * min(size.width, size.height) * 0.18
                    nodes.append(CGPoint(x: center.x + cos(angle) * radius,
                                         y: center.y + sin(angle) * radius))
                }

                // Draw connections
                for i in 1..<nodes.count {
                    var linePath = Path()
                    linePath.move(to: center)
                    linePath.addLine(to: nodes[i])
                    context.stroke(linePath, with: .color(Color.resonanceGoldPrimary.opacity(0.15)), lineWidth: 1)
                }

                // Draw some cross-connections
                for i in 1..<min(5, nodes.count) {
                    let j = (i % (nodes.count - 1)) + 1
                    var crossPath = Path()
                    crossPath.move(to: nodes[i])
                    crossPath.addLine(to: nodes[j])
                    context.stroke(crossPath, with: .color(Color.resonanceGreen500.opacity(0.1)), lineWidth: 0.5)
                }

                // Draw nodes
                for (i, node) in nodes.enumerated() {
                    let nodeSize: CGFloat = i == 0 ? 14 : 8
                    let nodeColor = i == 0 ? Color.resonanceGoldPrimary : Color.resonanceGreen500
                    let rect = CGRect(x: node.x - nodeSize / 2, y: node.y - nodeSize / 2, width: nodeSize, height: nodeSize)
                    context.fill(Path(ellipseIn: rect), with: .color(nodeColor.opacity(0.8)))
                    let glowRect = rect.insetBy(dx: -2, dy: -2)
                    context.fill(Path(ellipseIn: glowRect), with: .color(nodeColor.opacity(0.15)))
                }
            }
            .frame(height: 160)
        }
        .glassPanel(cornerRadius: 16)
        .accessibilityLabel("Network visualization showing 42 connections")
    }

    private func milestoneRow(_ milestone: DevelopmentMilestone) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.resonanceGoldPrimary.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: milestone.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(ResonanceTypography.sansHeadline())
                    .foregroundStyle(.white)
                Text(milestone.description)
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(milestone.date, style: .date)
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(.white.opacity(0.3))
                Text(milestone.category)
                    .font(ResonanceTypography.sansCaption2())
                    .foregroundStyle(Color.resonanceGoldPrimary)
            }
        }
        .glassPanel(cornerRadius: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(milestone.title): \(milestone.description)")
    }
    #endif

    // MARK: Groups Section

    #if !os(watchOS)
    private var groupsSection: some View {
        VStack(spacing: 20) {
            // Study groups
            VStack(alignment: .leading, spacing: 12) {
                Text("STUDY GROUPS")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .tracking(2)
                    .padding(.horizontal, 20)

                ForEach(viewModel.studyGroups) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(group.name)
                                .font(ResonanceTypography.sansHeadline())
                                .foregroundStyle(.white)
                            Spacer()
                            if group.isActive {
                                Text("Active")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(Color.resonanceGreen400)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.resonanceGreen400.opacity(0.15)))
                            }
                        }

                        Text(group.currentChapter)
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.6))

                        HStack {
                            Image(systemName: "person.2")
                                .font(.system(size: 12))
                            Text("\(group.memberCount) members")
                                .font(ResonanceTypography.sansCaption2())
                            Spacer()
                            if let nextDate = group.nextSessionDate {
                                Image(systemName: "calendar")
                                    .font(.system(size: 12))
                                Text(nextDate, style: .date)
                                    .font(ResonanceTypography.sansCaption2())
                            }
                        }
                        .foregroundStyle(.white.opacity(0.4))
                    }
                    .glassPanel(cornerRadius: 14)
                    .padding(.horizontal, 20)
                }
            }

            // Practice circles
            VStack(alignment: .leading, spacing: 12) {
                Text("PRACTICE CIRCLES")
                    .font(ResonanceTypography.sansCaption())
                    .foregroundStyle(Color.resonanceGoldPrimary)
                    .tracking(2)
                    .padding(.horizontal, 20)

                ForEach(viewModel.practiceCircles) { circle in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.resonanceGreen700.opacity(0.4))
                                .frame(width: 44, height: 44)
                            Image(systemName: "figure.mind.and.body")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.resonanceGoldPrimary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(circle.name)
                                .font(ResonanceTypography.sansHeadline())
                                .foregroundStyle(.white)
                            HStack(spacing: 8) {
                                Text(circle.practiceType)
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(Color.resonanceGoldPrimary)
                                Text("\(circle.memberCount) practitioners")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.white.opacity(0.4))
                                Text(circle.frequency)
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }

                        Spacer()

                        Button("Join") {}
                            .buttonStyle(.resonanceSecondary)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 16)
    }
    #endif

    // MARK: Community Section

    #if !os(watchOS)
    private var communitySection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.communityPosts) { post in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        // Author avatar
                        ZStack {
                            Circle()
                                .fill(Color.resonanceGreen700)
                                .frame(width: 36, height: 36)
                            Text(post.authorInitials)
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(Color.resonanceGoldLight)
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(post.authorName)
                                .font(ResonanceTypography.sansHeadline())
                                .foregroundStyle(.white)
                            Text(post.timestamp, style: .relative)
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(.white.opacity(0.4))
                        }

                        Spacer()

                        Text(post.postType.rawValue.capitalized)
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.resonanceGoldPrimary.opacity(0.1)))
                    }

                    Text(post.content)
                        .font(ResonanceTypography.sansBody(size: 15))
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 20) {
                        Button {} label: {
                            HStack(spacing: 4) {
                                Image(systemName: "heart")
                                Text("\(post.likeCount)")
                            }
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.5))
                        }
                        .accessibilityLabel("\(post.likeCount) likes")

                        Button {} label: {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                Text("\(post.replyCount)")
                            }
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white.opacity(0.5))
                        }
                        .accessibilityLabel("\(post.replyCount) replies")

                        Spacer()

                        Button {} label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .accessibilityLabel("Share")
                    }
                }
                .glassPanel(cornerRadius: 16)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }
    #endif

    // MARK: Apps Section

    #if !os(watchOS)
    private var appsSection: some View {
        VStack(spacing: 12) {
            Text("LUMINOUS PROSPERITY ECOSYSTEM")
                .font(ResonanceTypography.sansCaption())
                .foregroundStyle(Color.resonanceGoldPrimary)
                .tracking(2)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.ecosystemApps) { app in
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [app.color, app.color.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)

                            Image(systemName: app.icon)
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }

                        Text(app.name)
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.white)
                            .lineLimit(1)

                        Text(app.description)
                            .font(ResonanceTypography.sansCaption2())
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)

                        if app.isInstalled {
                            Text("Open")
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(Color.resonanceGoldPrimary)
                        } else {
                            Text("Get")
                                .font(ResonanceTypography.sansCaption2())
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                                .background(Capsule().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .glassPanel(cornerRadius: 16)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(app.name): \(app.description), \(app.isInstalled ? "installed" : "not installed")")
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 16)
    }
    #endif

    // MARK: Profile Sheet

    #if !os(watchOS)
    private var profileSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Avatar and info
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.resonanceGreen600, Color.resonanceGreen800],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text("JD")
                                .font(ResonanceTypography.sansTitle())
                                .foregroundStyle(Color.resonanceGoldLight)
                        }

                        Text("Jamie Doe")
                            .font(ResonanceTypography.sansTitle())
                        Text("Integral Explorer")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(.secondary)
                    }

                    ResonanceDivider()

                    // Journey stats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DEVELOPMENT JOURNEY")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .tracking(2)

                        HStack(spacing: 20) {
                            VStack {
                                Text("\(viewModel.readingStreak)")
                                    .font(ResonanceTypography.sansTitle())
                                Text("Day Streak")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Text("3")
                                    .font(ResonanceTypography.sansTitle())
                                Text("Milestones")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)

                            VStack {
                                Text("42")
                                    .font(ResonanceTypography.sansTitle())
                                Text("Connections")
                                    .font(ResonanceTypography.sansCaption2())
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(20)

                    // Milestones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MILESTONES")
                            .font(ResonanceTypography.sansCaption())
                            .foregroundStyle(Color.resonanceGoldPrimary)
                            .tracking(2)

                        ForEach(viewModel.milestones) { milestone in
                            HStack(spacing: 12) {
                                Image(systemName: milestone.icon)
                                    .foregroundStyle(Color.resonanceGoldPrimary)
                                VStack(alignment: .leading) {
                                    Text(milestone.title)
                                        .font(ResonanceTypography.sansBody())
                                    Text(milestone.date, style: .date)
                                        .font(ResonanceTypography.sansCaption2())
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { viewModel.showProfile = false }
                }
            }
        }
    }
    #endif
}

// MARK: - Preview

#if DEBUG
struct EcosystemHubView_Previews: PreviewProvider {
    static var previews: some View {
        EcosystemHubView()
            .preferredColorScheme(.dark)
    }
}
#endif
