// DeepRestToggle.swift
// Resonance — Design for the Exhale

import SwiftUI

struct DeepRestToggle: View {
    @Bindable var themeManager: ThemeManager

    var body: some View {
        Button {
            themeManager.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: themeManager.isDeepRest ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(
                        themeManager.isDeepRest
                            ? themeManager.currentTheme.goldPrimary
                            : themeManager.currentTheme.textMuted
                    )

                #if !os(watchOS)
                Text(themeManager.isDeepRest ? "Deep Rest" : "Daylight")
                    .font(ResonanceFont.labelSmall)
                    .foregroundStyle(themeManager.currentTheme.textMuted)
                #endif
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(themeManager.currentTheme.bgSurface.opacity(0.6))
                    .overlay {
                        Capsule()
                            .stroke(themeManager.currentTheme.borderLight.opacity(0.5), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
        #if os(iOS) || os(watchOS)
        .sensoryFeedback(.selection, trigger: themeManager.isDeepRest)
        #endif
    }
}

// MARK: - Spaciousness Gauge

struct SpacousnessGauge: View {
    let percent: Int
    let theme: ResonanceTheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wind")
                .font(.system(size: 12))
                .foregroundStyle(theme.textLight)

            VStack(alignment: .leading, spacing: 2) {
                Text("SPACIOUSNESS")
                    .font(ResonanceFont.caption)
                    .tracking(1.5)
                    .foregroundStyle(theme.textLight)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(theme.borderLight.opacity(0.3))
                            .frame(height: 3)

                        Capsule()
                            .fill(theme.goldPrimary.opacity(0.6))
                            .frame(width: geo.size.width * CGFloat(percent) / 100, height: 3)
                    }
                }
                .frame(height: 3)
            }

            Text("\(percent)%")
                .font(ResonanceFont.labelSmall)
                .foregroundStyle(theme.goldPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassPanel(theme: theme, cornerRadius: ResonanceTheme.cornerSmall)
    }
}

// MARK: - Breathing Circle

struct BreathingCircle: View {
    let theme: ResonanceTheme
    let size: CGFloat
    @State private var isBreathing = false

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(theme.goldPrimary.opacity(0.1))
                .frame(width: size * 1.5, height: size * 1.5)
                .scaleEffect(isBreathing ? 1.1 : 0.9)

            // Inner circle
            Circle()
                .fill(
                    RadialGradient(
                        colors: [theme.goldLight.opacity(0.4), theme.goldPrimary.opacity(0.15)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
                .scaleEffect(isBreathing ? 1.05 : 0.95)

            // Center dot
            Circle()
                .fill(theme.goldPrimary.opacity(0.6))
                .frame(width: size * 0.15, height: size * 0.15)
        }
        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isBreathing)
        .onAppear { isBreathing = true }
    }
}

// MARK: - Gold Accent Button

struct GoldAccentButton: View {
    let title: String
    let icon: String?
    let theme: ResonanceTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                }
                Text(title)
                    .font(ResonanceFont.labelMedium)
            }
            .foregroundStyle(theme.goldPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(theme.goldPrimary.opacity(0.1))
                    .overlay {
                        Capsule()
                            .stroke(theme.goldPrimary.opacity(0.3), lineWidth: 0.5)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Domain Tag

struct DomainTag: View {
    let name: String
    let theme: ResonanceTheme

    var body: some View {
        Text(name.uppercased())
            .font(ResonanceFont.caption)
            .tracking(1)
            .foregroundStyle(theme.textLight)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
                Capsule()
                    .fill(theme.borderLight.opacity(0.3))
            }
    }
}
