export const dimensions = [
  {
    id: 'perceptual-mode',
    name: 'Perceptual Mode',
    lowLabel: 'Analytic',
    highLabel: 'Holistic',
    color: '#4FC3F7',
    colorName: 'Crystal Blue',
    icon: 'Eye',
    description:
      'Perceptual Mode describes how you initially take in and organize information from the world around you. Analytic perceivers naturally decompose experiences into discrete parts, noticing details, sequences, and logical structures. Holistic perceivers grasp patterns, contexts, and the gestalt of a situation before attending to specifics. Neither is superior — analysts excel at precision and troubleshooting, while holists excel at pattern recognition and contextual understanding. Most people can access both modes but have a natural home territory on this spectrum.',
    questions: [
      {
        id: 'pm-1',
        text: 'When entering a new environment, I first notice specific details rather than the overall atmosphere.',
        reversed: false,
      },
      {
        id: 'pm-2',
        text: 'I prefer to understand each component of a system before grasping the whole picture.',
        reversed: false,
      },
      {
        id: 'pm-3',
        text: 'When reading, I naturally focus on the overarching themes and narrative arc rather than individual facts.',
        reversed: true,
      },
      {
        id: 'pm-4',
        text: 'I find it easier to spot what is different or out of place than to sense the mood of a group.',
        reversed: false,
      },
      {
        id: 'pm-5',
        text: 'When someone describes a problem, I instinctively see how it connects to the broader context before analyzing its parts.',
        reversed: true,
      },
    ],
  },
  {
    id: 'processing-rhythm',
    name: 'Processing Rhythm',
    lowLabel: 'Deliberative',
    highLabel: 'Spontaneous',
    color: '#FFB74D',
    colorName: 'Amber Gold',
    icon: 'Clock',
    description:
      'Processing Rhythm captures the tempo at which you naturally move from perception to action. Deliberative processors prefer to pause, reflect, and consider before responding — they value accuracy and thoroughness. Spontaneous processors trust their rapid, intuitive responses and thrive in fast-moving situations. Deliberative thinkers bring rigor and care; spontaneous thinkers bring agility and flow. Your rhythm affects how you make decisions, respond to deadlines, and navigate uncertainty.',
    questions: [
      {
        id: 'pr-1',
        text: 'I prefer to sleep on important decisions rather than decide in the moment.',
        reversed: false,
      },
      {
        id: 'pr-2',
        text: 'I often trust my first instinct and act on it quickly.',
        reversed: true,
      },
      {
        id: 'pr-3',
        text: 'I tend to gather extensive information before committing to a course of action.',
        reversed: false,
      },
      {
        id: 'pr-4',
        text: 'In conversations, my best responses come to me immediately rather than after reflection.',
        reversed: true,
      },
      {
        id: 'pr-5',
        text: 'I feel uncomfortable when pressed to make quick decisions without time to think them through.',
        reversed: false,
      },
    ],
  },
  {
    id: 'generative-orientation',
    name: 'Generative Orientation',
    lowLabel: 'Convergent',
    highLabel: 'Divergent',
    color: '#66BB6A',
    colorName: 'Emerald',
    icon: 'Lightbulb',
    description:
      'Generative Orientation describes whether your thinking naturally narrows toward single best answers or expands toward multiple possibilities. Convergent thinkers excel at evaluation, prioritization, and finding the optimal solution. Divergent thinkers excel at brainstorming, making unexpected connections, and generating novel ideas. Creative work requires both — the spark of divergence and the discipline of convergence — but most people have a natural preference for one mode over the other.',
    questions: [
      {
        id: 'go-1',
        text: 'When brainstorming, I naturally generate many ideas before evaluating any of them.',
        reversed: true,
      },
      {
        id: 'go-2',
        text: 'I prefer to identify the single best solution rather than keep multiple options open.',
        reversed: false,
      },
      {
        id: 'go-3',
        text: 'I often see connections between seemingly unrelated fields or concepts.',
        reversed: true,
      },
      {
        id: 'go-4',
        text: 'I feel most productive when I can focus on refining one idea to perfection.',
        reversed: false,
      },
      {
        id: 'go-5',
        text: 'I enjoy exploring tangents and unexpected directions in my thinking, even if they do not lead anywhere immediately useful.',
        reversed: true,
      },
    ],
  },
  {
    id: 'representational-channel',
    name: 'Representational Channel',
    lowLabel: 'Verbal-Symbolic',
    highLabel: 'Imagistic-Spatial',
    color: '#AB47BC',
    colorName: 'Violet',
    icon: 'Palette',
    description:
      'Representational Channel identifies the internal medium of your thinking. Verbal-symbolic thinkers process primarily through language, logic, and abstract symbols — they think in words, numbers, and formal structures. Imagistic-spatial thinkers process through mental imagery, spatial relationships, and sensory simulations — they think in pictures, diagrams, and felt impressions. This dimension profoundly affects how you learn, communicate, and solve problems.',
    questions: [
      {
        id: 'rc-1',
        text: 'When thinking through a problem, I primarily use inner dialogue and verbal reasoning.',
        reversed: false,
      },
      {
        id: 'rc-2',
        text: 'I naturally create mental maps or images to understand complex information.',
        reversed: true,
      },
      {
        id: 'rc-3',
        text: 'I prefer written instructions over diagrams or visual demonstrations.',
        reversed: false,
      },
      {
        id: 'rc-4',
        text: 'I can easily rotate three-dimensional objects in my mind.',
        reversed: true,
      },
      {
        id: 'rc-5',
        text: 'I find it easier to remember something I have read than something I have seen in a picture or diagram.',
        reversed: false,
      },
    ],
  },
  {
    id: 'relational-orientation',
    name: 'Relational Orientation',
    lowLabel: 'Autonomous',
    highLabel: 'Connected',
    color: '#EF5350',
    colorName: 'Rose',
    icon: 'Users',
    description:
      'Relational Orientation captures how your cognition is shaped by social context. Autonomous thinkers do their best thinking independently, forming conclusions through internal reasoning before seeking input. Connected thinkers do their best thinking in dialogue, naturally incorporating others perspectives and arriving at understanding through exchange. This is not introversion vs. extroversion — it is about whether your cognitive process itself is more solitary or more social.',
    questions: [
      {
        id: 'ro-1',
        text: 'I develop my best ideas through conversation with others rather than thinking alone.',
        reversed: true,
      },
      {
        id: 'ro-2',
        text: 'I prefer to fully form my thoughts before sharing them with anyone.',
        reversed: false,
      },
      {
        id: 'ro-3',
        text: 'Other people\'s perspectives frequently change how I think about a problem.',
        reversed: true,
      },
      {
        id: 'ro-4',
        text: 'I do my most productive thinking in solitude, without interruption.',
        reversed: false,
      },
      {
        id: 'ro-5',
        text: 'I find that teaching or explaining something to others deepens my own understanding significantly.',
        reversed: true,
      },
    ],
  },
  {
    id: 'somatic-integration',
    name: 'Somatic Integration',
    lowLabel: 'Cerebral',
    highLabel: 'Embodied',
    color: '#26A69A',
    colorName: 'Teal',
    icon: 'Activity',
    description:
      'Somatic Integration describes how much your body participates in your cognitive processes. Cerebral thinkers operate primarily from the neck up — their thinking feels disembodied and abstract, driven by logic and language. Embodied thinkers naturally integrate bodily signals — gut feelings, physical tension, energetic shifts — into their reasoning. Many high-stakes decisions benefit from somatic awareness, yet academic culture has historically privileged cerebral processing.',
    questions: [
      {
        id: 'si-1',
        text: 'I often notice a physical sensation (gut feeling, tension, warmth) that guides my decisions.',
        reversed: true,
      },
      {
        id: 'si-2',
        text: 'My best thinking happens while I am physically active — walking, exercising, or moving.',
        reversed: true,
      },
      {
        id: 'si-3',
        text: 'I tend to make decisions based on logical analysis rather than physical or emotional intuition.',
        reversed: false,
      },
      {
        id: 'si-4',
        text: 'I can easily identify where in my body I am holding stress or emotion.',
        reversed: true,
      },
      {
        id: 'si-5',
        text: 'When evaluating an idea, I pay more attention to whether the reasoning is sound than to how it feels in my body.',
        reversed: false,
      },
    ],
  },
  {
    id: 'complexity-tolerance',
    name: 'Complexity Tolerance',
    lowLabel: 'Closure-Seeking',
    highLabel: 'Ambiguity-Embracing',
    color: '#5C6BC0',
    colorName: 'Indigo',
    icon: 'Layers',
    description:
      'Complexity Tolerance measures your relationship with ambiguity, paradox, and unresolved tensions. Closure-seeking thinkers are energized by clarity, resolution, and definitive answers — they bring order to chaos and drive toward completion. Ambiguity-embracing thinkers are comfortable holding contradictions, tolerating uncertainty, and allowing meaning to emerge over time. In a complex world, both capacities are essential: closure gets things done while ambiguity tolerance enables deeper understanding.',
    questions: [
      {
        id: 'ct-1',
        text: 'I feel uncomfortable when a question does not have a clear, definitive answer.',
        reversed: false,
      },
      {
        id: 'ct-2',
        text: 'I can hold two contradictory ideas in mind without feeling the need to resolve them immediately.',
        reversed: true,
      },
      {
        id: 'ct-3',
        text: 'I prefer clear categories and classifications over blurry spectrums.',
        reversed: false,
      },
      {
        id: 'ct-4',
        text: 'I find paradoxes and contradictions intellectually stimulating rather than frustrating.',
        reversed: true,
      },
      {
        id: 'ct-5',
        text: 'When starting a project, I need a clear plan and defined outcome before I can begin.',
        reversed: false,
      },
    ],
  },
];

export const dimensionColors = dimensions.map((d) => d.color);

export const getDimensionById = (id) => dimensions.find((d) => d.id === id);

export const getAllQuestions = () => {
  const questions = [];
  dimensions.forEach((dim) => {
    dim.questions.forEach((q) => {
      questions.push({
        ...q,
        dimensionId: dim.id,
        dimensionName: dim.name,
        dimensionColor: dim.color,
      });
    });
  });
  return questions;
};

export default dimensions;
