import SwiftUI

struct BioIndicator: View {
    let status: SyncStatus

    @State private var glowRadius: CGFloat = 4

    private var color: Color {
        switch status {
        case .synced: return ResonanceTheme.growthGreen
        case .pending: return ResonanceTheme.warmthAmber
        case .error: return ResonanceTheme.rhythmCoral
        case .backingUp: return ResonanceTheme.strategicBlue
        }
    }

    private var animationDuration: Double {
        status == .backingUp ? 1.0 : 3.0
    }

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .shadow(color: color.opacity(0.6), radius: glowRadius)
            .onAppear {
                withAnimation(.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                    glowRadius = 8
                }
            }
    }
}
