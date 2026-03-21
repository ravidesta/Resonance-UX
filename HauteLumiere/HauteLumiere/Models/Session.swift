// Session.swift
// Haute Lumière

import Foundation

// MARK: - Session Types
enum SessionType: String, Codable, CaseIterable {
    case yogaNidra = "Yoga Nidra"
    case guidedBreathing = "Guided Breathing"
    case visualizationMeditation = "Visualization"
    case soundscape = "Soundscape"
    case lifeCoaching = "Life Coaching"
    case executiveCoaching = "Executive Coaching"
    case selfInquiry = "Self-Inquiry"
    case qiGung = "Qi Gung Breathing"

    var icon: String {
        switch self {
        case .yogaNidra: return "moon.stars.fill"
        case .guidedBreathing: return "wind"
        case .visualizationMeditation: return "eye.fill"
        case .soundscape: return "waveform"
        case .lifeCoaching: return "person.2.fill"
        case .executiveCoaching: return "briefcase.fill"
        case .selfInquiry: return "sparkle.magnifyingglass"
        case .qiGung: return "figure.mind.and.body"
        }
    }
}

// MARK: - Yoga Nidra Session
struct YogaNidraSession: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int // minutes
    let theme: YogaNidraTheme
    let intention: String
    let bodyRegions: [BodyRegion]
    let visualizationStyle: VisualizationStyle
    let binauralFrequency: Double? // Hz
    let backgroundSoundscape: SoundscapeType
    let difficulty: ExperienceLevel
    let isFavorite: Bool
    let timesCompleted: Int

    init(
        title: String,
        subtitle: String,
        duration: Int,
        theme: YogaNidraTheme,
        intention: String,
        bodyRegions: [BodyRegion] = BodyRegion.allCases,
        visualizationStyle: VisualizationStyle = .nature,
        binauralFrequency: Double? = 4.0,
        backgroundSoundscape: SoundscapeType = .rain,
        difficulty: ExperienceLevel = .beginner
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.theme = theme
        self.intention = intention
        self.bodyRegions = bodyRegions
        self.visualizationStyle = visualizationStyle
        self.binauralFrequency = binauralFrequency
        self.backgroundSoundscape = backgroundSoundscape
        self.difficulty = difficulty
        self.isFavorite = false
        self.timesCompleted = 0
    }
}

enum YogaNidraTheme: String, Codable, CaseIterable {
    case deepSleep = "Deep Sleep"
    case stressRelease = "Stress Release"
    case emotionalHealing = "Emotional Healing"
    case bodyRestoration = "Body Restoration"
    case innerPeace = "Inner Peace"
    case creativity = "Creative Awakening"
    case confidence = "Confidence Building"
    case gratitude = "Gratitude"
    case selfLove = "Self-Love"
    case abundance = "Abundance"
    case clarity = "Mental Clarity"
    case energyBalance = "Energy Balance"
    case release = "Letting Go"
    case grounding = "Grounding"
    case expansion = "Expansion"
}

enum BodyRegion: String, Codable, CaseIterable {
    case rightHand, leftHand, rightArm, leftArm
    case rightFoot, leftFoot, rightLeg, leftLeg
    case torso, back, neck, face, crown
}

enum VisualizationStyle: String, Codable, CaseIterable {
    case nature = "Nature Vistas"
    case cosmic = "Cosmic Journey"
    case ocean = "Ocean Depths"
    case mountain = "Mountain Peaks"
    case forest = "Ancient Forest"
    case garden = "Sacred Garden"
    case sky = "Open Sky"
    case light = "Pure Light"
}

// MARK: - Breathing Session
struct BreathingSession: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let duration: Int
    let technique: BreathingTechnique
    let purpose: BreathingPurpose
    let difficulty: ExperienceLevel
    let guidanceLevel: GuidanceLevel
    let backgroundSound: SoundscapeType
    let isFavorite: Bool
    let timesCompleted: Int

    init(
        title: String,
        subtitle: String,
        duration: Int,
        technique: BreathingTechnique,
        purpose: BreathingPurpose,
        difficulty: ExperienceLevel = .beginner,
        guidanceLevel: GuidanceLevel = .full,
        backgroundSound: SoundscapeType = .silence
    ) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.technique = technique
        self.purpose = purpose
        self.difficulty = difficulty
        self.guidanceLevel = guidanceLevel
        self.backgroundSound = backgroundSound
        self.isFavorite = false
        self.timesCompleted = 0
    }
}

