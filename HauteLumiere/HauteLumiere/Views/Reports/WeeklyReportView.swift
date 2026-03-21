// WeeklyReportView.swift
// Haute Lumière — Weekly Coach Report
//
// Both a printable PDF and a social-media-ready shareable card.
// Appreciatively annotated: everything that happened and why it mattered.
// The coach writes a personalized narrative for each week.

import SwiftUI

struct WeeklyReportView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var habitTracker: HabitTracker
    @EnvironmentObject var coachEngine: CoachEngine
    @State private var showShareSheet = false
    @State private var showPDFExport = false
    @State private var weeklyReport: WeeklyCoachReport?

    private var palette: HLColorPalette { appState.selectedColorPalette }

    var body: some View {
        ZStack {
            DarkLaceBackground(palette: palette)

            ScrollView(showsIndicators: false) {
                VStack(spacing: HLSpacing.lg) {
                    // Shareable report card (social media)
                    shareableReportCard
                        .padding(.horizontal, HLSpacing.lg)

                    // Export buttons
                    exportButtons
                        .padding(.horizontal, HLSpacing.lg)

                    // Coach's appreciative narrative
                    coachNarrativeSection
                        .padding(.horizontal, HLSpacing.lg)

                    // Appreciative Annotations — what happened + why it mattered
                    annotationsSection
                        .padding(.horizontal, HLSpacing.lg)

                    // Practice breakdown
                    detailedBreakdown
                        .padding(.horizontal, HLSpacing.lg)

                    // Coach highlights
                    coachHighlightsSection
                        .padding(.horizontal, HLSpacing.lg)

                    // Next week focus
                    nextWeekCard
                        .padding(.horizontal, HLSpacing.lg)

                    Spacer(minLength: 120)
                }
                .padding(.top, HLSpacing.md)
            }
        }
        .onAppear {
            weeklyReport = coachEngine.generateWeeklyCoachReport()
        }
    }

    // MARK: - Shareable Report Card (Social Media Ready)
    private var shareableReportCard: some View {
        VStack(spacing: HLSpacing.lg) {
            // Header
            VStack(spacing: HLSpacing.sm) {
                Image(systemName: "light.max")
                    .font(.system(size: 24, weight: .ultraLight))
                    .foregroundColor(palette.accentPrimary)

                Text("Haute Lumière")
                    .font(HLTypography.serifLight(16))
                    .foregroundColor(palette.accentLight)

                Text("Weekly Wellness Report")
                    .font(HLTypography.serifMedium(24))
                    .foregroundColor(palette.textPrimary)

                Text(weekRangeString)
                    .font(HLTypography.caption)
                    .foregroundColor(palette.textSecondary)
            }

            // Key metrics
            HStack(spacing: HLSpacing.lg) {
                ReportMetric(value: "\(habitTracker.totalSessionsCompleted)", label: "Sessions", icon: "checkmark.circle", palette: palette)
                ReportMetric(value: "\(habitTracker.totalMinutesPracticed)", label: "Minutes", icon: "clock", palette: palette)
                ReportMetric(value: "\(habitTracker.currentStreak)", label: "Day Streak", icon: "flame.fill", palette: palette)
            }

            Rectangle()
                .fill(palette.accentPrimary.opacity(0.3))
                .frame(height: 0.5)
                .padding(.horizontal, HLSpacing.lg)

            // Quote
            VStack(spacing: HLSpacing.sm) {
                let quote = ProfoundQuoteLibrary.quoteForNow()
                Text("\"\(quote.text)\"")
                    .font(HLTypography.serifItalic(14))
                    .foregroundColor(palette.textPrimary.opacity(0.8))
                    .multilineTextAlignment(.center)

                Text("— \(quote.author)")
                    .font(HLTypography.caption)
                    .foregroundColor(palette.textSecondary)
            }
            .padding(.horizontal, HLSpacing.md)

            // Weekly bar chart
            HStack(spacing: 6) {
                ForEach(habitTracker.weeklyProgress) { day in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(day.completionRate > 0 ? palette.accentPrimary : palette.cardFill)
                            .frame(width: 28, height: max(4, CGFloat(day.completionRate) * 40))

                        Text(day.dayName)
                            .font(.system(size: 9))
                            .foregroundColor(palette.textSecondary)
                    }
                }
            }

            // Coach's note
            VStack(spacing: HLSpacing.sm) {
                HStack(spacing: 6) {
                    Image(systemName: appState.selectedCoach.avatarSymbol)
                        .font(.system(size: 12))
                        .foregroundColor(palette.accentPrimary)
                    Text(appState.selectedCoach.displayName)
                        .font(HLTypography.caption)
                        .foregroundColor(palette.accentPrimary)
                }

                Text("Your consistency this week shows the discipline of someone truly committed to their growth. I see real momentum building.")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(palette.textPrimary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(HLSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [palette.bgDeep, palette.bgMid, palette.bgSurface.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: HLRadius.xl)
                .stroke(
                    LinearGradient(colors: [palette.accentPrimary.opacity(0.4), palette.accentLight.opacity(0.2), palette.accentPrimary.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .hlBrandWatermark(palette: palette)
    }

    // MARK: - Export Buttons
    private var exportButtons: some View {
        HStack(spacing: HLSpacing.sm) {
            // Share as image
            Button(action: { showShareSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                        .font(HLTypography.sansMedium(14))
                }
                .foregroundColor(palette.bgDeep)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(palette.accentPrimary)
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
            }

            // Export as PDF
            Button(action: { showPDFExport = true }) {
                HStack {
                    Image(systemName: "doc.richtext")
                    Text("Print PDF")
                        .font(HLTypography.sansMedium(14))
                }
                .foregroundColor(palette.accentPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(palette.accentPrimary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: HLRadius.pill)
                        .stroke(palette.accentPrimary.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Coach's Appreciative Narrative
    private var coachNarrativeSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(colors: appState.selectedCoach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: appState.selectedCoach.avatarSymbol)
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(appState.selectedCoach.displayName)'s Report")
                        .font(HLTypography.cardTitle)
                        .foregroundColor(palette.textPrimary)
                    Text("Appreciative weekly review")
                        .font(HLTypography.caption)
                        .foregroundColor(palette.textSecondary)
                }
            }

            if let report = weeklyReport {
                Text(report.coachNarrative)
                    .font(HLTypography.body)
                    .foregroundColor(palette.textPrimary.opacity(0.85))
                    .lineSpacing(4)
            } else {
                Text("Your coach is preparing this week's report...")
                    .font(HLTypography.body)
                    .foregroundColor(palette.textSecondary)
            }
        }
        .hlDiaryCard(palette: palette)
    }

    // MARK: - Appreciative Annotations
    private var annotationsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("What Happened & Why It Mattered")
                .font(HLTypography.sectionTitle)
                .foregroundColor(palette.textPrimary)

            if let report = weeklyReport, !report.annotations.isEmpty {
                ForEach(report.annotations) { annotation in
                    VStack(alignment: .leading, spacing: HLSpacing.sm) {
                        // What happened
                        HStack(alignment: .top, spacing: HLSpacing.sm) {
                            Circle()
                                .fill(palette.accentPrimary)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(annotation.event)
                                    .font(HLTypography.cardTitle)
                                    .foregroundColor(palette.textPrimary)
                                    .lineLimit(2)

                                Text(annotation.date, style: .date)
                                    .font(HLTypography.caption)
                                    .foregroundColor(palette.textSecondary)
                            }
                        }

                        // Why it mattered (coach's annotation)
                        HStack(spacing: HLSpacing.sm) {
                            Rectangle()
                                .fill(palette.accentPrimary.opacity(0.3))
                                .frame(width: 2)

                            Text(annotation.significance)
                                .font(HLTypography.serifItalic(13))
                                .foregroundColor(palette.accentLight.opacity(0.8))
                                .lineSpacing(3)
                        }
                        .padding(.leading, HLSpacing.md)
                    }
                    .padding(HLSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: HLRadius.md)
                            .fill(palette.cardFill)
                    )
                }
            } else {
                // Placeholder annotations
                ForEach(0..<3, id: \.self) { index in
                    sampleAnnotationCard(index: index)
                }
            }
        }
    }

    private func sampleAnnotationCard(index: Int) -> some View {
        let samples: [(event: String, significance: String)] = [
            ("Completed 7 consecutive days of morning meditation",
             "This consistency is building new neural pathways. The fact that it's becoming automatic means your system is integrating this as identity, not just behavior."),
            ("Shared a vulnerable moment in coaching session",
             "Vulnerability at this level signals trust — both in the process and in yourself. This is exactly the kind of opening that accelerates growth in the Clarity phase."),
            ("First advanced Qi Gung breathing session",
             "Moving to advanced techniques shows your body's readiness. The respiratory system is signaling coherence — your mind-body connection is deepening measurably."),
        ]
        let sample = samples[index % samples.count]

        return VStack(alignment: .leading, spacing: HLSpacing.sm) {
            HStack(alignment: .top, spacing: HLSpacing.sm) {
                Circle()
                    .fill(palette.accentPrimary)
                    .frame(width: 6, height: 6)
                    .padding(.top, 6)

                Text(sample.event)
                    .font(HLTypography.cardTitle)
                    .foregroundColor(palette.textPrimary)
            }

            HStack(spacing: HLSpacing.sm) {
                Rectangle()
                    .fill(palette.accentPrimary.opacity(0.3))
                    .frame(width: 2)

                Text(sample.significance)
                    .font(HLTypography.serifItalic(13))
                    .foregroundColor(palette.accentLight.opacity(0.8))
                    .lineSpacing(3)
            }
            .padding(.leading, HLSpacing.md)
        }
        .padding(HLSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(palette.cardFill)
        )
    }

    // MARK: - Practice Breakdown
    private var detailedBreakdown: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Practice Breakdown")
                .font(HLTypography.sectionTitle)
                .foregroundColor(palette.textPrimary)

            VStack(spacing: HLSpacing.sm) {
                BreakdownRow(label: "Yoga Nidra", minutes: 90, color: Color(hex: "1a1a3e"), palette: palette)
                BreakdownRow(label: "Guided Breathing", minutes: 45, color: .hlAzure, palette: palette)
                BreakdownRow(label: "Visualization", minutes: 30, color: .hlGreen500, palette: palette)
                BreakdownRow(label: "Soundscapes", minutes: 60, color: palette.accentPrimary, palette: palette)
                BreakdownRow(label: "Journaling", minutes: 25, color: Color(hex: "9A8AC5"), palette: palette)
            }
        }
    }

    // MARK: - Coach Highlights
    private var coachHighlightsSection: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Your Coach Noticed")
                .font(HLTypography.sectionTitle)
                .foregroundColor(palette.textPrimary)

            VStack(spacing: HLSpacing.sm) {
                HighlightCard(icon: "star.fill", title: "Strength Displayed", text: "Remarkable consistency in showing up daily", color: palette.accentPrimary, palette: palette)
                HighlightCard(icon: "trophy.fill", title: "Win of the Week", text: "Completed your first advanced breathing session", color: .hlSuccess, palette: palette)
                HighlightCard(icon: "arrow.up.right", title: "Growth Area", text: "Sleep quality improving with evening Nidra practice", color: .hlAzure, palette: palette)
            }
        }
    }

    // MARK: - Next Week
    private var nextWeekCard: some View {
        VStack(alignment: .leading, spacing: HLSpacing.md) {
            Text("Next Week's Focus")
                .font(HLTypography.sectionTitle)
                .foregroundColor(palette.textPrimary)

            VStack(alignment: .leading, spacing: HLSpacing.sm) {
                Text("\(appState.selectedCoach.displayName)'s Recommendation")
                    .font(HLTypography.label)
                    .foregroundColor(palette.accentPrimary)

                Text("Based on your progress in the \(coachEngine.currentPhase.displayName) phase, I recommend focusing on deeper Yoga Nidra sessions and introducing Nadi Shodhana breathing to enhance your nervous system balance.")
                    .font(HLTypography.body)
                    .foregroundColor(palette.textSecondary)
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(palette.cardFill)
            )
        }
    }

    private var weekRangeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end) ?? end
        return "\(formatter.string(from: start)) — \(formatter.string(from: end))"
    }
}

