// VisionHomeView.swift
// Haute Lumière — Vision Pro Immersive Meditation Spaces

import SwiftUI

struct VisionHomeView: View {
    @State private var selectedEnvironment: ImmersiveEnvironment = .sacredGrove
    @State private var isInSession = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Deep ambient background
                LinearGradient(
                    colors: [Color(hex: "0A1C14"), Color(hex: "122E21")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    // Floating header
                    VStack(spacing: 12) {
                        Image(systemName: "light.max")
                            .font(.system(size: 36, weight: .ultraLight))
                            .foregroundColor(Color(hex: "C5A059"))

                        Text("Haute Lumière")
                            .font(.custom("Cormorant Garamond", size: 32).weight(.light))
                            .foregroundColor(Color(hex: "E6D0A1"))

                        Text("Immersive Wellness Experience")
                            .font(.custom("Manrope", size: 14).weight(.light))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.top, 40)

                    // Environment selector
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose Your Space")
                            .font(.custom("Cormorant Garamond", size: 24).weight(.medium))
                            .foregroundColor(Color(hex: "E6D0A1"))

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(ImmersiveEnvironment.allCases, id: \.self) { env in
                                    VisionEnvironmentCard(
                                        environment: env,
                                        isSelected: selectedEnvironment == env
                                    ) {
                                        selectedEnvironment = env
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                    // Session types for Vision Pro
                    VStack(spacing: 12) {
                        VisionSessionButton(
                            title: "Yoga Nidra Journey",
                            subtitle: "Full immersive body scan with spatial audio",
                            icon: "moon.stars.fill",
                            duration: "30-60 min"
                        )

                        VisionSessionButton(
                            title: "Breathing Sanctuary",
                            subtitle: "360° breathing visualization with haptic guidance",
                            icon: "wind",
                            duration: "10-30 min"
                        )

                        VisionSessionButton(
                            title: "Visualization Meditation",
                            subtitle: "AI-generated immersive landscapes unique to you",
                            icon: "eye.fill",
                            duration: "15-45 min"
                        )

                        VisionSessionButton(
                            title: "Coaching Space",
                            subtitle: "Private spatial coaching with \(CoachPersona.avaAzure.displayName)",
                            icon: "person.2.fill",
                            duration: "45-90 min"
                        )

                        VisionSessionButton(
                            title: "Sound Bath",
                            subtitle: "Spatial audio soundscape mixing in 360°",
                            icon: "waveform",
                            duration: "Continuous"
                        )
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Immersive Environments
enum ImmersiveEnvironment: String, CaseIterable {
    case sacredGrove = "Sacred Grove"
    case mountainSummit = "Mountain Summit"
    case oceanCliff = "Ocean Cliff"
    case desertNight = "Desert Night"
    case zenGarden = "Zen Garden"
    case crystalCave = "Crystal Cave"
    case floatingTemple = "Floating Temple"
    case cosmicVoid = "Cosmic Void"

    var description: String {
        switch self {
        case .sacredGrove: return "Ancient trees, dappled light, birdsong"
        case .mountainSummit: return "Above the clouds, infinite vista"
        case .oceanCliff: return "Waves crashing below, salt air, sunset"
        case .desertNight: return "Infinite stars, warm sand, silence"
        case .zenGarden: return "Raked sand, cherry blossoms, stillness"
        case .crystalCave: return "Amethyst walls, inner glow, deep earth"
        case .floatingTemple: return "Marble columns, eternal flame, cosmic view"
        case .cosmicVoid: return "Nebulae, stars, weightless peace"
        }
    }

    var icon: String {
        switch self {
        case .sacredGrove: return "tree.fill"
        case .mountainSummit: return "mountain.2.fill"
        case .oceanCliff: return "water.waves"
        case .desertNight: return "moon.stars.fill"
        case .zenGarden: return "leaf.fill"
        case .crystalCave: return "diamond.fill"
        case .floatingTemple: return "building.columns.fill"
        case .cosmicVoid: return "sparkles"
        }
    }
}

// MARK: - Environment Card
struct VisionEnvironmentCard: View {
    let environment: ImmersiveEnvironment
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "1B402E"), Color(hex: "2A5A42")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 140, height: 100)

                    Image(systemName: environment.icon)
                        .font(.system(size: 28, weight: .ultraLight))
                        .foregroundColor(Color(hex: "C5A059").opacity(0.7))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color(hex: "C5A059") : .clear, lineWidth: 2)
                )

                Text(environment.rawValue)
                    .font(.custom("Manrope", size: 12).weight(.medium))
                    .foregroundColor(isSelected ? Color(hex: "C5A059") : .white.opacity(0.7))

                Text(environment.description)
                    .font(.custom("Manrope", size: 10))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 140)
        }
    }
}

// MARK: - Session Button
struct VisionSessionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let duration: String

    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "C5A059").opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "C5A059"))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Manrope", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Text(duration)
                    .font(.custom("Manrope", size: 11))
                    .foregroundColor(Color(hex: "C5A059"))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            )
        }
    }
}
