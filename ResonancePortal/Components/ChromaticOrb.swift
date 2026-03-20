import SwiftUI

struct ChromaticOrb: View {
    let name: String
    let color: Color
    var size: CGFloat = 48

    private var initials: String {
        name.split(separator: "-")
            .compactMap(\.first)
            .prefix(2)
            .map(String.init)
            .joined()
            .uppercased()
    }

    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.29)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Inner glow overlay
            RoundedRectangle(cornerRadius: size * 0.29)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.2), Color.clear],
                        center: UnitPoint(x: 0.3, y: 0.5),
                        startRadius: 0,
                        endRadius: size * 0.6
                    )
                )

            Text(initials)
                .font(.system(size: size * 0.375, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                scale = 1.05
            }
        }
    }
}
