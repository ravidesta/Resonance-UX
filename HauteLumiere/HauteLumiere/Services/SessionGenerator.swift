// SessionGenerator.swift
// Haute Lumière — Content Generation Engine

import Foundation

/// Generates the 100+ combinations of Yoga Nidra, Breathing, and
/// Visualization sessions dynamically from composable elements
struct SessionGenerator {

    // MARK: - Yoga Nidra Library (100+ combinations)
    static func generateYogaNidraLibrary() -> [YogaNidraSession] {
        var sessions: [YogaNidraSession] = []
        let durations = [15, 20, 25, 30, 35, 40, 45, 50, 55, 60]

        // Curated signature sessions
        let signatureSessions: [(String, String, Int, YogaNidraTheme, String)] = [
            ("Moonlit Sanctuary", "A journey into deep restorative rest", 30, .deepSleep, "I am at peace, fully held by the earth"),
            ("Golden Dawn Awakening", "Rise with radiant clarity and purpose", 20, .clarity, "I awaken to my fullest potential"),
            ("Forest of Surrender", "Release everything that no longer serves you", 45, .release, "I release with grace and gratitude"),
            ("Ocean of Stillness", "Float in the vast calm of your inner ocean", 30, .innerPeace, "I am the stillness beneath the waves"),
            ("Mountain of Presence", "Unshakeable grounding in your true nature", 25, .grounding, "I am rooted, stable, and whole"),
            ("Starlight Healing", "Bathe every cell in luminous restoration", 40, .bodyRestoration, "Every cell vibrates with healing light"),
            ("Garden of Gratitude", "Cultivate abundance through deep appreciation", 20, .gratitude, "My life overflows with blessings"),
            ("Temple of Confidence", "Reclaim your sovereign inner power", 35, .confidence, "I trust myself completely"),
            ("River of Creativity", "Unlock the flowing source of creative genius", 30, .creativity, "Creativity flows through me effortlessly"),
            ("Heartspace Expansion", "Open the heart to boundless self-love", 25, .selfLove, "I am worthy of all the love I give"),
            ("Abundance Constellation", "Align with the universal flow of prosperity", 45, .abundance, "Abundance is my natural state"),
            ("Crystal Clear Mind", "Dissolve mental fog into diamond clarity", 20, .clarity, "My mind is sharp, clear, and luminous"),
            ("Energetic Equilibrium", "Balance all energy centers in perfect harmony", 35, .energyBalance, "My energy flows in perfect balance"),
            ("Deep Earth Grounding", "Connect to the primal stability of the earth", 30, .grounding, "I am one with the earth beneath me"),
            ("Cosmic Expansion", "Expand awareness to the edges of the universe", 60, .expansion, "I am infinite, boundless, free"),
            ("Twilight Restoration", "Let the gentle twilight restore your essence", 40, .bodyRestoration, "My body knows exactly how to heal"),
            ("Sacred Silence", "Rest in the profound silence of pure being", 45, .innerPeace, "In silence, I find everything"),
            ("Emotional Alchemy", "Transform heavy emotions into golden wisdom", 35, .emotionalHealing, "I transform all experience into wisdom"),
            ("Stress Dissolve", "Watch stress melt away like morning frost", 15, .stressRelease, "I release tension with every breath"),
            ("Midnight Garden", "A moonlit journey through fragrant serenity", 50, .deepSleep, "Sleep comes to me naturally and deeply"),
        ]

        for (title, subtitle, dur, theme, intention) in signatureSessions {
            sessions.append(YogaNidraSession(
                title: title, subtitle: subtitle, duration: dur,
                theme: theme, intention: intention
            ))
        }

        // Generate additional combinations from themes × durations × visualizations
        let additionalThemes: [(YogaNidraTheme, String, String)] = [
            (.deepSleep, "Velvet Night", "Sink into the softest darkness"),
            (.stressRelease, "Unwinding", "Let each layer of tension release"),
            (.emotionalHealing, "Heart Mending", "Gentle repair of the emotional body"),
            (.bodyRestoration, "Cell Renewal", "Every cell restored to radiance"),
            (.innerPeace, "Still Waters", "Absolute tranquility within"),
            (.creativity, "Muse's Garden", "Where creative impulses bloom"),
            (.confidence, "Lion's Heart", "Fierce, compassionate self-trust"),
            (.gratitude, "Abundance Rain", "Gratitude falling like gentle rain"),
            (.selfLove, "Mirror of Love", "Seeing yourself through love's eyes"),
            (.abundance, "Golden Stream", "Riding the current of prosperity"),
            (.clarity, "Diamond Mind", "Cutting through to essential truth"),
            (.energyBalance, "Chakra Flow", "Harmonizing your energy centers"),
            (.release, "Autumn Leaves", "Letting everything fall naturally"),
            (.grounding, "Root System", "Deep earth connection"),
            (.expansion, "Beyond the Stars", "Transcending all boundaries"),
        ]

        let visualizations = VisualizationStyle.allCases
        let soundscapes: [SoundscapeType] = [.rain, .ocean, .forest, .fire, .creek, .wind, .tibetanBowls, .crystalBowls]

        for (theme, namePrefix, subtitle) in additionalThemes {
            for vis in visualizations {
                let dur = durations.randomElement() ?? 30
                let sound = soundscapes.randomElement() ?? .rain
                sessions.append(YogaNidraSession(
                    title: "\(namePrefix) · \(vis.rawValue)",
                    subtitle: subtitle,
                    duration: dur,
                    theme: theme,
                    intention: "I embrace \(theme.rawValue.lowercased()) with every breath",
                    visualizationStyle: vis,
                    backgroundSoundscape: sound
                ))
            }
        }

        return sessions
    }

