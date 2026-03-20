/**
 * Apple Vision Pro (visionOS) Configuration
 * Luminous Lifewheel — Spatial Computing Experience
 *
 * The Lifewheel becomes a truly 3D, spatial object you can
 * walk around, resize, and interact with via gaze and gesture.
 */

export const VisionOSConfig = {
  platform: 'visionOS',
  minVersion: '2.0',

  // Window configurations
  windows: {
    main: {
      type: 'window',
      defaultSize: { width: 1200, height: 900 },
      style: 'automatic', // .plain, .volumetric, or .automatic
      resizability: 'automatic',
    },
    lifewheel3D: {
      type: 'volumetric',
      defaultSize: { width: 600, height: 600, depth: 600 },
      style: 'volumetric',
      // 3D Lifewheel floats in space — dimensions radiate outward
    },
    immersiveJournal: {
      type: 'immersive',
      style: 'mixed', // Mixed reality — see your room while journaling
    },
  },

  // Spatial interaction
  interactions: {
    gazeHighlight: true,       // Dimensions highlight on gaze
    pinchToSelect: true,       // Pinch gesture to select/score dimensions
    dragToResize: true,        // Resize the 3D wheel
    handTracking: true,        // Track hand movements for score slider
    eyeTracking: {
      enabled: true,
      dwellTime: 800,          // ms to trigger action on gaze
    },
  },

  // 3D Lifewheel rendering
  lifewheel3D: {
    renderMode: 'realityKit',
    material: 'physicallyBased',
    dimensionSpokes: {
      geometry: 'cylinder',
      radius: 0.005,
      glow: true,
      glowIntensity: 0.3,
    },
    scorePolygon: {
      material: 'translucent',
      opacity: 0.4,
      goldShimmer: true,
    },
    scoreDots: {
      geometry: 'sphere',
      radius: 0.015,
      emission: 0.2,  // Self-illuminating
    },
    ambientParticles: {
      enabled: true,
      type: 'luminousFireflies',
      count: 50,
      speed: 0.02,
    },
  },

  // Resonance UX spatial adaptations
  resonanceUX: {
    glassEffect: 'visionOSGlass', // Use native visionOS glass material
    organicBlobs: {
      renderAs: '3DVolume',        // Blobs become volumetric light sources
      opacity: 0.15,
    },
    typography: {
      // Slightly larger for spatial reading
      scaleFactor: 1.15,
    },
    haptics: {
      onScore: 'soft',
      onComplete: 'success',
      onNavigate: 'selection',
    },
  },

  // Shareplay for 5D Quantum Partner
  sharePlay: {
    enabled: true,
    activities: [
      'sharedLifewheel',     // Both partners see each other's wheel side by side
      'guidedAssessment',    // One leads, the other follows
      'celebrationCircle',   // Community circle in shared space
    ],
  },
};

export default VisionOSConfig;
