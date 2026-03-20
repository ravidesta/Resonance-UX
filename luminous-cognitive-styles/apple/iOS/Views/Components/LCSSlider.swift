// LCSSlider.swift
// Luminous Cognitive Styles™ — iOS
// Custom slider with gradient track, glowing thumb, and smooth animation

import SwiftUI

struct LCSSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double> = 1...10
    var step: Double = 0.1
    var color: Color = LCSTheme.goldAccent

    @State private var isDragging = false

    private var normalizedValue: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let thumbX = trackWidth * CGFloat(normalizedValue)

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 6)

                // Active track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.4), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, thumbX), height: 6)

                // Tick marks
                HStack(spacing: 0) {
                    ForEach(0..<Int(range.upperBound - range.lowerBound) + 1, id: \.self) { i in
                        if i > 0 { Spacer() }
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 1, height: i % 5 == 0 ? 12 : 6)
                        if i < Int(range.upperBound - range.lowerBound) && i == 0 { Spacer() }
                    }
                }
                .frame(height: 12)

                // Thumb
                Circle()
                    .fill(color)
                    .frame(width: isDragging ? 28 : 22, height: isDragging ? 28 : 22)
                    .shadow(color: color.opacity(isDragging ? 0.8 : 0.5), radius: isDragging ? 12 : 6)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: isDragging ? 10 : 8, height: isDragging ? 10 : 8)
                    )
                    .offset(x: thumbX - (isDragging ? 14 : 11))
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isDragging = true
                        let fraction = gesture.location.x / trackWidth
                        let clamped = min(max(fraction, 0), 1)
                        let rawValue = range.lowerBound + Double(clamped) * (range.upperBound - range.lowerBound)
                        let stepped = (rawValue / step).rounded() * step
                        value = min(range.upperBound, max(range.lowerBound, stepped))
                    }
                    .onEnded { _ in
                        isDragging = false
                        // Snap to nearest 0.5
                        value = (value * 2).rounded() / 2
                    }
            )
        }
        .frame(height: 36)
    }
}

// MARK: - Likert Scale Buttons (for DSR)

struct LikertScaleView: View {
    let labels: [String]
    @Binding var selectedValue: Int?
    var accentColor: Color = LCSTheme.goldAccent

    private let scaleLabels = [
        "Strongly\nDisagree",
        "Disagree",
        "Slightly\nDisagree",
        "Neutral",
        "Slightly\nAgree",
        "Agree",
        "Strongly\nAgree",
    ]

    var body: some View {
        VStack(spacing: LCSTheme.Spacing.sm) {
            HStack(spacing: LCSTheme.Spacing.xs) {
                ForEach(1...7, id: \.self) { value in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedValue = value
                        }
                    } label: {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(selectedValue == value ? accentColor : Color.white.opacity(0.06))
                                    .frame(width: scaleButtonSize(value), height: scaleButtonSize(value))

                                Circle()
                                    .stroke(
                                        selectedValue == value ? accentColor : Color.white.opacity(0.2),
                                        lineWidth: selectedValue == value ? 2 : 1
                                    )
                                    .frame(width: scaleButtonSize(value), height: scaleButtonSize(value))

                                if selectedValue == value {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(LCSTheme.deepNavy)
                                }
                            }

                            Text("\(value)")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(selectedValue == value ? accentColor : LCSTheme.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack {
                Text(scaleLabels.first ?? "")
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.textTertiary)
                    .multilineTextAlignment(.center)
                Spacer()
                Text(scaleLabels.last ?? "")
                    .font(.system(size: 9))
                    .foregroundColor(LCSTheme.textTertiary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func scaleButtonSize(_ value: Int) -> CGFloat {
        let base: CGFloat = 36
        if value == 4 { return base + 4 }
        return base
    }
}
