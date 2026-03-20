import SwiftUI

struct LivingSurface<Content: View>: View {
    var glowColor: Color = ResonanceTheme.growthGreen
    @ViewBuilder var content: () -> Content

    @State private var breatheOpacity: Double = 0.04

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(breatheOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(breatheOpacity + 0.02), lineWidth: 1)
                )

            // Inner radial glow
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    RadialGradient(
                        colors: [glowColor.opacity(0.05), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.5),
                        startRadius: 0,
                        endRadius: 200
                    )
                )

            content()
                .padding(24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                breatheOpacity = 0.06
            }
        }
    }
}
