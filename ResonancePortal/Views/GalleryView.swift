import SwiftUI

struct GalleryView: View {
    let repos: [Repository]
    let onSelect: (Repository) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 340, maximum: 500), spacing: 20)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(repos) { repo in
                    PortfolioCardView(
                        repo: repo,
                        color: ResonanceTheme.chromaticPalette[repo.id % ResonanceTheme.chromaticPalette.count]
                    )
                    .onTapGesture { onSelect(repo) }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }
}
