// CosmicReadingView.swift
// Haute Lumière Date & Time — Bespoke Readings & Year-Ahead Reports
//
// $30 Bespoke Reading: 10-page impeccably illustrated PDF on anything.
// $99 Year-Ahead: Love, life, any life wheel dimension — full synthesis
//     across astrology, numerology, ayurveda, five elements, enneagram.
// Includes bespoke audiobook narration of the reading.
// Monthly collectible book-sized report included with subscription.

import SwiftUI

struct CosmicReadingView: View {
    @EnvironmentObject var cosmicEngine: CosmicEngine
    @State private var selectedReading: ReadingProduct?
    @State private var selectedTopic: ReadingTopic = .loveLife
    @State private var selectedTraditions: Set<CosmicTradition> = [.westernAstrology, .numerology]
    @State private var customQuestion = ""
    @State private var showPurchaseConfirm = false

    private let gold = Color(hex: "D4AF37")
    private let ivory = Color(hex: "FAFAF5")
    private let muted = Color(hex: "8A8A85")
    private let bg = Color(hex: "050505")

    var body: some View {
        NavigationStack {
            ZStack {
                bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Bespoke Readings")
                                .font(.custom("Cormorant Garamond", size: 28).weight(.medium))
                                .foregroundColor(ivory)
                            Text("Impeccably illustrated. Deeply personal.")
                                .font(.custom("Avenir Next", size: 13))
                                .foregroundColor(muted)
                        }
                        .padding(.top, 20)

                        // Reading products
                        ForEach(ReadingProduct.allProducts, id: \.id) { product in
                            readingProductCard(product)
                        }

                        // Topic selector
                        topicSelector

                        // Tradition picker
                        traditionPicker

                        // Custom question
                        customQuestionField

                        // What you get
                        whatYouGet

                        // Monthly collectible preview
                        monthlyCollectiblePreview

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "light.max")
                            .font(.system(size: 10, weight: .ultraLight))
                            .foregroundColor(gold)
                        Text("Readings")
                            .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                            .foregroundColor(ivory)
                    }
                }
            }
        }
    }

    // MARK: - Reading Product Card
    private func readingProductCard(_ product: ReadingProduct) -> some View {
        Button(action: { selectedReading = product; showPurchaseConfirm = true }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name)
                            .font(.custom("Cormorant Garamond", size: 22).weight(.medium))
                            .foregroundColor(ivory)
                        Text(product.subtitle)
                            .font(.custom("Avenir Next", size: 12))
                            .foregroundColor(muted)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(product.price)
                            .font(.custom("Cormorant Garamond", size: 28).weight(.light))
                            .foregroundColor(gold)
                        if let pages = product.pages {
                            Text("\(pages) pages")
                                .font(.custom("Avenir Next", size: 10))
                                .foregroundColor(muted)
                        }
                    }
                }

                // Features
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(product.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(gold)
                            Text(feature)
                                .font(.custom("Avenir Next", size: 12))
                                .foregroundColor(ivory.opacity(0.7))
                        }
                    }
                }

                // CTA
                Text(product.cta)
                    .font(.custom("Avenir Next", size: 14).weight(.medium))
                    .foregroundColor(bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(gold)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.03)))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(colors: [gold.opacity(0.3), gold.opacity(0.1), gold.opacity(0.3)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Topic Selector
    private var topicSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What would you like to explore?")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(ReadingTopic.allCases, id: \.self) { topic in
                    Button(action: { selectedTopic = topic }) {
                        HStack(spacing: 8) {
                            Image(systemName: topic.icon)
                                .font(.system(size: 14))
                                .foregroundColor(selectedTopic == topic ? bg : gold)
                            Text(topic.rawValue)
                                .font(.custom("Avenir Next", size: 12))
                                .foregroundColor(selectedTopic == topic ? bg : ivory.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTopic == topic ? gold : Color.white.opacity(0.03))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Tradition Picker
    private var traditionPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose any traditions to synthesize")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            ForEach(CosmicTradition.allCases, id: \.self) { tradition in
                Button(action: { toggleTradition(tradition) }) {
                    HStack(spacing: 12) {
                        Image(systemName: tradition.icon)
                            .foregroundColor(gold)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(tradition.rawValue)
                                .font(.custom("Avenir Next", size: 14).weight(.semibold))
                                .foregroundColor(ivory)
                            Text(tradition.description)
                                .font(.custom("Avenir Next", size: 11))
                                .foregroundColor(muted)
                                .lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: selectedTraditions.contains(tradition) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(selectedTraditions.contains(tradition) ? gold : muted)
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedTraditions.contains(tradition) ? gold.opacity(0.06) : Color.white.opacity(0.02))
                    )
                }
            }
        }
    }

    // MARK: - Custom Question
    private var customQuestionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ask anything")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            TextField("When is the best time to move? What does my year ahead in love look like?", text: $customQuestion, axis: .vertical)
                .font(.custom("Avenir Next", size: 14))
                .foregroundColor(ivory)
                .lineLimit(3...6)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.03)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(gold.opacity(0.15), lineWidth: 0.5))
        }
    }

    // MARK: - What You Get
    private var whatYouGet: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What You Receive")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            VStack(alignment: .leading, spacing: 8) {
                deliverableRow("doc.richtext.fill", "10-page impeccably illustrated PDF")
                deliverableRow("headphones", "Bespoke audiobook narration of your reading")
                deliverableRow("star.circle.fill", "Full synthesis across selected traditions")
                deliverableRow("person.fill.viewfinder", "Personalized to your exact birth chart")
                deliverableRow("heart.circle.fill", "Integrated with your coaching journey")
                deliverableRow("square.and.arrow.up", "Beautiful enough to share on social media")
            }
        }
    }

    private func deliverableRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon).foregroundColor(gold).frame(width: 20)
            Text(text)
                .font(.custom("Avenir Next", size: 13))
                .foregroundColor(ivory.opacity(0.7))
        }
    }

    // MARK: - Monthly Collectible
    private var monthlyCollectiblePreview: some View {
        VStack(spacing: 12) {
            Text("Monthly Collectible")
                .font(.custom("Cormorant Garamond", size: 18).weight(.medium))
                .foregroundColor(ivory)

            VStack(spacing: 8) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 32, weight: .ultraLight))
                    .foregroundColor(gold)

                Text("Your book-sized monthly cosmic report arrives every month. A collector's edition briefing on the month ahead — across all traditions, personalized to your chart.")
                    .font(.custom("Avenir Next", size: 13))
                    .foregroundColor(ivory.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Text("Included with subscription")
                    .font(.custom("Avenir Next", size: 11).weight(.semibold))
                    .foregroundColor(gold)
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.03)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(gold.opacity(0.15), lineWidth: 0.5))
        }
    }

    private func toggleTradition(_ tradition: CosmicTradition) {
        if selectedTraditions.contains(tradition) {
            selectedTraditions.remove(tradition)
        } else {
            selectedTraditions.insert(tradition)
        }
    }
}

