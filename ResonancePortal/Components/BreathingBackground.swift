import SwiftUI

struct BreathingBackground: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            ResonanceTheme.green900
                .ignoresSafeArea()

            // Blob 1 - top left
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ResonanceTheme.growthGreen.opacity(0.12), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(x: -150, y: -200)
                .scaleEffect(1 + 0.1 * sin(phase))
                .blur(radius: 80)

            // Blob 2 - bottom right
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ResonanceTheme.gold.opacity(0.1), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 150, y: 300)
                .scaleEffect(1 + 0.1 * cos(phase + 1.5))
                .blur(radius: 80)

            // Blob 3 - center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ResonanceTheme.strategicBlue.opacity(0.06), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(1 + 0.05 * sin(phase + 3))
                .blur(radius: 80)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
                phase = .pi * 2
            }
        }
    }
}