enum BreathingTechnique: String, Codable, CaseIterable {
    // 12 Beginner
    case boxBreathing = "Box Breathing"
    case fourSevenEight = "4-7-8 Breathing"
    case diaphragmatic = "Diaphragmatic Breathing"
    case alternateNostril = "Alternate Nostril"
    case coherentBreathing = "Coherent Breathing"
    case pursedLip = "Pursed Lip Breathing"
    case bellyBreathing = "Belly Breathing"
    case countedBreath = "Counted Breath"
    case naturalRhythm = "Natural Rhythm"
    case sighing = "Physiological Sigh"
    case oceanBreath = "Ocean Breath (Ujjayi Light)"
    case gentleExpansion = "Gentle Expansion"

    // 6 Moderate
    case ujjayi = "Ujjayi Pranayama"
    case kapalabhati = "Kapalabhati"
    case bhramari = "Bhramari (Bee Breath)"
    case nadiShodhana = "Nadi Shodhana"
    case viloma = "Viloma Pranayama"
    case sitali = "Sitali (Cooling Breath)"

    // 6 Advanced (Qi Gung)
    case qiGungDantian = "Qi Gung: Dantian Breathing"
    case qiGungReverse = "Qi Gung: Reverse Breathing"
    case qiGungBoneMarrow = "Qi Gung: Bone Marrow Washing"
    case qiGungMicrocosmic = "Qi Gung: Microcosmic Orbit"
    case qiGungEmbryonic = "Qi Gung: Embryonic Breathing"
    case qiGungFiveElements = "Qi Gung: Five Elements Breath"

    var level: ExperienceLevel {
        switch self {
        case .boxBreathing, .fourSevenEight, .diaphragmatic, .alternateNostril,
             .coherentBreathing, .pursedLip, .bellyBreathing, .countedBreath,
             .naturalRhythm, .sighing, .oceanBreath, .gentleExpansion:
            return .beginner
        case .ujjayi, .kapalabhati, .bhramari, .nadiShodhana, .viloma, .sitali:
            return .intermediate
        case .qiGungDantian, .qiGungReverse, .qiGungBoneMarrow,
             .qiGungMicrocosmic, .qiGungEmbryonic, .qiGungFiveElements:
            return .advanced
        }
    }

    var description: String {
        switch self {
        case .boxBreathing: return "Equal counts of inhale, hold, exhale, hold. Navy SEAL technique for calm focus."
        case .fourSevenEight: return "Inhale 4, hold 7, exhale 8. Dr. Andrew Weil's natural tranquilizer."
        case .diaphragmatic: return "Deep belly breathing activating the diaphragm for full oxygen exchange."
        case .alternateNostril: return "Balance left and right brain hemispheres through rhythmic nostril switching."
        case .coherentBreathing: return "5.5 breaths per minute for optimal heart rate variability."
        case .pursedLip: return "Extended exhale through pursed lips to slow breathing and reduce anxiety."
        case .bellyBreathing: return "Foundational practice placing awareness on the rise and fall of the belly."
        case .countedBreath: return "Simple counting meditation using breath as anchor."
        case .naturalRhythm: return "Observing and gently guiding the breath to its natural rhythm."
        case .sighing: return "Double inhale followed by extended exhale — fastest physiological stress relief."
        case .oceanBreath: return "Gentle throat constriction creating a soothing oceanic sound."
        case .gentleExpansion: return "Progressive deepening of breath capacity with compassionate awareness."
        case .ujjayi: return "Victorious breath with throat engagement for heat and focus."
        case .kapalabhati: return "Skull-shining breath — rapid exhales for energization and clarity."
        case .bhramari: return "Humming bee breath stimulating the vagus nerve for deep calm."
        case .nadiShodhana: return "Advanced alternate nostril with precise ratios for energy channel purification."
        case .viloma: return "Interrupted breathing with pauses to build prana capacity."
        case .sitali: return "Tongue-curling cooling breath for reducing heat and calming pitta."
        case .qiGungDantian: return "Lower dantian breathing to cultivate and store qi in the body's energy center."
        case .qiGungReverse: return "Abdominal compression on inhale — advanced technique for martial power and healing."
        case .qiGungBoneMarrow: return "Visualization-breath fusion cleansing marrow and regenerating vital essence."
        case .qiGungMicrocosmic: return "Circulating qi through the governing and conception vessels."
        case .qiGungEmbryonic: return "The most refined breathing — returning to prenatal breath patterns."
        case .qiGungFiveElements: return "Sequential breathing through wood, fire, earth, metal, water energies."
        }
    }
}

