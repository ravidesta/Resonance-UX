/**
 * Book Catalog — Structured content definitions for the Luminous Integral Architecture library.
 *
 * Provides factory functions that assemble [Book] instances with their full
 * chapter/section hierarchy, interactive exercises, and audio segment metadata.
 * Content here is static seed data; runtime user-generated annotations live
 * in the reader state layer.
 */
package com.luminous.resonance.content

import com.luminous.resonance.model.*

/**
 * Central catalog of all books available in the Luminous ecosystem.
 */
object BookCatalog {

    /** Returns the complete list of available books. */
    fun allBooks(): List<Book> = listOf(
        luminousIntegralArchitecture(),
    )

    /** Retrieve a book by its [ContentId]. */
    fun bookById(id: ContentId): Book? = allBooks().firstOrNull { it.id == id }

    // ──────────────────────────────────────────────
    // Luminous Integral Architecture™
    // ──────────────────────────────────────────────

    private fun luminousIntegralArchitecture(): Book = Book(
        id = ContentId("book-lia-001"),
        title = "Luminous Integral Architecture™",
        subtitle = "Design as a Developmental Practice",
        authors = listOf("Resonance Collective"),
        coverImageUrl = "covers/lia_cover.webp",
        parts = listOf(
            partOneFoundations(),
            partTwoResonance(),
            partThreeIntegration(),
        ),
        glossary = coreGlossary(),
        totalAudioDurationMs = 14_400_000L, // ~4 hours
    )

    // ── Part I ────────────────────────────────────