    // MARK: - Breathing Library (100+ experiences)
    static func generateBreathingLibrary() -> [BreathingSession] {
        var sessions: [BreathingSession] = []

        let purposes = BreathingPurpose.allCases
        let durations = [5, 10, 15, 20, 25, 30]
        let backgrounds: [SoundscapeType] = [.silence, .rain, .ocean, .forest, .tibetanBowls, .newAgePads, .brownNoise]

        // Generate for each technique × purpose combination
        for technique in BreathingTechnique.allCases {
            for purpose in purposes {
                let dur = durations.randomElement() ?? 15
                let bg = backgrounds.randomElement() ?? .silence
                sessions.append(BreathingSession(
                    title: "\(technique.rawValue) for \(purpose.rawValue)",
                    subtitle: technique.description,
                    duration: dur,
                    technique: technique,
                    purpose: purpose,
                    difficulty: technique.level,
                    backgroundSound: bg
                ))
            }
        }

        // Add curated signature breathing experiences
        let signatureBreathing: [(String, String, Int, BreathingTechnique, BreathingPurpose)] = [
            ("Morning Awakening Breath", "Start your day with energized clarity", 10, .diaphragmatic, .energize),
            ("Executive Reset", "90-second stress reset between meetings", 5, .boxBreathing, .performance),
            ("Sleep Descent", "Guide your nervous system to deep rest", 20, .fourSevenEight, .sleep),
            ("Anxiety Dissolve", "Rapid calm when you need it most", 5, .sighing, .anxiety),
            ("Flow State Activation", "Enter peak performance focus", 15, .coherentBreathing, .focus),
            ("Heart Opening Breath", "Expand emotional capacity", 20, .bhramari, .emotional),
            ("Qi Cultivation", "Build internal energy reserves", 30, .qiGungDantian, .healing),
            ("Warrior's Breath", "Forge unshakeable inner strength", 15, .qiGungReverse, .performance),
            ("Ocean of Calm", "Waves of peace with each breath", 25, .ujjayi, .calm),
            ("Sacred Fire Breath", "Ignite your inner flame", 10, .kapalabhati, .energize),
        ]

        for (title, subtitle, dur, technique, purpose) in signatureBreathing {
            sessions.append(BreathingSession(
                title: title, subtitle: subtitle, duration: dur,
                technique: technique, purpose: purpose,
                difficulty: technique.level
            ))
        }

        return sessions
    }

    // MARK: - Visualization Generator (Unique Each Time)
    static func generateUniqueVisualization(preferences: UserPreferences, phase: FiveDPhase) -> VisualizationMeditation {
        let themes = VisualizationTheme.allCases
        let theme = themes.randomElement() ?? .sacredGrove

        let elements = generateSceneElements(for: theme, phase: phase)
        let duration = preferences.preferredSessionLength.minutes

        let title = generateVisualizationTitle(theme: theme)
        let prompt = generateVisualizationPrompt(theme: theme, elements: elements, phase: phase)

        let soundscapes: [SoundscapeType] = [.forest, .ocean, .rain, .creek, .birds, .tibetanBowls, .newAgePads]
        let soundscape = soundscapes.randomElement() ?? .forest

        return VisualizationMeditation(
            title: title,
            prompt: prompt,
            duration: duration,
            theme: theme,
            elements: elements,
            soundscape: soundscape
        )
    }

