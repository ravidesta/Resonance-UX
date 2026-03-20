// LargeRadarView.swift
// Luminous Cognitive Styles™ — iPad
// Full-screen radar chart with detailed annotations and Apple Pencil support

import SwiftUI

struct LargeRadarView: View {
    let profile: CognitiveProfile
    @State private var selectedDimension: CognitiveDimension?
    @State private var annotations: [UUID: AnnotationNote] = [:]
    @State private var isAnnotating = false
    @State private var showAnnotationInput = false
    @State private var newAnnotationText = ""
    @State private var tapLocation: CGPoint = .zero

    var body: some View {
        GeometryReader { geo in
            let chartSize = min(geo.size.width, geo.size.height) * 0.65

            ZStack {
                // Background
                LCSTheme.deepNavy.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top bar with profile name
                    HStack {
                        VStack(alignment: .leading) {
                            Text(profile.profileTypeName)
                                .font(.title.weight(.bold))
                                .foregroundColor(LCSTheme.textPrimary)
                            Text(profile.profileSummary)
                                .font(.subheadline)
                                .foregroundColor(LCSTheme.textSecondary)
                        }
                        Spacer()

                        // Annotation toggle
                        Button {
                            isAnnotating.toggle()
                        } label: {
                            Label(
                                isAnnotating ? "Done Annotating" : "Annotate",
                                systemImage: isAnnotating ? "pencil.circle.fill" : "pencil.circle"
                            )
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(isAnnotating ? LCSTheme.goldAccent : LCSTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, LCSTheme.Spacing.xl)
                    .padding(.top, LCSTheme.Spacing.md)

                    Spacer()

                    // Large radar chart
                    ZStack {
                        RadarChartView(
                            profile: profile,
                            showLabels: true,
                            showAdaptiveRange: true,
                            animated: true,
                            size: chartSize
                        )

                        // Annotation dots
                        ForEach(Array(annotations.values)) { note in
                            AnnotationDotView(note: note) {
                                annotations.removeValue(forKey: note.id)
                            }
                            .position(note.position)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        if isAnnotating {
                            tapLocation = location
                            showAnnotationInput = true
                        }
                    }
                    .simultaneousGesture(
                        // Detect dimension taps from radar labels
                        TapGesture().onEnded { _ in }
                    )

                    Spacer()

                    // Bottom detail strip
                    bottomDetailStrip(chartSize: chartSize)
                }

                // Dimension detail overlay
                if let dim = selectedDimension {
                    dimensionOverlay(dim)
                }
            }
        }
        .alert("Add Note", isPresented: $showAnnotationInput) {
            TextField("Your note...", text: $newAnnotationText)
            Button("Add") {
                if !newAnnotationText.isEmpty {
                    let note = AnnotationNote(
                        position: tapLocation,
                        text: newAnnotationText
                    )
                    annotations[note.id] = note
                    newAnnotationText = ""
                }
            }
            Button("Cancel", role: .cancel) {
                newAnnotationText = ""
            }
        }
    }

    // MARK: - Bottom Detail Strip

    private func bottomDetailStrip(chartSize: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: LCSTheme.Spacing.md) {
                ForEach(CognitiveDimension.allCases) { dim in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDimension = selectedDimension == dim ? nil : dim
                        }
                    } label: {
                        VStack(spacing: LCSTheme.Spacing.sm) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(dim.color)
                                    .frame(width: 8, height: 8)
                                Text(dim.shortName)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(LCSTheme.textPrimary)
                            }

                            Text(ScoreFormatter.formatted(profile.score(for: dim)))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(dim.color)

                            Text(ScoreFormatter.poleLabel(dimension: dim, score: profile.score(for: dim)))
                                .font(.system(size: 10))
                                .foregroundColor(LCSTheme.textTertiary)

                            // Mini score bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.06))
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(dim.color.opacity(0.6))
                                        .frame(width: geo.size.width * CGFloat(ScoreFormatter.percentPosition(profile.score(for: dim))))
                                }
                            }
                            .frame(height: 3)
                        }
                        .frame(width: 100)
                        .padding(.vertical, LCSTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                                .fill(selectedDimension == dim ? dim.color.opacity(0.1) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: LCSTheme.Radius.md)
                                        .stroke(selectedDimension == dim ? dim.color.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, LCSTheme.Spacing.lg)
            .padding(.bottom, LCSTheme.Spacing.lg)
        }
    }

    // MARK: - Dimension Overlay

    private func dimensionOverlay(_ dimension: CognitiveDimension) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: LCSTheme.Spacing.md) {
                    HStack {
                        Image(systemName: dimension.icon)
                            .foregroundColor(dimension.color)
                        Text(dimension.name)
                            .font(.headline)
                            .foregroundColor(LCSTheme.textPrimary)
                        Spacer()
                        Button {
                            withAnimation { selectedDimension = nil }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(LCSTheme.textTertiary)
                        }
                    }

                    DimensionScoreView(
                        dimension: dimension,
                        score: profile.score(for: dimension),
                        showInterpretation: true,
                        animated: false
                    )

                    Text(ProfileTypeNamer.extendedInterpretation(
                        dimension: dimension,
                        score: profile.score(for: dimension)
                    ))
                    .font(.caption)
                    .foregroundColor(LCSTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: 360)
                .lcsCard()
                .padding(LCSTheme.Spacing.xl)
            }
        }
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}

// MARK: - Annotation Models & Views

struct AnnotationNote: Identifiable {
    let id = UUID()
    let position: CGPoint
    let text: String
    let createdAt = Date()
}

struct AnnotationDotView: View {
    let note: AnnotationNote
    let onDelete: () -> Void
    @State private var showText = false

    var body: some View {
        ZStack {
            // Dot
            Circle()
                .fill(LCSTheme.goldAccent)
                .frame(width: 12, height: 12)
                .shadow(color: LCSTheme.goldAccent.opacity(0.5), radius: 4)
                .onTapGesture { showText.toggle() }

            // Text popover
            if showText {
                VStack(spacing: 4) {
                    Text(note.text)
                        .font(.caption)
                        .foregroundColor(LCSTheme.textPrimary)
                        .padding(.horizontal, LCSTheme.Spacing.sm)
                        .padding(.vertical, LCSTheme.Spacing.xs)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(LCSTheme.darkSurface)
                                .shadow(color: .black.opacity(0.3), radius: 4)
                        )

                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundColor(.red)
                    }
                }
                .offset(y: -30)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