// MARK: - Report Metric
struct ReportMetric: View {
    let value: String
    let label: String
    let icon: String
    var palette: HLColorPalette = .forestSanctuary

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(palette.accentPrimary)
            Text(value)
                .font(HLTypography.serifMedium(24))
                .foregroundColor(palette.textPrimary)
            Text(label)
                .font(HLTypography.caption)
                .foregroundColor(palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Breakdown Row
struct BreakdownRow: View {
    let label: String
    let minutes: Int
    let color: Color
    var palette: HLColorPalette = .forestSanctuary

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 4, height: 32)

            Text(label)
                .font(HLTypography.cardTitle)
                .foregroundColor(palette.textPrimary)

            Spacer()

            Text("\(minutes) min")
                .font(HLTypography.label)
                .foregroundColor(palette.accentPrimary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Highlight Card
struct HighlightCard: View {
    let icon: String
    let title: String
    let text: String
    let color: Color
    var palette: HLColorPalette = .forestSanctuary

    var body: some View {
        HStack(spacing: HLSpacing.md) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HLTypography.label)
                    .foregroundColor(palette.textPrimary)
                Text(text)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(palette.textSecondary)
            }

            Spacer()
        }
        .padding(HLSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: HLRadius.md)
                .fill(palette.cardFill)
        )
    }
}