    private fun partOneFoundations(): Part = Part(
        id = ContentId("part-001"),
        number = 1,
        title = "Foundations",
        epigraph = "\"The eye through which I see God is the same eye through which God sees me.\" — Meister Eckhart",
        chapters = listOf(
            Chapter(
                id = ContentId("ch-001"),
                number = 1,
                title = "The Integral Impulse",
                subtitle = "Why Design Needs a Bigger Map",
                sections = listOf(
                    Section(
                        id = ContentId("sec-001-01"),
                        heading = "Beyond Flatland",
                        paragraphs = listOf(
                            bodyParagraph("sec-001-01-p1",
                                "Design has always carried an implicit philosophy. Every wireframe, " +
                                "every colour palette, every interaction pattern encodes assumptions " +
                                "about who users are and what they need. Most of these assumptions " +
                                "remain unexamined."
                            ),
                            bodyParagraph("sec-001-01-p2",
                                "Integral theory offers a map that honours the full spectrum of human " +
                                "experience—interior and exterior, individual and collective. When we " +
                                "apply this map to design, we stop reducing people to click-streams " +
                                "and start creating environments that support genuine development."
                            ),
                        ),
                    ),
                    Section(
                        id = ContentId("sec-001-02"),
                        heading = "The Four Quadrants of Design",
                        paragraphs = listOf(
                            bodyParagraph("sec-001-02-p1",
                                "Ken Wilber's AQAL framework identifies four irreducible dimensions " +
                                "of any phenomenon. In design terms: the designer's intention (Upper " +
                                "Left), the observable interface (Upper Right), the team's shared " +
                                "culture (Lower Left), and the systemic infrastructure (Lower Right)."
                            ),
                            bodyParagraph("sec-001-02-p2",
                                "Neglecting any quadrant produces a design that is technically " +
                                "competent but existentially thin. A button can be pixel-perfect yet " +
                                "spiritually vacant. Integral design asks: does this interaction " +
                                "nourish all four dimensions?"
                            ),
                        ),
                    ),
                ),
                exercises = listOf(
                    InteractiveExercise(
                        id = ContentId("ex-001-01"),
                        type = ExerciseType.QUADRANT_MAPPING,
                        title = "Map Your Current Project",
                        prompt = "Choose a design project you are currently working on. " +
                            "Place observations in each quadrant to see where your attention concentrates " +
                            "and where blind spots may hide.",
                        quadrantMapping = QuadrantMapping(
                            topic = "Your Current Design Project",
                            upperLeft = listOf("What is my intention as designer?", "What emotional state am I designing from?"),
                            upperRight = listOf("What measurable outcomes am I targeting?", "What does the interface look like?"),
                            lowerLeft = listOf("What cultural values does the team share?", "How do users talk about this product?"),
                            lowerRight = listOf("What technical systems support this?", "What economic structures constrain it?"),
                        ),
                        estimatedDurationMinutes = 10,
                    ),
                    InteractiveExercise(
                        id = ContentId("ex-001-02"),
                        type = ExerciseType.REFLECTION_QUESTION,
                        title = "Designer's Interior",
                        prompt = "Reflect on a time when your inner state—stress, excitement, fatigue—visibly " +
                            "shaped a design decision. What would have changed if you had paused to notice " +
                            "that interior dimension before acting?",
                        estimatedDurationMinutes = 5,
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-001"),
                estimatedReadingTimeMinutes = 18,
            ),
            Chapter(
                id = ContentId("ch-002"),
                number = 2,
                title = "Developmental Altitude",
                subtitle = "Stages of Meaning-Making in Users and Designers",
                sections = listOf(
                    Section(
                        id = ContentId("sec-002-01"),
                        heading = "What Develops?",
                        paragraphs = listOf(
                            bodyParagraph("sec-002-01-p1",
                                "Human beings grow through identifiable stages of complexity in how " +
                                "they construct meaning. These stages are not value judgements—each " +
                                "is a valid home base—but they radically shape how a person experiences " +
                                "a designed environment."
                            ),
                            bodyParagraph("sec-002-01-p2",
                                "A user at a conventional stage seeks clarity, consistency, and trust " +
                                "signals. A user at a post-conventional stage seeks transparency, " +
                                "agency, and systemic awareness. Designing for only one altitude " +
                                "alienates the other."
                            ),
                        ),
                    ),
                    Section(
                        id = ContentId("sec-002-02"),
                        heading = "Designing Across Altitudes",
                        paragraphs = listOf(
                            bodyParagraph("sec-002-02-p1",
                                "The integral designer learns to create scaffolded experiences—interfaces " +
                                "that meet each user where they are while gently inviting the next step " +
                                "of complexity. This is the art of developmental design."
                            ),
                        ),
                    ),
                ),
                exercises = listOf(
                    InteractiveExercise(
                        id = ContentId("ex-002-01"),
                        type = ExerciseType.SELF_ASSESSMENT,
                        title = "Altitude Self-Check",
                        prompt = "Without judgement, consider: which description resonates most with how " +
                            "you typically approach a new design problem? There are no wrong answers.",
                        estimatedDurationMinutes = 8,
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-002"),
                estimatedReadingTimeMinutes = 15,
            ),
            Chapter(
                id = ContentId("ch-003"),
                number = 3,
                title = "States and the Felt Sense",
                subtitle = "Somatic Intelligence in the Design Process",
                sections = listOf(
                    Section(
                        id = ContentId("sec-003-01"),
                        heading = "The Body Knows",
                        paragraphs = listOf(
                            bodyParagraph("sec-003-01-p1",
                                "States of consciousness—waking, dreaming, meditative, flow—are not " +
                                "luxuries. They are lenses through which users engage with technology. " +
                                "A mindfulness app encountered during a stressed state must meet that " +
                                "reality with somatic care, not cognitive overload."
                            ),
                        ),
                    ),
                ),
                exercises = listOf(
                    InteractiveExercise(
                        id = ContentId("ex-003-01"),
                        type = ExerciseType.SOMATIC_PRACTICE,
                        title = "Grounding Before Design",
                        prompt = "A brief somatic check-in to bring embodied awareness to your design work.",
                        guidedSteps = listOf(
                            GuidedStep(1, "Sit comfortably. Close your eyes or soften your gaze.", 10),
                            GuidedStep(2, "Take three slow breaths, lengthening the exhale.", 20),
                            GuidedStep(3, "Scan from the crown of your head to the soles of your feet. Notice areas of tension.", 30),
                            GuidedStep(4, "Place one hand on your chest. Feel the rhythm of your heartbeat.", 15),
                            GuidedStep(5, "Ask yourself: what is my body's intuition about the design problem I'm holding?", 20),
                            GuidedStep(6, "Open your eyes gently. Carry this awareness into your next design session.", 5),
                        ),
                        estimatedDurationMinutes = 3,
                    ),
                    InteractiveExercise(
                        id = ContentId("ex-003-02"),
                        type = ExerciseType.GUIDED_MEDITATION,
                        title = "Flow State Invitation",
                        prompt = "A guided breathwork practice to cultivate the flow state before deep design work.",
                        guidedSteps = listOf(
                            GuidedStep(1, "Find a quiet space. Set a timer for 5 minutes.", 5),
                            GuidedStep(2, "Inhale for 4 counts through the nose.", 4),
                            GuidedStep(3, "Hold for 7 counts.", 7),
                            GuidedStep(4, "Exhale for 8 counts through the mouth.", 8),
                            GuidedStep(5, "Repeat this 4-7-8 cycle four times.", 80),
                            GuidedStep(6, "Return to natural breathing. Notice the shift in your state.", 15),
                        ),
                        audioGuideId = ContentId("audio-meditation-001"),
                        estimatedDurationMinutes = 5,
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-003"),
                estimatedReadingTimeMinutes = 12,
            ),
        ),
    )

    // ── Part II ───────────────────────────────────

    private fun partTwoResonance(): Part = Part(
        id = ContentId("part-002"),
        number = 2,
        title = "Resonance",
        epigraph = "\"Resonance is not agreement. It is the vibration that arises when truth meets readiness.\"",
        chapters = listOf(
            Chapter(
                id = ContentId("ch-004"),
                number = 4,
                title = "The Resonance Principle",
                subtitle = "When Design Meets the User's Frequency",
                sections = listOf(
                    Section(
                        id = ContentId("sec-004-01"),
                        heading = "Attunement as Design Method",
                        paragraphs = listOf(
                            bodyParagraph("sec-004-01-p1",
                                "Resonance in physics is the phenomenon where a system oscillates " +
                                "with greater amplitude at specific frequencies. In design, resonance " +
                                "occurs when an interface vibrates at the frequency of the user's " +
                                "deepest need—not their stated preference, but their developmental edge."
                            ),
                            bodyParagraph("sec-004-01-p2",
                                "This requires a different kind of listening. Not the listening of " +
                                "user interviews and analytics dashboards alone, but the listening of " +
                                "empathic attunement—feeling into the user's world."
                            ),
                        ),
                    ),
                ),
                exercises = listOf(
                    InteractiveExercise(
                        id = ContentId("ex-004-01"),
                        type = ExerciseType.REFLECTION_QUESTION,
                        title = "Resonance Audit",
                        prompt = "Think of a digital product that deeply resonated with you. What made it " +
                            "feel like it 'understood' you? Now consider: was that resonance accidental " +
                            "or designed? What principles might have guided its creators?",
                        estimatedDurationMinutes = 7,
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-004"),
                estimatedReadingTimeMinutes = 14,
            ),
            Chapter(
                id = ContentId("ch-005"),
                number = 5,
                title = "Biophilic Digital Spaces",
                subtitle = "Nature Patterns in Interface Design",
                sections = listOf(
                    Section(
                        id = ContentId("sec-005-01"),
                        heading = "The Organic Interface",
                        paragraphs = listOf(
                            bodyParagraph("sec-005-01-p1",
                                "Biophilic design translates nature's patterns into built environments. " +
                                "In the digital realm, this means breathing animations instead of " +
                                "mechanical spinners, organic colour palettes drawn from forest canopies, " +
                                "and spatial layouts that echo natural wayfinding."
                            ),
                        ),
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-005"),
                estimatedReadingTimeMinutes = 16,
            ),
            Chapter(
                id = ContentId("ch-006"),
                number = 6,
                title = "Typography as Consciousness",
                subtitle = "How Letterforms Shape Inner Experience",
                sections = listOf(
                    Section(
                        id = ContentId("sec-006-01"),
                        heading = "Serif and Soul",
                        paragraphs = listOf(
                            bodyParagraph("sec-006-01-p1",
                                "Typography is not decoration. The serif carries historical gravity; " +
                                "the sans-serif speaks modern clarity. In the Resonance system, " +
                                "Cormorant Garamond anchors contemplative content while Manrope " +
                                "carries functional interface text."
                            ),
                        ),
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-006"),
                estimatedReadingTimeMinutes = 11,
            ),
        ),
    )

    // ── Part III ──────────────────────────────────

    private fun partThreeIntegration(): Part = Part(
        id = ContentId("part-003"),
        number = 3,
        title = "Integration",
        epigraph = "\"Integration is not the absence of conflict but the capacity to hold all parts.\"",
        chapters = listOf(
            Chapter(
                id = ContentId("ch-007"),
                number = 7,
                title = "The Multiplatform Canvas",
                subtitle = "One Vision, Many Surfaces",
                sections = listOf(
                    Section(
                        id = ContentId("sec-007-01"),
                        heading = "Platform as Context, Not Constraint",
                        paragraphs = listOf(
                            bodyParagraph("sec-007-01-p1",
                                "Each platform—phone, tablet, desktop, watch, spatial headset—is not " +
                                "a limitation but a unique context for consciousness. The phone is intimate, " +
                                "the desktop is expansive, the watch is glanceable, and visionOS is immersive. " +
                                "Integral design honours each context."
                            ),
                        ),
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-007"),
                estimatedReadingTimeMinutes = 20,
            ),
            Chapter(
                id = ContentId("ch-008"),
                number = 8,
                title = "The Living System",
                subtitle = "Ecosystem Design as Developmental Practice",
                sections = listOf(
                    Section(
                        id = ContentId("sec-008-01"),
                        heading = "From Product to Ecosystem",
                        paragraphs = listOf(
                            bodyParagraph("sec-008-01-p1",
                                "A product is a thing. An ecosystem is a living system of relationships. " +
                                "The Luminous ecosystem connects reader, listener, learner, and community " +
                                "in a web of mutual support—each interaction enriching all others."
                            ),
                        ),
                    ),
                ),
                exercises = listOf(
                    InteractiveExercise(
                        id = ContentId("ex-008-01"),
                        type = ExerciseType.QUADRANT_MAPPING,
                        title = "Ecosystem Quadrant Map",
                        prompt = "Map the Luminous ecosystem through all four quadrants. Where does each " +
                            "platform surface contribute? Where are the gaps?",
                        quadrantMapping = QuadrantMapping(
                            topic = "The Luminous Ecosystem",
                            upperLeft = listOf("Reader's contemplative state", "Designer's developmental intention"),
                            upperRight = listOf("App performance metrics", "Interaction patterns observed"),
                            lowerLeft = listOf("Community shared meaning", "Cultural norms of the practice circles"),
                            lowerRight = listOf("KMP shared module architecture", "Cloud sync infrastructure"),
                        ),
                        estimatedDurationMinutes = 12,
                    ),
                ),
                audioSegmentId = ContentId("audio-ch-008"),
                estimatedReadingTimeMinutes = 22,
            ),
        ),
    )

    // ── Glossary ──────────────────────────────────

    private fun coreGlossary(): List<GlossaryTerm> = listOf(
        GlossaryTerm(
            id = ContentId("gloss-aqal"),
            term = "AQAL",
            definition = "All Quadrants, All Levels — Ken Wilber's comprehensive map of human " +
                "experience encompassing four quadrants (I, IT, WE, ITS), multiple levels " +
                "of development, lines of intelligence, states of consciousness, and types.",
            sourceChapterId = ContentId("ch-001"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-resonance"),
            term = "Resonance",
            definition = "The quality of attunement between a designed artefact and the user's " +
                "developmental centre of gravity. High resonance creates felt meaning; " +
                "low resonance creates friction or indifference.",
            sourceChapterId = ContentId("ch-004"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-biophilic"),
            term = "Biophilic Design",
            definition = "Design approach that incorporates natural forms, patterns, and processes " +
                "into built and digital environments to support human well-being.",
            sourceChapterId = ContentId("ch-005"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-altitude"),
            term = "Developmental Altitude",
            definition = "The stage or level of complexity at which a person habitually constructs " +
                "meaning. Higher altitude does not mean better—it means more inclusive.",
            sourceChapterId = ContentId("ch-002"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-somatic"),
            term = "Somatic Intelligence",
            definition = "The body's capacity for knowing, distinct from cognitive analysis. " +
                "Somatic intelligence registers design quality as felt sense—comfort, " +
                "unease, flow, or friction—before the mind forms a judgement.",
            sourceChapterId = ContentId("ch-003"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-quadrant"),
            term = "Quadrant",
            definition = "One of four irreducible perspectives on any phenomenon: Interior-Individual " +
                "(subjective), Exterior-Individual (objective), Interior-Collective " +
                "(intersubjective), Exterior-Collective (interobjective).",
            relatedTermIds = listOf(ContentId("gloss-aqal")),
            sourceChapterId = ContentId("ch-001"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-flow-state"),
            term = "Flow State",
            definition = "A state of consciousness characterised by complete absorption in an " +
                "activity, loss of self-consciousness, and intrinsic reward. Optimal UX " +
                "design creates conditions for flow.",
            sourceChapterId = ContentId("ch-003"),
        ),
        GlossaryTerm(
            id = ContentId("gloss-kmp"),
            term = "Kotlin Multiplatform (KMP)",
            definition = "A technology for sharing business logic across Android, iOS, Desktop, " +
                "and Web while preserving platform-native UI. The architectural backbone " +
                "of the Luminous ecosystem.",
            sourceChapterId = ContentId("ch-007"),
        ),
    )

    // ── Helpers ───────────────────────────────────

    private fun bodyParagraph(id: String, text: String): Paragraph = Paragraph(
        id = ContentId(id),
        type = ParagraphType.BODY,
        spans = listOf(TextSpan(text)),
    )
}