    private static func generateSceneElements(for theme: VisualizationTheme, phase: FiveDPhase) -> [String] {
        let baseElements: [String]
        switch theme {
        case .sacredGrove:
            baseElements = ["ancient oak trees", "dappled sunlight", "moss-covered stones", "a clear spring", "singing birds", "wildflowers", "gentle mist"]
        case .mountainSummit:
            baseElements = ["snow-capped peaks", "vast panorama", "crisp air", "eagles soaring", "golden sunrise", "stone cairns", "wind whispers"]
        case .oceanHorizon:
            baseElements = ["turquoise waters", "white sand", "gentle waves", "sea breeze", "distant sailboat", "shells", "coral reef light"]
        case .desertStarscape:
            baseElements = ["infinite stars", "warm sand", "cool night air", "shooting stars", "ancient rock formations", "moonlight", "silence"]
        case .waterfallSanctuary:
            baseElements = ["cascading water", "rainbow mist", "emerald pool", "ferns", "smooth rocks", "birdsong", "hidden cave"]
        case .meadowOfLight:
            baseElements = ["golden grass", "wildflower fields", "warm breeze", "butterflies", "distant mountains", "blue sky", "sun warmth"]
        case .crystalCave:
            baseElements = ["amethyst walls", "crystal formations", "inner glow", "underground lake", "stalactites", "mineral veins", "echoing drops"]
        case .templeOfSilence:
            baseElements = ["marble columns", "incense smoke", "candlelight", "sacred geometry", "eternal flame", "bell tone", "golden altar"]
        case .gardenOfPresence:
            baseElements = ["zen garden", "cherry blossoms", "koi pond", "stone path", "bamboo", "meditation bell", "raked sand"]
        case .cosmicJourney:
            baseElements = ["nebulae", "floating among stars", "planet rings", "cosmic dust", "deep space silence", "aurora", "galactic core"]
        case .forestCanopy:
            baseElements = ["towering redwoods", "canopy light", "forest floor", "mushrooms", "deer", "owl calls", "ancient roots"]
        case .riverOfTime:
            baseElements = ["flowing current", "stepping stones", "willow trees", "golden fish", "bridge", "reflections", "gentle rapids"]
        }

        // Add phase-specific elements
        let phaseElement: String
        switch phase {
        case .discover: phaseElement = "a path appearing before you"
        case .define: phaseElement = "a compass pointing to your true north"
        case .develop: phaseElement = "seeds you planted now sprouting"
        case .deepen: phaseElement = "roots growing deeper into rich soil"
        case .deliver: phaseElement = "a radiant light emanating from your heart"
        }

        var selected = Array(baseElements.shuffled().prefix(4))
        selected.append(phaseElement)
        return selected
    }

    private static func generateVisualizationTitle(theme: VisualizationTheme) -> String {
        let adjectives = ["Luminous", "Sacred", "Ethereal", "Serene", "Radiant", "Ancient", "Celestial", "Golden", "Infinite", "Crystalline"]
        let adj = adjectives.randomElement() ?? "Sacred"
        return "\(adj) \(theme.rawValue)"
    }

    private static func generateVisualizationPrompt(theme: VisualizationTheme, elements: [String], phase: FiveDPhase) -> String {
        let elementList = elements.joined(separator: ", ")
        return """
        You find yourself entering a \(theme.rawValue.lowercased()). \
        Around you: \(elementList). \
        With each breath, you sink deeper into this place of \(phase.displayName.lowercased()). \
        This is your sanctuary — created uniquely for this moment, never to be repeated exactly this way again. \
        Let the scene unfold naturally, following wherever your awareness leads.
        """
    }

    // MARK: - Soundscape Library
    static func generateSoundscapeLibrary() -> [Soundscape] {
        SoundscapeType.allCases.map { type in
            let category: SoundscapeCategory
            switch type {
            case .delta, .theta, .alpha, .beta, .gamma:
                category = .binaural
            case .africanDrumming, .djembe, .dundun, .balafon,
                 .classicalPiano, .classicalStrings, .classicalHarp, .classicalFlute,
                 .newAgeSynth, .newAgePads, .newAgeChimes, .newAgeBowls,
                 .tibetanBowls, .crystalBowls, .gongs,
                 .nativeFlute, .shakuhachi, .sitar, .tanpura:
                category = .music
            case .whiteNoise, .pinkNoise, .brownNoise, .silence:
                category = .ambient
            default:
                category = .nature
            }
            return Soundscape(name: type.displayName, category: category, type: type)
        }
    }
}