// MARK: - PDF Report Generator
/// Generates a printable PDF version of the weekly coach report.
/// Luxury format: cream paper stock feel, gold accents, serif headings.
struct PDFReportGenerator {
    static func generatePDF(from report: WeeklyCoachReport, palette: HLColorPalette) -> Data {
        let pageWidth: CGFloat = 612  // Letter size
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 60

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        return renderer.pdfData { context in
            context.beginPage()

            var yPosition: CGFloat = margin

            // Header: Haute Lumière
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Cormorant Garamond", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .light),
                .foregroundColor: UIColor(red: 0.77, green: 0.63, blue: 0.35, alpha: 1)  // Gold
            ]
            let header = "Haute Lumière"
            header.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: headerAttrs)
            yPosition += 40

            // Subtitle
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Cormorant Garamond", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .regular),
                .foregroundColor: UIColor.darkGray
            ]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d, yyyy"
            "Weekly Coach Report — \(dateFormatter.string(from: report.weekStart)) to \(dateFormatter.string(from: report.weekEnd))".draw(
                at: CGPoint(x: margin, y: yPosition),
                withAttributes: subtitleAttrs
            )
            yPosition += 40

            // Gold line
            let goldColor = UIColor(red: 0.77, green: 0.63, blue: 0.35, alpha: 0.5)
            goldColor.setStroke()
            let line = UIBezierPath()
            line.move(to: CGPoint(x: margin, y: yPosition))
            line.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition))
            line.lineWidth = 0.5
            line.stroke()
            yPosition += 20

            // Coach Narrative
            let narrativeAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Avenir Next", size: 11) ?? UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 6
                    return style
                }()
            ]
            let narrativeRect = CGRect(x: margin, y: yPosition, width: pageWidth - margin * 2, height: 200)
            report.coachNarrative.draw(in: narrativeRect, withAttributes: narrativeAttrs)
            yPosition += 160

            // Annotations header
            let sectionAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Cormorant Garamond", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium),
                .foregroundColor: UIColor(red: 0.77, green: 0.63, blue: 0.35, alpha: 1)
            ]
            "What Happened & Why It Mattered".draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionAttrs)
            yPosition += 30

            // Annotations
            let eventAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Avenir Next", size: 11) ?? UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            let sigAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Cormorant Garamond", size: 11) ?? UIFont.italicSystemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineSpacing = 4
                    return style
                }()
            ]

            for annotation in report.annotations.prefix(8) {
                if yPosition > pageHeight - 120 {
                    context.beginPage()
                    yPosition = margin
                }

                // Event bullet
                "• \(annotation.event)".draw(
                    in: CGRect(x: margin, y: yPosition, width: pageWidth - margin * 2, height: 40),
                    withAttributes: eventAttrs
                )
                yPosition += 22

                // Significance (indented)
                annotation.significance.draw(
                    in: CGRect(x: margin + 20, y: yPosition, width: pageWidth - margin * 2 - 20, height: 60),
                    withAttributes: sigAttrs
                )
                yPosition += 50
            }

            // Footer
            yPosition = pageHeight - margin
            goldColor.setStroke()
            let footerLine = UIBezierPath()
            footerLine.move(to: CGPoint(x: margin, y: yPosition - 20))
            footerLine.addLine(to: CGPoint(x: pageWidth - margin, y: yPosition - 20))
            footerLine.lineWidth = 0.5
            footerLine.stroke()

            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Cormorant Garamond", size: 10) ?? UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor(red: 0.77, green: 0.63, blue: 0.35, alpha: 0.6)
            ]
            "Haute Lumière — Your Wellness Journey".draw(at: CGPoint(x: margin, y: yPosition - 12), withAttributes: footerAttrs)
        }
    }
}