enum BreathingPurpose: String, Codable, CaseIterable {
    case calm = "Calming"
    case energize = "Energizing"
    case focus = "Focus"
    case sleep = "Sleep Preparation"
    case anxiety = "Anxiety Relief"
    case performance = "Peak Performance"
    case healing = "Healing"
    case emotional = "Emotional Balance"
    case spiritual = "Spiritual Practice"
    case recovery = "Physical Recovery"
}

enum GuidanceLevel: String, Codable, CaseIterable {
    case full = "Fully Guided"
    case partial = "Gentle Cues"
    case minimal = "Timer Only"
}

// MARK: - Visualization Meditation
struct VisualizationMeditation: Identifiable, Codable {
    let id: UUID
    let title: String
    let generatedPrompt: String
    let duration: Int
    let theme: VisualizationTheme
    let sceneElements: [String]
    let backgroundSoundscape: SoundscapeType
    let timestamp: Date
    var isFavorite: Bool
    let isGenerated: Bool // true = AI-generated unique experience

    init(
        title: String,
        prompt: String,
        duration: Int,
        theme: VisualizationTheme,
        elements: [String] = [],
        soundscape: SoundscapeType = .forest
    ) {
        self.id = UUID()
        self.title = title
        self.generatedPrompt = prompt
        self.duration = duration
        self.theme = theme
        self.sceneElements = elements
        self.backgroundSoundscape = soundscape
        self.timestamp = Date()
        self.isFavorite = false
        self.isGenerated = true
    }
}

enum VisualizationTheme: String, Codable, CaseIterable {
    case sacredGrove = "Sacred Grove"
    case mountainSummit = "Mountain Summit"
    case oceanHorizon = "Ocean Horizon"
    case desertStarscape = "Desert Starscape"
    case waterfallSanctuary = "Waterfall Sanctuary"
    case meadowOfLight = "Meadow of Light"
    case crystalCave = "Crystal Cave"
    case templeOfSilence = "Temple of Silence"
    case gardenOfPresence = "Garden of Presence"
    case cosmicJourney = "Cosmic Journey"
    case forestCanopy = "Forest Canopy"
    case riverOfTime = "River of Time"
}

// MARK: - Soundscape
struct Soundscape: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: SoundscapeCategory
    let type: SoundscapeType
    let duration: Int? // nil = loops
    var volume: Float
    let isMixable: Bool

    init(name: String, category: SoundscapeCategory, type: SoundscapeType, duration: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.type = type
        self.duration = duration
        self.volume = 0.7
        self.isMixable = true
    }
}

enum SoundscapeCategory: String, Codable, CaseIterable {
    case nature = "Nature"
    case binaural = "Binaural Beats"
    case music = "Music"
    case ambient = "Ambient"
}

enum SoundscapeType: String, Codable, CaseIterable {
    // Nature (100+)
    case rain, thunderstorm, gentleRain, tropicalRain
    case ocean, waves, creek, waterfall, river, babbling
    case forest, birds, crickets, owls, wolves
    case wind, breeze, leaves, rustling
    case fire, campfire, hearth
    case snow, icecracking, winterWind

    // Binaural Beats
    case delta, theta, alpha, beta, gamma

