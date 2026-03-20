// BookChapter.swift
// Luminous Cognitive Styles™
// Book content model with chapters and reading progress

import Foundation

struct BookChapter: Identifiable, Codable {
    let id: Int
    let title: String
    let subtitle: String
    let content: String
    var readingProgress: Double
    let estimatedMinutes: Int

    var isComplete: Bool { readingProgress >= 1.0 }

    static let chapters: [BookChapter] = [
        BookChapter(
            id: 1,
            title: "The Luminous Mind",
            subtitle: "An Introduction to Cognitive Styles",
            content: """
            Every mind has a signature. Not a fixed label, not a box, but a living pattern—a distinctive way of engaging \
            with the world that is as unique as a fingerprint and as dynamic as a conversation.

            For centuries, we have tried to categorize human cognition. From the ancient Greek temperaments to modern \
            personality typologies, we have sought to map the territory of the mind. Yet most of these maps have been \
            too coarse, too static, or too reductive to capture the luminous complexity of how we actually think.

            The Luminous Cognitive Styles™ framework offers something different: not a typology that sorts you into \
            a box, but a dimensional portrait that reveals your cognitive signature in all its nuance and dynamism.

            At the heart of this framework are seven fundamental dimensions of cognitive style. Each dimension \
            represents a spectrum—not a binary—along which your mind naturally operates. Your position on each \
            spectrum is not a limitation but a home base: the cognitive territory where you are most fluent, most \
            energized, and most naturally effective.

            But here is the crucial insight: you are not trapped at any point on any spectrum. Your cognitive style \
            is not your cognitive destiny. Every mind has a Home Territory, an Adaptive Range, and a Developmental \
            Edge. Understanding these three zones is the key to both self-acceptance and intentional growth.

            Your Home Territory is where you naturally operate—the cognitive modes that feel like home. Your \
            Adaptive Range encompasses the broader territory you can access with moderate effort and intention. \
            And your Developmental Edge marks the frontier of growth—the cognitive modes that feel foreign but \
            hold the greatest potential for expanding your capabilities.

            In the chapters that follow, we will explore each dimension in depth, help you discover your own \
            cognitive signature, and show you how to leverage your natural strengths while strategically \
            developing your adaptive range.

            Welcome to the luminous landscape of your own mind.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 8
        ),
        BookChapter(
            id: 2,
            title: "Perceptual Mode",
            subtitle: "Analytic ↔ Holistic",
            content: """
            Imagine walking into an unfamiliar room. One mind immediately notices the arrangement of furniture, \
            the specific titles on the bookshelf, the brand of the coffee maker on the counter. Another mind \
            takes in the room as a whole: the warmth, the lived-in quality, the sense that this is a space \
            where creative work happens.

            Both minds are perceiving accurately. But they are perceiving differently.

            The Perceptual Mode dimension captures this fundamental difference in how we initially take in and \
            organize information. At one end of the spectrum lies the Analytic orientation: a natural tendency \
            to decompose wholes into parts, to attend to details and specific features, to process information \
            sequentially and systematically.

            At the other end lies the Holistic orientation: a natural tendency to grasp patterns and gestalts, \
            to see relationships and contexts, to process information simultaneously and integratively.

            Neither orientation is superior. Analytic perception excels at precision, accuracy, and thorough \
            examination. Holistic perception excels at pattern recognition, contextual understanding, and \
            rapid sense-making in complex environments.

            The analytic mind is a microscope; the holistic mind is a wide-angle lens. The world needs both.

            In practice, your perceptual mode affects everything from how you read (details-first vs. \
            themes-first), how you learn (building from parts vs. grasping the whole), how you solve \
            problems (decomposition vs. pattern matching), and even how you communicate (precise specifics \
            vs. evocative big pictures).

            Understanding your perceptual mode is the first step toward cognitive self-awareness. It helps \
            you recognize why certain learning environments feel natural and others feel like swimming upstream. \
            It helps you choose strategies that work with your mind rather than against it. And it helps you \
            appreciate the complementary gifts of minds that perceive differently from your own.

            Exercises for developing your perceptual range:
            - If you are naturally analytic: Practice describing a scene in terms of its overall feeling before \
              noting any specific details. Try mind-mapping instead of outlining.
            - If you are naturally holistic: Practice listing five specific details about a situation before \
              forming a general impression. Try creating structured outlines before writing.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 3,
            title: "Processing Rhythm",
            subtitle: "Deliberative ↔ Spontaneous",
            content: """
            Time moves differently for different minds. Not clock time—cognitive time.

            Some minds operate like a careful chess player, thinking several moves ahead, weighing each option \
            methodically, arriving at decisions through systematic evaluation. These are the deliberative \
            processors—minds that value thoroughness, accuracy, and the confidence that comes from careful \
            consideration.

            Other minds operate like a jazz musician, responding to the moment with fluid improvisation, \
            trusting intuitive pattern recognition to guide rapid decisions. These are the spontaneous \
            processors—minds that value responsiveness, creativity, and the energy that comes from thinking \
            on one's feet.

            Your Processing Rhythm shapes how you engage with cognitive demands across time. Deliberative \
            processors often prefer to schedule dedicated thinking time, to work through problems in a \
            structured sequence, and to resist premature closure. They may appear slower but often arrive \
            at more thoroughly vetted conclusions.

            Spontaneous processors often prefer to think in the flow of action, to trust their first \
            impressions and refine them quickly, and to maintain cognitive momentum rather than pausing \
            for extended analysis. They may appear less systematic but often demonstrate remarkable \
            adaptive intelligence.

            The key insight is that neither rhythm is inherently better. The optimal processing rhythm \
            depends on the context: emergency medicine rewards spontaneous processing; legal analysis \
            rewards deliberative processing. The cognitively flexible person can shift rhythms based on \
            the demands of the situation—but everyone has a home rhythm that feels most natural.

            Understanding your processing rhythm helps you design your work environment and habits to \
            support your natural cognitive tempo. It also helps you recognize when a situation calls \
            for a rhythm outside your comfort zone, and to make that shift intentionally rather than \
            being caught off guard.

            Practice shifting your rhythm:
            - If you are naturally deliberative: Set a timer for 2 minutes and make a decision before it \
              goes off. Notice what your gut says before your analysis begins.
            - If you are naturally spontaneous: Before your next important decision, commit to sleeping on \
              it. Write down your initial impulse, then spend 30 minutes examining alternatives.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 4,
            title: "Generative Orientation",
            subtitle: "Convergent ↔ Divergent",
            content: """
            Every creative act involves two movements: expansion and contraction. We open up to possibilities, \
            then we close in on the best one. We brainstorm, then we decide. We explore, then we commit.

            But minds differ dramatically in where they feel most at home in this creative rhythm.

            Convergent thinkers are energized by the narrowing process. They love the satisfaction of \
            eliminating weak options, applying rigorous criteria, and arriving at the single best solution. \
            For them, the creative process reaches its peak at the moment of decision—when clarity emerges \
            from complexity.

            Divergent thinkers are energized by the expanding process. They love the thrill of generating \
            new possibilities, making unexpected connections, and discovering options that nobody else has \
            considered. For them, the creative process reaches its peak at the moment of generation—when \
            new ideas spark from the collision of existing ones.

            Both orientations are essential to complete creative work, but most people have a strong natural \
            preference for one phase or the other.

            The convergent mind asks: "What is the best answer?" The divergent mind asks: "What else could \
            be an answer?" Both questions are vital.

            In team settings, understanding generative orientation can prevent enormous frustration. The \
            divergent thinker who keeps introducing new ideas may appear unfocused to the convergent \
            thinker who is trying to reach closure. The convergent thinker who keeps eliminating options \
            may appear closed-minded to the divergent thinker who wants to explore further.

            Neither is right. They are operating from different generative orientations, and the best \
            outcomes typically emerge when both orientations are honored in a structured process that \
            alternates between expansion and contraction.

            Strengthen your range:
            - If you are naturally convergent: In your next brainstorming session, set a target of 20 \
              ideas before evaluating any of them. Quantity before quality.
            - If you are naturally divergent: Practice the "kill your darlings" exercise. From your last \
              ten ideas, choose only one to pursue, and articulate clear reasons for your choice.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 5,
            title: "Representational Channel",
            subtitle: "Verbal-Symbolic ↔ Imagistic-Spatial",
            content: """
            Inside the theater of the mind, what is playing? Words or images? Equations or landscapes? \
            Internal monologue or vivid sensory experience?

            The Representational Channel dimension captures the medium of your inner life—the primary \
            format in which your mind encodes, manipulates, and communicates information.

            Verbal-symbolic thinkers experience cognition primarily through language and abstract symbols. \
            Their inner life is rich with words, propositions, logical structures, and numerical relationships. \
            They think by talking (internally or externally), and they understand by translating experience \
            into language. For them, if something cannot be stated in words, it is not yet fully thought.

            Imagistic-spatial thinkers experience cognition primarily through mental imagery, spatial \
            relationships, and sensory impressions. Their inner life is rich with visual scenes, spatial \
            models, textures, and dynamic simulations. They think by visualizing, and they understand by \
            constructing internal models. For them, words are often a pale translation of a richer internal \
            experience.

            This dimension has profound implications for learning, communication, and professional strengths. \
            Verbal-symbolic thinkers typically excel in fields that require precise language, logical \
            argumentation, mathematical reasoning, and textual analysis. Imagistic-spatial thinkers \
            typically excel in fields that require design thinking, spatial reasoning, mechanical \
            understanding, and artistic expression.

            Crucially, most educational and professional environments are heavily biased toward verbal-symbolic \
            representation. This means that imagistic-spatial thinkers may have been consistently underserved \
            and undervalued—not because their thinking is less sophisticated, but because it operates in a \
            channel that is harder to standardize and assess.

            Understanding your representational channel helps you choose learning strategies that match \
            your cognitive medium, communicate more effectively by translating between channels, and \
            appreciate the genuine cognitive diversity that exists among minds.

            Expand your representational flexibility:
            - If you are naturally verbal-symbolic: Try explaining a concept using only diagrams. Practice \
              thinking in images before converting to words.
            - If you are naturally imagistic-spatial: Try articulating your visual insights in precise \
              language. Practice converting your spatial understanding into step-by-step verbal instructions.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 12
        ),
        BookChapter(
            id: 6,
            title: "Relational Orientation",
            subtitle: "Autonomous ↔ Connected",
            content: """
            Thinking is often portrayed as a solitary activity: the lone genius in the garret, the \
            philosopher in contemplation, the scientist alone in the laboratory. But this portrait, \
            while capturing one valid mode of cognition, obscures another equally powerful one: \
            thinking-in-relationship.

            The Relational Orientation dimension captures how your cognition relates to social context. \
            It is not about introversion vs. extroversion (a personality trait), but specifically about \
            how the presence and input of others affects the quality and nature of your thinking.

            Autonomous thinkers do their deepest, most original work in solitude. They may enjoy social \
            interaction, but when it comes to serious cognitive work—solving a hard problem, generating \
            creative ideas, making important decisions—they need space and silence. Input from others \
            can feel disruptive, even contaminating, to their cognitive process.

            Connected thinkers do their deepest, most original work in dialogue. They may enjoy solitude, \
            but when it comes to serious cognitive work, they need interlocutors—someone to think with, \
            to bounce ideas off, to challenge and extend their reasoning. Isolation can feel deadening \
            to their cognitive process.

            This is not a social preference; it is a cognitive architecture difference. The autonomous \
            thinker's mind is designed for deep solo processing. The connected thinker's mind is designed \
            for distributed processing across social networks.

            In practice, this means that the autonomous thinker may produce their best work in a private \
            office, while the connected thinker may produce their best work in a collaborative studio. \
            The autonomous thinker may prefer to present finished ideas, while the connected thinker \
            may prefer to develop ideas in real-time dialogue.

            Neither approach is more valid. Some of history's greatest intellectual achievements emerged \
            from solitary contemplation; others emerged from intense collaborative partnerships.

            Develop your relational range:
            - If you are naturally autonomous: Try thinking out loud with a trusted partner about an \
              important problem. Notice what new ideas emerge from the dialogue itself.
            - If you are naturally connected: Try spending a full day in solo contemplation on a single \
              problem. Journal your thoughts instead of discussing them.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 7,
            title: "Somatic Integration",
            subtitle: "Cerebral ↔ Embodied",
            content: """
            Where does your thinking happen? In your head, of course—but is that the whole story?

            The Somatic Integration dimension challenges the Cartesian assumption that cognition is \
            purely a mental affair, separate from the body. Emerging research in embodied cognition \
            reveals that for many people, the body is not merely a vehicle for the brain but an active \
            participant in the thinking process.

            Cerebral thinkers operate primarily in abstract mental space. When they think, they are \
            largely unaware of their physical state. They can think effectively in any physical position \
            or environment. Their body is a faithful servant of the mind, carrying it where it needs to \
            go but contributing little to the cognitive process itself.

            Embodied thinkers integrate physical sensation, movement, and bodily awareness into their \
            cognitive process. When they think, their body thinks too—through gut feelings, kinesthetic \
            intuitions, postural shifts, and movement patterns. They may think best while walking, \
            need to gesture while explaining complex ideas, or experience important insights as physical \
            sensations before they become conscious thoughts.

            This dimension has significant implications for learning environments and work design. \
            Embodied thinkers may struggle in traditional sit-still-and-listen educational settings—not \
            because they cannot focus, but because their cognitive system requires physical engagement \
            to function optimally.

            Understanding your level of somatic integration helps you create optimal conditions for \
            your best thinking. If you are an embodied thinker, giving yourself permission to move, \
            gesture, and attend to physical sensations while thinking is not a distraction—it is a \
            cognitive strategy.

            Practices for somatic exploration:
            - If you are naturally cerebral: Try a walking meditation focused on bodily sensation. \
              Before your next important decision, pause and notice what your body is telling you.
            - If you are naturally embodied: Try sitting completely still while solving a cognitive \
              problem. Notice how the constraint affects your thinking and what adaptations you develop.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 8,
            title: "Complexity Tolerance",
            subtitle: "Closure-Seeking ↔ Ambiguity-Embracing",
            content: """
            Some minds are built for certainty. Others are built for mystery.

            The Complexity Tolerance dimension captures your relationship with ambiguity, uncertainty, \
            and unresolved tension. It is perhaps the most consequential dimension for navigating our \
            increasingly complex world, where clear answers are rare and the ability to operate \
            effectively amid uncertainty is a crucial cognitive skill.

            Closure-seeking thinkers experience a strong drive toward resolution. Unanswered questions \
            create genuine cognitive discomfort—a tension that motivates persistent effort toward clarity \
            and completion. These thinkers excel at bringing projects to conclusion, making definitive \
            decisions, and creating order from chaos.

            Ambiguity-embracing thinkers experience a natural comfort with unresolved complexity. \
            Open questions create curiosity rather than discomfort—an energy that sustains exploration \
            and prevents premature closure. These thinkers excel at navigating uncertain environments, \
            holding multiple competing hypotheses, and discovering novel solutions that emerge only \
            after prolonged engagement with complexity.

            The tension between these orientations plays out in virtually every domain: in science \
            (the drive to publish results vs. the patience to pursue long-term inquiries), in business \
            (the pressure to decide vs. the wisdom to wait for more information), in relationships \
            (the desire for clear commitment vs. the comfort with evolving dynamics).

            Neither orientation is superior, but they create very different cognitive landscapes. \
            Closure-seeking thinkers may sometimes close too quickly, missing important nuances. \
            Ambiguity-embracing thinkers may sometimes remain open too long, missing the window for action.

            The wisest path involves understanding your natural orientation and developing the ability \
            to intentionally shift when the situation demands it.

            Expand your complexity tolerance:
            - If you are naturally closure-seeking: Practice sitting with an unresolved question for \
              a full week without trying to answer it. Journal about the experience of not-knowing.
            - If you are naturally ambiguity-embracing: Practice making a firm decision within 24 hours \
              on something you would normally leave open. Notice the relief and the cost.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 10
        ),
        BookChapter(
            id: 9,
            title: "Your Cognitive Signature",
            subtitle: "Integration, Growth, and the Luminous Path",
            content: """
            You have now explored all seven dimensions of your cognitive style. You have a map—not a \
            complete one, because no map is ever complete, but a useful one.

            Your cognitive signature is the unique pattern formed by your positions across all seven \
            dimensions. It is not a type; it is a landscape. And like all landscapes, it has peaks \
            and valleys, well-worn paths and unexplored territories.

            The purpose of knowing your cognitive signature is threefold:

            First, self-acceptance. Your cognitive style is not a flaw to be corrected but a design \
            to be understood. The analytic mind is not broken because it doesn't see big pictures easily. \
            The spontaneous mind is not flawed because it doesn't plan methodically. Each style represents \
            a genuine cognitive adaptation—a way of engaging with the world that has real strengths.

            Second, strategic leverage. Once you understand your cognitive signature, you can intentionally \
            put yourself in situations that play to your strengths. You can choose learning strategies, \
            work environments, collaborative partnerships, and creative processes that align with your \
            natural cognitive architecture.

            Third, intentional growth. Your cognitive signature includes not only your Home Territory \
            (where you naturally operate) but also your Adaptive Range (where you can operate with effort) \
            and your Developmental Edge (where growth is possible but challenging). Understanding all \
            three zones allows you to grow strategically—expanding your range without abandoning your base.

            The Luminous Cognitive Styles framework is not about putting people in boxes. It is about \
            illuminating the beautiful diversity of human minds and giving each person the self-knowledge \
            they need to think at their best.

            Your mind is luminous. Let it shine in its own distinctive way.

            Going Forward:
            - Revisit your profile regularly. Cognitive styles can shift with life experience and practice.
            - Share the framework with people you work and live with. Understanding cognitive diversity \
              transforms relationships.
            - Use the coaching features of this app to develop specific dimensions intentionally.
            - Remember: the goal is not to change who you are, but to expand what you can do.

            The journey of cognitive self-discovery is lifelong. This is just the beginning.
            """,
            readingProgress: 0.0,
            estimatedMinutes: 12
        ),
    ]
}
