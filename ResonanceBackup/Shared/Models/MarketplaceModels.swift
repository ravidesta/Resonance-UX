// MarketplaceModels.swift
// Resonance UX GitHub Backup — Marketplace
// Buy, sell, license, and trade repositories

import Foundation
import SwiftUI

// MARK: - Marketplace Listing

struct MarketplaceListing: Identifiable, Codable {
    let id: UUID
    var portfolioID: UUID                // Link to portfolio
    var sellerUsername: String
    var title: String
    var description: String
    var repositoryName: String
    var primaryLanguage: String
    var tags: [String]
    var listingType: ListingType
    var pricing: PricingInfo
    var license: LicenseInfo
    var statistics: ListingStats
    var createdAt: Date
    var updatedAt: Date
    var isActive: Bool
    var isFeatured: Bool
    var previewImages: [String]          // URLs to screenshots
    var demoURL: String?

    enum ListingType: String, Codable, CaseIterable {
        case sale = "For Sale"
        case license = "License"
        case trade = "Trade"
        case auction = "Auction"
        case openSource = "Open Source"
    }

    init(portfolioID: UUID, seller: String, name: String, description: String,
         language: String, type: ListingType) {
        self.id = UUID()
        self.portfolioID = portfolioID
        self.sellerUsername = seller
        self.title = name
        self.description = description
        self.repositoryName = name
        self.primaryLanguage = language
        self.tags = []
        self.listingType = type
        self.pricing = PricingInfo()
        self.license = LicenseInfo()
        self.statistics = ListingStats()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isActive = true
        self.isFeatured = false
        self.previewImages = []
        self.demoURL = nil
    }
}

// MARK: - Pricing

struct PricingInfo: Codable {
    var price: Decimal                    // Base price
    var currency: String                  // "USD", "EUR", "BTC", etc.
    var priceType: PriceType
    var minimumBid: Decimal?             // For auctions
    var royaltyPercentage: Double?       // Ongoing royalty on resale
    var negotiable: Bool

    enum PriceType: String, Codable, CaseIterable {
        case fixed = "Fixed Price"
        case subscription = "Subscription"
        case perSeat = "Per Seat"
        case payWhatYouWant = "Pay What You Want"
        case auction = "Auction"
        case trade = "Trade Only"
        case free = "Free"
    }

    init() {
        self.price = 0
        self.currency = "USD"
        self.priceType = .fixed
        self.negotiable = true
    }
}

// MARK: - License Info

struct LicenseInfo: Codable {
    var licenseType: LicenseType
    var customTerms: String?
    var allowsModification: Bool
    var allowsCommercialUse: Bool
    var allowsRedistribution: Bool
    var requiresAttribution: Bool
    var exclusiveRights: Bool
    var transferable: Bool
    var duration: LicenseDuration
    var territories: [String]            // Geographic restrictions

    enum LicenseType: String, Codable, CaseIterable {
        case mit = "MIT"
        case apache2 = "Apache 2.0"
        case gplv3 = "GPLv3"
        case agplv3 = "AGPLv3"
        case bsd2 = "BSD 2-Clause"
        case bsd3 = "BSD 3-Clause"
        case proprietary = "Proprietary"
        case commercial = "Commercial"
        case creativeCommons = "Creative Commons"
        case custom = "Custom"
    }

    enum LicenseDuration: String, Codable, CaseIterable {
        case perpetual = "Perpetual"
        case annual = "Annual"
        case monthly = "Monthly"
        case oneTime = "One-Time Use"
    }

    init() {
        self.licenseType = .mit
        self.allowsModification = true
        self.allowsCommercialUse = true
        self.allowsRedistribution = true
        self.requiresAttribution = true
        self.exclusiveRights = false
        self.transferable = true
        self.duration = .perpetual
        self.territories = ["Worldwide"]
    }
}

// MARK: - Listing Statistics

struct ListingStats: Codable {
    var views: Int
    var favorites: Int
    var inquiries: Int
    var downloads: Int
    var rating: Double                   // 0-5 stars
    var reviewCount: Int

    init() {
        self.views = 0
        self.favorites = 0
        self.inquiries = 0
        self.downloads = 0
        self.rating = 0
        self.reviewCount = 0
    }
}

// MARK: - Trade Offer

struct TradeOffer: Identifiable, Codable {
    let id: UUID
    var fromUser: String
    var toUser: String
    var offeredListingID: UUID
    var requestedListingID: UUID
    var additionalPayment: Decimal?
    var currency: String
    var message: String
    var status: TradeStatus
    var createdAt: Date

    enum TradeStatus: String, Codable {
        case pending = "Pending"
        case accepted = "Accepted"
        case declined = "Declined"
        case countered = "Countered"
        case expired = "Expired"
        case completed = "Completed"
    }
}

// MARK: - Transaction Record

struct TransactionRecord: Identifiable, Codable {
    let id: UUID
    var listingID: UUID
    var buyerUsername: String
    var sellerUsername: String
    var transactionType: TransactionType
    var amount: Decimal
    var currency: String
    var licenseGranted: LicenseInfo
    var timestamp: Date
    var receiptHash: String              // For verification
    var bitstampHash: String?            // Timestamped on blockchain

    enum TransactionType: String, Codable {
        case purchase = "Purchase"
        case license = "License"
        case trade = "Trade"
        case subscription = "Subscription"
    }
}

// MARK: - Review

struct ListingReview: Identifiable, Codable {
    let id: UUID
    var listingID: UUID
    var reviewerUsername: String
    var rating: Int                      // 1-5
    var title: String
    var body: String
    var createdAt: Date
    var helpful: Int
}
