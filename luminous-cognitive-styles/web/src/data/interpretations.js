const interpretations = {
  'perceptual-mode': {
    low: {
      range: 'Analytic (1-3)',
      homeTerritory:
        'You naturally perceive the world through a lens of precision and differentiation. Your mind instinctively breaks complex wholes into their component parts, noticing details, sequences, and logical structures that others miss. You are the person who spots the typo, catches the logical flaw, and remembers the specific data point.',
      strengths: [
        'Exceptional attention to detail and accuracy',
        'Strong logical and sequential reasoning',
        'Ability to isolate variables and troubleshoot systematically',
        'Precise communication and clear definitions',
        'Excellence in tasks requiring careful differentiation',
      ],
      growthEdges: [
        'May sometimes miss the forest for the trees',
        'Can feel overwhelmed when forced to make decisions without complete information',
        'May undervalue intuitive or gestalt-based insights',
        'Could benefit from practicing big-picture synthesis',
      ],
      famousExamples: [
        'Marie Curie — meticulous experimental precision',
        'Sherlock Holmes (fictional) — detail-oriented deduction',
        'Ada Lovelace — analytic mathematical vision',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You have genuine access to both analytic and holistic perception, shifting fluidly depending on context. You can zoom in on details when precision matters and zoom out to see patterns when context matters. This flexibility is a significant cognitive asset, though you may sometimes feel uncertain about which mode to trust.',
      strengths: [
        'Cognitive flexibility across perceptual modes',
        'Ability to bridge detail-oriented and big-picture thinkers',
        'Natural mediator between analytic and holistic perspectives',
        'Comfort with both structured and unstructured information',
        'Versatile problem-solving approach',
      ],
      growthEdges: [
        'May occasionally feel pulled between competing perceptual modes',
        'Could deepen expertise in one mode for specialized tasks',
        'Might benefit from consciously choosing which mode to deploy',
        'Risk of being a generalist without developing either mode fully',
      ],
      famousExamples: [
        'Leonardo da Vinci — mastered both detailed anatomy and holistic composition',
        'Charles Darwin — combined meticulous observation with grand theory',
        'Angela Merkel — balanced analytical rigor with contextual awareness',
      ],
    },
    high: {
      range: 'Holistic (7-10)',
      homeTerritory:
        'You naturally perceive the world as an interconnected whole. Your mind grasps patterns, contexts, and the overall gestalt of a situation before attending to specifics. You are the person who senses the mood of a room, sees the emerging trend before it becomes obvious, and understands how all the pieces fit together.',
      strengths: [
        'Powerful pattern recognition across complex systems',
        'Strong contextual and situational awareness',
        'Intuitive grasp of relationships and dynamics',
        'Ability to see emerging trends and possibilities',
        'Excellence in strategic and systems thinking',
      ],
      growthEdges: [
        'May overlook important details or specific data points',
        'Can struggle with tasks requiring sequential, step-by-step analysis',
        'May have difficulty communicating insights to analytic thinkers',
        'Could benefit from developing more systematic verification habits',
      ],
      famousExamples: [
        'Steve Jobs — holistic product vision and aesthetic sense',
        'Maya Angelou — contextual, atmospheric perception in writing',
        'Marshall McLuhan — saw media and culture as interconnected wholes',
      ],
    },
  },
  'processing-rhythm': {
    low: {
      range: 'Deliberative (1-3)',
      homeTerritory:
        'Your mind operates at a measured, reflective tempo. You naturally pause before responding, weigh multiple factors carefully, and prefer to arrive at considered conclusions rather than snap judgments. Your thoughts deepen with time — your best insights often emerge hours or days after an experience.',
      strengths: [
        'Thorough and careful decision-making',
        'Deep, nuanced analysis of complex situations',
        'Reduced susceptibility to cognitive biases and impulsive errors',
        'Excellent at long-term strategic planning',
        'High-quality output that reflects careful consideration',
      ],
      growthEdges: [
        'May miss opportunities that require quick action',
        'Can be perceived as indecisive or slow by faster-paced colleagues',
        'May over-analyze situations that call for immediate response',
        'Could benefit from practicing comfortable imperfection in low-stakes decisions',
      ],
      famousExamples: [
        'Abraham Lincoln — known for careful, deliberate decision-making',
        'Jane Austen — slow, meticulous craftsmanship in writing',
        'Warren Buffett — patient, deliberate investment philosophy',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You can shift between deliberative and spontaneous processing depending on what the situation demands. You know when to pause and reflect and when to trust your gut and act quickly. This adaptive rhythm serves you well across diverse contexts.',
      strengths: [
        'Situational awareness of when to act fast vs. slow down',
        'Effective in both fast-paced and reflective environments',
        'Can match the tempo of diverse collaborators',
        'Good calibration of how much thought a decision requires',
        'Flexible response style across varied demands',
      ],
      growthEdges: [
        'May occasionally misjudge the tempo a situation requires',
        'Could feel internal tension between wanting to reflect and needing to act',
        'Might benefit from more deliberately choosing processing speed',
        'Risk of defaulting to one mode under stress',
      ],
      famousExamples: [
        'Barack Obama — deliberate on policy, spontaneous in conversation',
        'Oprah Winfrey — blends preparation with in-the-moment responsiveness',
        'Satya Nadella — combines careful strategy with agile execution',
      ],
    },
    high: {
      range: 'Spontaneous (7-10)',
      homeTerritory:
        'Your mind operates at a rapid, intuitive tempo. You trust your immediate responses, think well on your feet, and thrive in dynamic, fast-moving situations. Your first instinct is often remarkably accurate, drawing on deep pattern recognition that operates below conscious awareness.',
      strengths: [
        'Rapid, confident decision-making',
        'Excellence in dynamic, fast-changing environments',
        'Strong intuitive pattern recognition',
        'Natural improvisational ability',
        'Energizing presence that drives momentum and action',
      ],
      growthEdges: [
        'May sometimes act before fully understanding a situation',
        'Can be perceived as impulsive or insufficiently thoughtful',
        'May undervalue the contributions of slower, more deliberate thinkers',
        'Could benefit from building in reflection pauses for high-stakes decisions',
      ],
      famousExamples: [
        'Winston Churchill — rapid, decisive action in crisis',
        'Robin Williams — lightning-fast improvisational genius',
        'Elon Musk — rapid-fire ideation and decision-making tempo',
      ],
    },
  },
  'generative-orientation': {
    low: {
      range: 'Convergent (1-3)',
      homeTerritory:
        'Your thinking naturally narrows toward the single best answer. You excel at evaluation, prioritization, and finding the optimal solution among alternatives. You bring discipline and focus to creative processes, ensuring that good ideas become great through refinement and critical analysis.',
      strengths: [
        'Excellent critical evaluation and judgment',
        'Strong prioritization and decision-making',
        'Ability to refine ideas to a high level of quality',
        'Efficient use of cognitive resources — focus on what matters',
        'Excellence in optimization and continuous improvement',
      ],
      growthEdges: [
        'May dismiss novel ideas too quickly',
        'Can feel uncomfortable with open-ended brainstorming',
        'May inadvertently shut down creative exploration in groups',
        'Could benefit from suspending judgment during early ideation',
      ],
      famousExamples: [
        'Jeff Bezos — relentless optimization and convergent focus',
        'Jony Ive — refined, converged design excellence',
        'Simone Biles — convergent mastery through focused refinement',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You move naturally between generating possibilities and evaluating them. You understand that creativity requires both divergent exploration and convergent refinement, and you can shift between these modes with relative ease.',
      strengths: [
        'Complete creative process — both generation and evaluation',
        'Natural sense of when to expand options and when to narrow',
        'Effective facilitator of creative group processes',
        'Balanced innovation that is both novel and practical',
        'Ability to bridge visionaries and implementers',
      ],
      growthEdges: [
        'May not go deep enough in either divergent or convergent mode',
        'Could feel torn between exploring more and deciding now',
        'Might benefit from explicitly labeling which mode you are in',
        'Risk of compromising between good enough ideas rather than finding the best',
      ],
      famousExamples: [
        'Walt Disney — famous for alternating between dreamer, realist, and critic',
        'Marie Kondo — generates organizational visions then converges on essentials',
        'Lin-Manuel Miranda — wild creative divergence refined through disciplined craft',
      ],
    },
    high: {
      range: 'Divergent (7-10)',
      homeTerritory:
        'Your thinking naturally expands outward, making unexpected connections and generating a rich abundance of ideas. You see possibilities where others see dead ends, find links between seemingly unrelated domains, and delight in the creative potential of every situation.',
      strengths: [
        'Prolific idea generation and creative output',
        'Ability to make novel, unexpected connections',
        'Comfort with ambiguity and open-ended exploration',
        'Natural innovation and originality',
        'Energizing brainstorming partner and creative catalyst',
      ],
      growthEdges: [
        'May struggle to commit to a single direction',
        'Can feel frustrated by the constraints of implementation',
        'May overwhelm others with too many ideas simultaneously',
        'Could benefit from developing stronger convergent discipline',
      ],
      famousExamples: [
        'Salvador Dali — wildly divergent artistic imagination',
        'Richard Feynman — playful, divergent scientific creativity',
        'Bjork — boundary-defying creative exploration across media',
      ],
    },
  },
  'representational-channel': {
    low: {
      range: 'Verbal-Symbolic (1-3)',
      homeTerritory:
        'Your inner world is primarily linguistic and symbolic. You think in words, reason through internal dialogue, and process experience through the medium of language. Abstract concepts, logical structures, and formal systems feel natural to you. Your thinking is precise, articulable, and often highly structured.',
      strengths: [
        'Precise, articulate communication',
        'Strong logical and analytical reasoning',
        'Excellence with abstract concepts and formal systems',
        'Ability to construct and follow complex arguments',
        'Natural aptitude for writing, coding, and symbolic manipulation',
      ],
      growthEdges: [
        'May struggle with purely visual or spatial tasks',
        'Can over-rely on verbal processing for problems better suited to imagery',
        'May find it difficult to communicate with strong visual thinkers',
        'Could benefit from developing mental imagery and visualization skills',
      ],
      famousExamples: [
        'Noam Chomsky — language-centered cognition and analysis',
        'Ruth Bader Ginsburg — precise legal-verbal reasoning',
        'Jorge Luis Borges — thinking through pure language and symbol',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You have access to both verbal-symbolic and imagistic-spatial channels of thought. You can reason through words and logic when needed, and shift to mental imagery and spatial thinking when that serves better. This dual channel gives you a rich inner cognitive life.',
      strengths: [
        'Multimodal thinking and problem-solving',
        'Can translate between verbal and visual representations',
        'Effective communication with diverse cognitive styles',
        'Rich inner life combining words, images, and spatial sense',
        'Versatile learning and processing across formats',
      ],
      growthEdges: [
        'May not develop either channel to its fullest potential',
        'Could feel uncertain about which representational mode to trust',
        'Might benefit from deliberately practicing each mode',
        'May occasionally mix modes in ways that create confusion',
      ],
      famousExamples: [
        'Oliver Sacks — combined clinical verbal precision with rich imagery',
        'Hayao Miyazaki — verbal storytelling fused with visual imagination',
        'Carl Sagan — moved fluently between scientific language and cosmic imagery',
      ],
    },
    high: {
      range: 'Imagistic-Spatial (7-10)',
      homeTerritory:
        'Your inner world is primarily visual, spatial, and sensory. You think in pictures, mental models, and felt impressions. Complex information becomes three-dimensional landscapes in your mind. You can rotate objects mentally, see solutions as spatial relationships, and experience ideas as vivid internal images.',
      strengths: [
        'Powerful visual imagination and mental modeling',
        'Strong spatial reasoning and three-dimensional thinking',
        'Intuitive understanding of complex systems through visualization',
        'Natural aptitude for design, architecture, and visual arts',
        'Ability to see solutions that verbal reasoning alone would miss',
      ],
      growthEdges: [
        'May struggle to articulate visual insights in words',
        'Can find purely verbal or textual learning frustrating',
        'May be underestimated in environments that privilege verbal intelligence',
        'Could benefit from developing verbal translation skills for your visual ideas',
      ],
      famousExamples: [
        'Nikola Tesla — thought in vivid, detailed mental images',
        'Frida Kahlo — processed experience through powerful visual imagery',
        'Temple Grandin — thinks in pictures, advocates for visual thinking',
      ],
    },
  },
  'relational-orientation': {
    low: {
      range: 'Autonomous (1-3)',
      homeTerritory:
        'Your cognitive process is fundamentally independent. You do your deepest, most original thinking alone, forming complete ideas through internal reasoning before sharing them. Solitude is not just pleasant for you — it is cognitively necessary. Your best work emerges from uninterrupted internal processing.',
      strengths: [
        'Deep, independent thinking unconstrained by group dynamics',
        'Strong personal conviction and intellectual integrity',
        'Ability to resist groupthink and social pressure',
        'Excellence in focused, solitary creative work',
        'Original perspectives developed through internal reflection',
      ],
      growthEdges: [
        'May miss valuable perspectives from others',
        'Can be perceived as aloof or disinterested in collaboration',
        'May not benefit enough from the cognitive advantages of dialogue',
        'Could benefit from structured practices of intellectual exchange',
      ],
      famousExamples: [
        'Emily Dickinson — produced brilliance in deep solitude',
        'Isaac Newton — major discoveries made in isolated concentration',
        'Greta Thunberg — autonomous conviction driving independent action',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You move between independent and collaborative cognition with relative ease. Sometimes you need solitude to think deeply; other times, dialogue sparks your best ideas. You understand that different problems benefit from different social configurations of thought.',
      strengths: [
        'Flexible cognitive social style',
        'Can work productively both alone and in teams',
        'Natural understanding of when to collaborate and when to retreat',
        'Effective at both independent analysis and group brainstorming',
        'Can serve as bridge between autonomous and connected thinkers',
      ],
      growthEdges: [
        'May not have strong enough solitary practice for deep work',
        'Could under-invest in collaborative relationships that spark insight',
        'Might benefit from more intentional structuring of solo vs. social thinking',
        'Risk of defaulting to one mode without realizing it',
      ],
      famousExamples: [
        'Einstein — alternated between solitary thought experiments and lively dialogue',
        'Toni Morrison — drew on communal stories, crafted in solitude',
        'Stewart Brand — combined independent vision with collaborative networks',
      ],
    },
    high: {
      range: 'Connected (7-10)',
      homeTerritory:
        'Your thinking is fundamentally relational. Ideas come alive for you in dialogue — through teaching, debating, sharing, and building on others insights. You do not simply benefit from social exchange; your cognitive process itself is social. Conversation is not distraction from thinking — it is thinking.',
      strengths: [
        'Exceptional collaborative intelligence',
        'Ability to synthesize diverse perspectives rapidly',
        'Natural teaching and mentoring ability that deepens understanding',
        'Strong interpersonal sensitivity in cognitive contexts',
        'Excellence in team-based creative and analytical work',
      ],
      growthEdges: [
        'May struggle to develop ideas fully in isolation',
        'Can be overly influenced by others opinions and perspectives',
        'May not invest enough in solitary deep work',
        'Could benefit from practices that strengthen independent analysis',
      ],
      famousExamples: [
        'Socrates — developed philosophy entirely through dialogue',
        'The Beatles — creative genius through relational collaboration',
        'bell hooks — thinking inseparable from community and relationship',
      ],
    },
  },
  'somatic-integration': {
    low: {
      range: 'Cerebral (1-3)',
      homeTerritory:
        'Your thinking lives primarily in the realm of the abstract and intellectual. You reason through logic, language, and formal analysis — the body is more of a vehicle that carries your brain around than an active participant in your thinking. This cerebral mode gives you powerful analytical capabilities unclouded by emotional or physical noise.',
      strengths: [
        'Clear, logical analysis unswayed by physical or emotional states',
        'Strong abstract reasoning and formal thinking',
        'Ability to maintain objectivity and intellectual detachment',
        'Excellence in theoretical and conceptual work',
        'Consistent cognitive performance across physical states',
      ],
      growthEdges: [
        'May ignore valuable bodily signals and intuitions',
        'Can experience burnout from disconnection between mind and body',
        'May miss emotional and somatic intelligence in decision-making',
        'Could benefit from developing interoceptive awareness practices',
      ],
      famousExamples: [
        'Immanuel Kant — pure reason, famously rigid daily routines',
        'Alan Turing — abstract mathematical cognition',
        'Simone de Beauvoir — intellectual analysis transcending embodied experience',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You have a working relationship between your intellectual and somatic processes. You can think abstractly when needed and also tune into bodily wisdom when it is available. You recognize that both modes offer valuable information, though you may not always integrate them seamlessly.',
      strengths: [
        'Access to both intellectual and somatic intelligence',
        'Ability to check analytical conclusions against gut feelings',
        'Versatile response to situations requiring either mode',
        'Growing capacity to integrate mind and body in decision-making',
        'Openness to both cerebral and embodied approaches',
      ],
      growthEdges: [
        'May not fully trust or develop somatic awareness',
        'Could experience conflict between head and gut signals',
        'Might benefit from more deliberate somatic practices',
        'Integration may require conscious effort rather than flowing naturally',
      ],
      famousExamples: [
        'Yo-Yo Ma — intellectual mastery expressed through physical artistry',
        'Temple Grandin — combines analytical mind with acute sensory awareness',
        'Brene Brown — bridges intellectual research with emotional-somatic honesty',
      ],
    },
    high: {
      range: 'Embodied (7-10)',
      homeTerritory:
        'Your body is a full participant in your thinking. You naturally integrate physical sensations, gut feelings, energetic shifts, and somatic signals into your cognitive process. For you, thinking is not just a brain activity — it involves your whole organism. You trust your body as a source of genuine intelligence.',
      strengths: [
        'Rich somatic intelligence informing decisions',
        'Strong interoceptive awareness and emotional attunement',
        'Natural integration of physical and intellectual knowing',
        'Excellence in embodied practices — movement, craft, performance',
        'Holistic decision-making drawing on the full range of human intelligence',
      ],
      growthEdges: [
        'May struggle in environments that dismiss bodily knowing',
        'Can find it difficult to articulate somatic insights logically',
        'May be overwhelmed by physical-emotional sensitivity',
        'Could benefit from developing analytical skills to complement somatic wisdom',
      ],
      famousExamples: [
        'Martha Graham — cognition expressed through movement',
        'Jimi Hendrix — thinking through the body and instrument',
        'Thich Nhat Hanh — embodied awareness as a way of knowing',
      ],
    },
  },
  'complexity-tolerance': {
    low: {
      range: 'Closure-Seeking (1-3)',
      homeTerritory:
        'You are energized by clarity, resolution, and definitive answers. Ambiguity feels uncomfortable, and you naturally drive toward conclusions, decisions, and clear categories. This orientation gives you tremendous power to get things done, create order from chaos, and bring projects to completion.',
      strengths: [
        'Decisive action and clear direction',
        'Excellent project completion and follow-through',
        'Ability to create clarity and structure for teams',
        'Strong organizational and categorical thinking',
        'Efficiency in moving from analysis to action',
      ],
      growthEdges: [
        'May reach premature closure on complex issues',
        'Can feel anxious or frustrated when answers are not forthcoming',
        'May oversimplify nuanced or paradoxical situations',
        'Could benefit from practicing comfort with not-knowing',
      ],
      famousExamples: [
        'Margaret Thatcher — decisive, clarity-seeking leadership',
        'James Watson — driven toward definitive answers in science',
        'Martha Stewart — order, clarity, and definitive standards',
      ],
    },
    mid: {
      range: 'Balanced (4-6)',
      homeTerritory:
        'You can tolerate ambiguity when needed while also valuing closure when it is time to decide. You understand that some situations call for sitting with uncertainty and others call for decisive action. This balance serves you well in a complex world.',
      strengths: [
        'Adaptive relationship with ambiguity and certainty',
        'Can sit with uncertainty without becoming paralyzed',
        'Able to make decisions when needed without premature closure',
        'Effective in both well-defined and ambiguous situations',
        'Natural sense of when to push for closure and when to wait',
      ],
      growthEdges: [
        'May not develop deep comfort with truly radical ambiguity',
        'Could sometimes waver between wanting closure and allowing openness',
        'Might benefit from intentionally challenging comfort zone in both directions',
        'Risk of staying in comfortable middle without stretching either capacity',
      ],
      famousExamples: [
        'Nelson Mandela — balanced patience with decisive action',
        'Marie Curie — tolerated scientific uncertainty while driving toward discovery',
        'Ursula Le Guin — embraced ambiguity in fiction while crafting structured narratives',
      ],
    },
    high: {
      range: 'Ambiguity-Embracing (7-10)',
      homeTerritory:
        'You are genuinely comfortable with paradox, contradiction, and unresolved complexity. Where others feel anxious about uncertainty, you feel curious and alive. You can hold multiple competing truths simultaneously, resist premature simplification, and allow meaning to emerge organically over time.',
      strengths: [
        'Deep comfort with uncertainty and paradox',
        'Ability to hold complexity without oversimplifying',
        'Openness to emergent, non-linear understanding',
        'Excellence in navigating truly ambiguous, novel situations',
        'Capacity for nuanced, multi-perspectival thinking',
      ],
      growthEdges: [
        'May have difficulty making decisions when clarity is actually needed',
        'Can be perceived as indecisive or overly philosophical',
        'May frustrate closure-seeking collaborators',
        'Could benefit from developing stronger commitment and follow-through skills',
      ],
      famousExamples: [
        'Rainer Maria Rilke — "Live the questions"',
        'Keats — Negative Capability, comfort with uncertainty',
        'Nassim Taleb — embraces randomness and the limits of knowledge',
      ],
    },
  },
};

export const getInterpretation = (dimensionId, score) => {
  const dim = interpretations[dimensionId];
  if (!dim) return null;
  if (score <= 3) return dim.low;
  if (score <= 6) return dim.mid;
  return dim.high;
};

export const getInterpretationLevel = (score) => {
  if (score <= 3) return 'low';
  if (score <= 6) return 'mid';
  return 'high';
};

export default interpretations;
