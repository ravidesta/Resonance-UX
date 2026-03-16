// MarketplaceView.swift
// Resonance UX GitHub Backup — Marketplace
// Buy, sell, license, and trade repositories

import SwiftUI

struct MarketplaceView: View {
    @EnvironmentObject var viewModel: BackupViewModel
    @State private var searchText = ""
    @State private var filterType: MarketplaceListing.ListingType?
    @State private var selectedListing: MarketplaceListing?
    @State private var showCreateListing = false

    var filteredListings: [MarketplaceListing] {
        viewModel.marketplaceListings.filter { listing in
            let matchesSearch = searchText.isEmpty ||
                listing.title.localizedCaseInsensitiveContains(searchText) ||
                listing.repositoryName.localizedCaseInsensitiveContains(searchText)
            let matchesType = filterType == nil || listing.listingType == filterType
            return matchesSearch && matchesType && listing.isActive
        }
    }

    var body: some View {
        VStack(spacing: ResonanceSpacing.md) {
            // Marketplace Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("MARKETPLACE")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.goldPrimary)
                        .tracking(3)
                    Text("Buy, Sell, License & Trade")
                        .font(ResonanceTypography.headingSystem)
                        .foregroundColor(ResonanceColors.textMain)
                }
                Spacer()
                Button(action: { showCreateListing = true }) {
                    Label("List Repository", systemImage: "plus.circle")
                        .font(ResonanceTypography.bodySystem)
                        .padding(.horizontal, ResonanceSpacing.md)
                        .padding(.vertical, ResonanceSpacing.sm)
                        .background(ResonanceColors.goldPrimary.opacity(0.15))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            // Filters
            HStack(spacing: ResonanceSpacing.sm) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ResonanceColors.textMuted)
                    TextField("Search marketplace...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(ResonanceSpacing.sm)
                .glassPanel()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        filterChip("All", type: nil)
                        ForEach(MarketplaceListing.ListingType.allCases, id: \.self) { type in
                            filterChip(type.rawValue, type: type)
                        }
                    }
                }
            }

            // Listings Grid
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 300, maximum: 450), spacing: ResonanceSpacing.md)],
                    spacing: ResonanceSpacing.md
                ) {
                    ForEach(filteredListings) { listing in
                        marketplaceCard(listing)
                            .onTapGesture { selectedListing = listing }
                    }
                }
                .padding(.bottom, ResonanceSpacing.xl)
            }
        }
        .padding(ResonanceSpacing.md)
    }

    func filterChip(_ title: String, type: MarketplaceListing.ListingType?) -> some View {
        Button(action: { filterType = type }) {
            Text(title)
                .font(ResonanceTypography.captionSystem)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(filterType == type ? ResonanceColors.goldPrimary.opacity(0.2) : Color.clear)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(ResonanceColors.borderLight, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    func marketplaceCard(_ listing: MarketplaceListing) -> some View {
        LivingSurface(accentColor: ResonanceColors.goldPrimary) {
            VStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(listing.title)
                            .font(ResonanceTypography.subheadingSystem)
                            .foregroundColor(ResonanceColors.textMain)
                            .lineLimit(1)

                        Text("by \(listing.sellerUsername)")
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.textMuted)
                    }
                    Spacer()

                    // Listing type badge
                    Text(listing.listingType.rawValue)
                        .font(ResonanceTypography.callsignFont)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(listingTypeColor(listing.listingType).opacity(0.15))
                        .foregroundColor(listingTypeColor(listing.listingType))
                        .clipShape(Capsule())
                }

                Text(listing.description)
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textMuted)
                    .lineLimit(2)

                Divider().opacity(0.2)

                // Price & License
                HStack {
                    if listing.pricing.priceType == .free {
                        Text("Free")
                            .font(ResonanceTypography.headingSystem)
                            .foregroundColor(ResonanceColors.growthGreen)
                    } else if listing.pricing.priceType == .trade {
                        Text("Trade Only")
                            .font(ResonanceTypography.bodySystem)
                            .foregroundColor(ResonanceColors.warmthAmber)
                    } else {
                        Text("$\(listing.pricing.price as NSDecimalNumber)")
                            .font(ResonanceTypography.headingSystem)
                            .foregroundColor(ResonanceColors.goldPrimary)
                        Text(listing.pricing.currency)
                            .font(ResonanceTypography.captionSystem)
                            .foregroundColor(ResonanceColors.textMuted)
                    }

                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                        Text(listing.license.licenseType.rawValue)
                    }
                    .font(ResonanceTypography.captionSystem)
                    .foregroundColor(ResonanceColors.textMuted)
                }

                // Stats
                HStack(spacing: ResonanceSpacing.md) {
                    Label("\(listing.statistics.views)", systemImage: "eye")
                    Label("\(listing.statistics.favorites)", systemImage: "heart")
                    Label(listing.primaryLanguage, systemImage: "chevron.left.forwardslash.chevron.right")
                    Spacer()
                    if listing.statistics.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .foregroundColor(ResonanceColors.goldPrimary)
                            Text(String(format: "%.1f", listing.statistics.rating))
                        }
                    }
                }
                .font(ResonanceTypography.captionSystem)
                .foregroundColor(ResonanceColors.textLight)
            }
            .padding(ResonanceSpacing.md)
        }
    }

    func listingTypeColor(_ type: MarketplaceListing.ListingType) -> Color {
        switch type {
        case .sale: return ResonanceColors.growthGreen
        case .license: return ResonanceColors.strategicBlue
        case .trade: return ResonanceColors.warmthAmber
        case .auction: return ResonanceColors.creativeMagenta
        case .openSource: return ResonanceColors.signalTeal
        }
    }
}
