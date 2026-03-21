// ResonanceAnimations.swift
// Resonance — Design for the Exhale
//
// Organic, breathing animations that create calm ambient motion.

import SwiftUI

// MARK: - Animation Presets

enum ResonanceAnimation {
    // The signature breathing animation — slow, organic
    static let breathe = Animation.easeInOut(duration: 4.0).repeatForever(autoreverses: true)

    // Gentle float for ambient elements
    static let gentleFloat = Animation.easeInOut(duration: 6.0).repeatForever(autoreverses: true)

    // View transitions
    static let viewTransition = Animation.easeOut(duration: 0.5)

    // Theme switching
    static let themeChange = Animation.easeInOut(duration: 0.8)

    // Interaction feedback
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7)

    // Elevated spring (iPad glass panels)
    static let elevatedSpring = Animation.spring(response: 0.5, dampingFraction: 0.65)

    // Subtle pulse for active indicators
    static let pulse = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)

    // Task completion
    static let complete = Animation.spring(response: 0.3, dampingFraction: 0.6)
}

// MARK: - Breathing Modifier

struct BreathingModifier: ViewModifier {
    @State private var isBreathing = false
    let intensity: CGFloat
    let duration: Double

    func body(content: Content) -> some View {
        content
            .scaleEffect(isBreathing ? 1.0 + intensity : 1.0)
            .offset(
                x: isBreathing ? intensity * 10 : 0,
                y: isBreathing ? intensity * 15 : 0
            )
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isBreathing
            )
            .onAppear { isBreathing = true }
    }
}

// MARK: - Ripple Effect

struct RippleModifier: ViewModifier {
    @State private var isRippling = false

    func body(content: Content) -> some View {
        content
            .overlay {
                Circle()
                    .stroke(Color(hex: "C5A059").opacity(isRippling ? 0 : 0.4), lineWidth: 2)
                    .scaleEffect(isRippling ? 2.5 : 1.0)
                    .animation(
                        .easeOut(duration: 1.5).repeatForever(autoreverses: false),
                        value: isRippling
                    )
            }
            .onAppear { isRippling = true }
    }
}

// MARK: - Fade In

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.7).delay(delay)) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Slide In

struct SlideInModifier: ViewModifier {
    @State private var offset: CGFloat = 20
    @State private var opacity: Double = 0
    let delay: Double
    let direction: Edge

    var computedOffset: CGSize {
        switch direction {
        case .bottom: return CGSize(width: 0, height: offset)
        case .trailing: return CGSize(width: offset, height: 0)
        case .leading: return CGSize(width: -offset, height: 0)
        case .top: return CGSize(width: 0, height: -offset)
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(computedOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(delay)) {
                    offset = 0
                    opacity = 1.0
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func breathe(intensity: CGFloat = 0.05, duration: Double = 8.0) -> some View {
        modifier(BreathingModifier(intensity: intensity, duration: duration))
    }

    func ripple() -> some View {
        modifier(RippleModifier())
    }

    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }

    func slideIn(from direction: Edge = .bottom, delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay, direction: direction))
    }
}

// MARK: - Transition Presets

extension AnyTransition {
    static var resonanceFade: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.98)).animation(.easeOut(duration: 0.4))
    }

    static var resonanceSlideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        ).animation(.easeOut(duration: 0.4))
    }

    static var resonanceSlideTrailing: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ).animation(.easeOut(duration: 0.35))
    }
}