    // Music
    case africanDrumming, djembe, dundun, balafon
    case classicalPiano, classicalStrings, classicalHarp, classicalFlute
    case newAgeSynth, newAgePads, newAgeChimes, newAgeBowls
    case tibetanBowls, crystalBowls, gongs
    case nativeFlute, shakuhachi, sitar, tanpura

    // Ambient
    case whiteNoise, pinkNoise, brownNoise
    case silence

    var displayName: String {
        switch self {
        case .rain: return "Gentle Rain"
        case .thunderstorm: return "Distant Thunder"
        case .gentleRain: return "Soft Drizzle"
        case .tropicalRain: return "Tropical Downpour"
        case .ocean: return "Ocean Waves"
        case .waves: return "Shore Waves"
        case .creek: return "Mountain Creek"
        case .waterfall: return "Cascading Waterfall"
        case .river: return "Flowing River"
        case .babbling: return "Babbling Brook"
        case .forest: return "Deep Forest"
        case .birds: return "Dawn Chorus"
        case .crickets: return "Evening Crickets"
        case .owls: return "Night Owls"
        case .wolves: return "Distant Wolves"
        case .wind: return "Mountain Wind"
        case .breeze: return "Gentle Breeze"
        case .leaves: return "Rustling Leaves"
        case .rustling: return "Forest Floor"
        case .fire: return "Crackling Fire"
        case .campfire: return "Campfire"
        case .hearth: return "Warm Hearth"
        case .snow: return "Falling Snow"
        case .icecracking: return "Arctic Ice"
        case .winterWind: return "Winter Wind"
        case .delta: return "Delta Waves (0.5-4 Hz)"
        case .theta: return "Theta Waves (4-8 Hz)"
        case .alpha: return "Alpha Waves (8-13 Hz)"
        case .beta: return "Beta Waves (13-30 Hz)"
        case .gamma: return "Gamma Waves (30+ Hz)"
        case .africanDrumming: return "African Drumming"
        case .djembe: return "Djembe Rhythms"
        case .dundun: return "Dundun Bass"
        case .balafon: return "Balafon Melody"
        case .classicalPiano: return "Classical Piano"
        case .classicalStrings: return "String Ensemble"
        case .classicalHarp: return "Ethereal Harp"
        case .classicalFlute: return "Silver Flute"
        case .newAgeSynth: return "Ethereal Synth"
        case .newAgePads: return "Ambient Pads"
        case .newAgeChimes: return "Wind Chimes"
        case .newAgeBowls: return "Sound Bath"
        case .tibetanBowls: return "Tibetan Singing Bowls"
        case .crystalBowls: return "Crystal Singing Bowls"
        case .gongs: return "Sacred Gongs"
        case .nativeFlute: return "Native Flute"
        case .shakuhachi: return "Shakuhachi"
        case .sitar: return "Sitar Meditation"
        case .tanpura: return "Tanpura Drone"
        case .whiteNoise: return "White Noise"
        case .pinkNoise: return "Pink Noise"
        case .brownNoise: return "Brown Noise"
        case .silence: return "Silence"
        }
    }
}

// MARK: - Coaching Session
struct CoachingSession: Identifiable, Codable {
    let id: UUID
    let type: CoachingSessionType
    let scheduledDate: Date
    let duration: Int // minutes
    var status: SessionStatus
    var notes: String
    var wins: [String]
    var actionItems: [String]
    var strengthsObserved: [String]

    enum CoachingSessionType: String, Codable {
        case lifeCoaching = "Life Coaching"
        case executiveCoaching = "Executive Coaching"
        case breathingInstruction = "Breathing Instruction"
        case meditationInstruction = "Meditation Instruction"
        case yogaNidraSession = "Yoga Nidra Session"
    }

    enum SessionStatus: String, Codable {
        case scheduled, inProgress, completed, cancelled
    }

    init(type: CoachingSessionType, date: Date, duration: Int = 45) {
        self.id = UUID()
        self.type = type
        self.scheduledDate = date
        self.duration = duration
        self.status = .scheduled
        self.notes = ""
        self.wins = []
        self.actionItems = []
        self.strengthsObserved = []
    }
}