// MARK: - Reading Products
struct ReadingProduct: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let price: String
    let pages: Int?
    let features: [String]
    let cta: String

    static let allProducts: [ReadingProduct] = [
        ReadingProduct(
            name: "Bespoke Reading",
            subtitle: "Ask anything. Get a deeply personal answer.",
            price: "$30",
            pages: 10,
            features: [
                "10-page illustrated PDF",
                "Bespoke audiobook narration",
                "Any topic, any question",
                "Full tradition synthesis",
                "Shareable social media cards"
            ],
            cta: "Commission Your Reading"
        ),
        ReadingProduct(
            name: "Year Ahead",
            subtitle: "Love, life, career — your complete cosmic roadmap.",
            price: "$99",
            pages: 30,
            features: [
                "30+ page comprehensive PDF",
                "Full audiobook narration",
                "Month-by-month forecasts",
                "All life wheel dimensions covered",
                "Auspicious dates for the entire year",
                "Integrated coaching recommendations"
            ],
            cta: "Reveal Your Year Ahead"
        ),
        ReadingProduct(
            name: "Relationship Reading",
            subtitle: "Synastry + composite chart — two souls, one story.",
            price: "$99",
            pages: 20,
            features: [
                "20-page synastry analysis",
                "Composite chart interpretation",
                "Numerological compatibility",
                "Dosha harmony assessment",
                "Enneagram pairing dynamics",
                "Free when a friend signs up"
            ],
            cta: "Explore Your Connection"
        ),
    ]
}

enum ReadingTopic: String, CaseIterable {
    case loveLife = "Love & Romance"
    case career = "Career & Purpose"
    case health = "Health & Vitality"
    case finances = "Money & Abundance"
    case relocation = "Where to Live"
    case spiritualGrowth = "Spiritual Path"
    case relationships = "Relationships"
    case timing = "Best Time For..."
    case yearAhead = "Year Ahead"
    case lifeWheel = "Full Life Wheel"

    var icon: String {
        switch self {
        case .loveLife: return "heart.fill"
        case .career: return "briefcase.fill"
        case .health: return "leaf.fill"
        case .finances: return "banknote.fill"
        case .relocation: return "map.fill"
        case .spiritualGrowth: return "sparkles"
        case .relationships: return "person.2.fill"
        case .timing: return "clock.fill"
        case .yearAhead: return "calendar"
        case .lifeWheel: return "chart.pie.fill"
        }
    }
}
