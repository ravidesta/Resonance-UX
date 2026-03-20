# Resonance: Designing Digital Calm — Audio Production Specification

**Version:** 1.0
**Last Updated:** 2026-03-20
**Status:** Pre-Production

---

## 1. Recording Requirements

### 1.1 Technical Format

| Parameter | Specification |
|---|---|
| Sample Rate | 48,000 Hz (48 kHz) |
| Bit Depth | 24-bit |
| Format | WAV (Broadcast WAV / BWF preferred) |
| Channels | Mono (single narrator) |
| File Naming | `RDC-[chapter]-[take]-[date].wav` (e.g., `RDC-00-foreword-T03-20260401.wav`) |

### 1.2 Recording Environment

- **Room:** Professionally treated recording booth or studio with RT60 below 0.3 seconds
- **Noise Floor:** Below -60 dBFS (ambient room noise with no signal)
- **Microphone:** Large-diaphragm condenser recommended (Neumann U87, TLM 103, or equivalent). Warm, detailed capsule preferred over bright/clinical character
- **Preamp:** Clean, transparent preamp with low self-noise (< -128 dBu EIN)
- **Pop Filter:** Dual-mesh pop filter positioned 4-6 inches from capsule
- **Distance:** Narrator 6-8 inches from microphone for intimate, warm proximity without excessive bass buildup
- **Monitoring:** Closed-back headphones for narrator; studio monitors for engineer (muted during recording)

### 1.3 Session Guidelines

- Record in 45-minute blocks maximum to preserve vocal freshness
- 15-minute vocal rest between blocks
- Room-tone capture: 30 seconds of silence at the start of each session for noise profiling
- Slate each take verbally: chapter number, section, take number
- Maintain consistent microphone distance throughout (use a fixed boom arm, not handheld)
- Keep water (room temperature, not cold) available for the narrator at all times
- Avoid recording after meals or caffeine (affects vocal quality and pacing)

---

## 2. Mastering Guidelines

### 2.1 Loudness and Dynamics

| Parameter | Target | Tolerance |
|---|---|---|
| Integrated Loudness (LUFS) | -18 LUFS | -20 to -16 LUFS |
| Loudness Range (LRA) | 6-9 dB | Maximum 12 dB |
| True Peak | -3 dBTP | Never exceed -1 dBTP |
| Noise Floor | Below -60 dBFS | Must not exceed -55 dBFS |
| Peak Level | -3 dBFS | -6 to -1 dBFS acceptable |

### 2.2 Processing Chain

1. **Noise Reduction** — Gentle spectral de-noise using session room-tone profile. Avoid over-processing; preserve natural room character
2. **De-essing** — Transparent de-essing targeting 4-8 kHz. Sibilance should be tamed, not eliminated
3. **EQ** — Subtle high-pass at 80 Hz (12 dB/oct). Gentle presence boost at 2-4 kHz if needed. Avoid harsh or clinical EQ curves
4. **Compression** — Gentle compression (2:1 to 3:1 ratio, slow attack 20-30ms, medium release 150-250ms). Goal is evenness, not flatness. Preserve the natural dynamics of contemplative narration
5. **Limiting** — Transparent brick-wall limiter at -3 dBTP. Should engage rarely, only catching occasional transients
6. **Loudness Normalization** — Final pass to -18 LUFS integrated

### 2.3 Quality Control

- Listen to every chapter in full at final master stage — no automated-only QC
- Check for: mouth clicks, breath artifacts, room rumble, digital clipping, phase issues
- Verify chapter markers align with script section breaks
- Test playback at 0.75x, 1.0x, 1.5x, and 2.0x speeds to ensure intelligibility across speed ranges
- Cross-reference against narration script for missed words, mispronunciations, or deviations

---

## 3. Background Music Specification

### 3.1 Philosophy

Background music in the Resonance audiobook serves the same purpose as the design system's ambient elements: it creates an environmental context without demanding attention. Music should feel like weather — present, atmospheric, and never competing with the narrator's voice.

### 3.2 Musical Parameters

| Parameter | Specification |
|---|---|
| Level relative to voice | -18 to -24 dB below narrator (music should be felt, not consciously heard) |
| Tempo | None / free-time (no discernible pulse or beat) |
| Key/Tonality | Ambient, modal, predominantly consonant. Root notes in the range of C3-G3 |
| Instrumentation | Sustained pads, soft synthesizers, treated piano, bowed strings (cello, viola), processed field recordings |
| Harmonic rhythm | Chord changes no more frequent than every 30-60 seconds |
| Dynamic range | Extremely narrow — music should be nearly static in level |
| Stereo width | Moderate stereo spread; avoid hard-panned elements that distract |

### 3.3 Music Placement

- **Chapter openings:** Music fades in 3-5 seconds before narrator begins. Gentle, establishing tone
- **Chapter endings:** Music swells subtly (+3-4 dB) during final paragraph, then sustains for 5-8 seconds after narrator finishes before fading out over 4-6 seconds
- **Section transitions:** Brief musical interlude (8-12 seconds) between major sections within a chapter
- **Quotes/Blockquotes:** Music may shift timbre slightly (e.g., add a soft harmonic overtone) to sonically signal a quoted passage
- **Silent passages:** Some sections should have no music at all, allowing the narrator's voice and silence itself to carry the weight. The absence of music is as intentional as its presence

### 3.4 Mood Map by Chapter

| Chapter | Musical Character |
|---|---|
| 00 - Foreword | Spacious, open, a single sustained note expanding into gentle harmony |
| 01 - Philosophy | Grounded, contemplative, warm bass tones with occasional high harmonics |
| 02 - Design System | Crystalline, precise, glass-like textures, shimmering pads |
| 03 - Daily Flow | Gently evolving, mirroring the four phases — dawn warmth to evening stillness |
| 04 - Inner Circle | Intimate, close, as if music is being played in a small room nearby |
| 05 - Writer | Sparse, nearly silent, single piano notes with long decay |
| 06 - Wellness | Organic, breath-like rhythms, natural field recordings (water, wind) |
| 07 - Cross-Platform | Layered, polyphonic, different textures weaving together |
| 08 - Integration | Warm analog textures, tactile quality, acoustic instruments |
| 09 - Technical | Clean, precise, minimal electronic tones, digital but human |
| 10 - Future | Expansive, building gradually, ending in open resonance |

---

## 4. Sound Design Elements

### 4.1 Phase Transition Sounds

Used at chapter transitions and major section breaks, these sounds echo the Resonance design system's phase transitions.

- **Morning Phase (Dawn):** Soft rising tone, like sunlight through glass. Sine wave with gentle harmonic overtones, sweeping from 220 Hz to 440 Hz over 3 seconds, with a soft reverb tail
- **Afternoon Phase (Peak):** Clear, present tone. A brief, warm chord (root + fifth + octave) at moderate resonance, lasting 2 seconds. Confident but not aggressive
- **Evening Phase (Golden Hour):** Descending warmth. A slow glissando from 440 Hz down to 330 Hz with increasing reverb and a subtle chorus effect. 4 seconds duration
- **Night Phase (Rest):** Near silence. A single low tone at 110 Hz, barely audible, with a long 6-second fade to nothing. The sonic equivalent of a deep exhale

### 4.2 Notification Tones (Illustrative)

When the narrator describes Resonance notification sounds, brief illustrative tones should play:

- **Gentle Ping:** Two-note ascending interval (perfect fifth), soft sine wave, 0.5 seconds. Used when discussing how Resonance handles notifications
- **Breath Reminder:** A single, breathy pad swell, 1.5 seconds, mimicking an inhale. Used when discussing wellness check-ins
- **Completion Chime:** Three ascending notes (root, third, fifth), soft bell timbre, 1 second total. Used when discussing task completion in Daily Flow

### 4.3 UI Interaction Sounds (Illustrative)

Brief sonic illustrations of described interface interactions:

- **Card Swipe:** Soft whoosh, 0.3 seconds, slight pitch shift suggesting lateral motion
- **Focus Mode Activation:** A gentle low-frequency hum that builds and then resolves into silence over 2 seconds. The sound of the world quieting
- **Glass Morphism Layer:** Subtle crystalline shimmer, like a fingertip touching a wine glass, 0.8 seconds
- **Deep Rest Mode:** Long, low drone that slowly diminishes, leaving perfect silence. 4 seconds

### 4.4 Chapter Transition Sequence

Standard transition between chapters (customize per chapter mood):

1. Narrator speaks final sentence of chapter
2. [2 seconds silence]
3. Phase transition tone plays (appropriate to chapter mood) — 3-4 seconds
4. [3 seconds silence]
5. Music for new chapter fades in — 3 seconds
6. Narrator announces new chapter title
7. [1 second pause]
8. Narration begins

Total transition duration: approximately 12-15 seconds.

---

## 5. Accessibility Requirements

### 5.1 Narration Accessibility

- **Pace:** 140-150 words per minute (slower than industry standard of 150-160 WPM). This deliberate pacing is both a design choice and an accessibility feature
- **Pronunciation guide:** Maintain a pronunciation reference document for all technical terms, proper nouns, and non-English words used in the text
- **Visual content description:** All references to visual design elements (color swatches, interface layouts, animations) must be described verbally in sufficient detail for a listener who cannot see the referenced images
- **Acronyms and abbreviations:** Spell out on first use, then use abbreviated form. Example: "User Experience, or UX" on first occurrence
- **Code and technical syntax:** When referencing code patterns, describe conceptually rather than reading raw syntax. Example: "a React component called GlassCard" rather than "angle bracket GlassCard space className equals quote..."

### 5.2 Structural Accessibility

- **Chapter markers:** Embedded chapter markers in all distribution formats for easy navigation
- **Section markers:** Sub-chapter section markers where supported by distribution format
- **Table of contents:** Navigable TOC in all formats that support it
- **Bookmarking:** Ensure all formats support listener bookmarking and position memory

### 5.3 Playback Compatibility

- Test all masters at playback speeds from 0.5x to 3.0x
- Ensure sound design elements remain coherent when time-stretched
- Background music should not produce artifacts at altered playback speeds
- Chapter transition sounds should remain pleasant at all standard speed settings

### 5.4 Cognitive Accessibility

- Narration pauses of 2-3 seconds between major topic shifts to allow processing time
- Complex concepts are introduced, explained, and then briefly summarized
- Sound design cues provide non-verbal markers for structural transitions, supporting listeners who may have difficulty tracking purely verbal structure cues
- No sudden loud sounds or jarring tonal shifts that could be distressing

---

## 6. File Delivery Structure

```
audiobook/
  production/
    raw/                    # Original unedited recordings
      00-foreword/
      01-philosophy/
      ...
    edited/                 # Edited and cleaned narration (no music/SFX)
      00-foreword.wav
      01-philosophy.wav
      ...
    music/                  # Background music stems
      00-foreword-ambient.wav
      01-philosophy-ambient.wav
      ...
    sfx/                    # Sound design elements
      phase-morning.wav
      phase-afternoon.wav
      phase-evening.wav
      phase-night.wav
      notification-ping.wav
      notification-breath.wav
      notification-chime.wav
      ui-swipe.wav
      ui-focus.wav
      ui-glass.wav
      ui-deep-rest.wav
      chapter-transition.wav
    final/                  # Mastered chapter files
      00-foreword.wav
      01-philosophy.wav
      ...
    distribution/           # Format-specific exports
      audible/
      apple-books/
      google-play/
      spotify/
      direct-flac/
      direct-mp3/
```

---

## 7. Production Timeline

| Phase | Duration | Description |
|---|---|---|
| Pre-production | 2 weeks | Script finalization, narrator casting, music composition brief |
| Narrator auditions | 1 week | Evaluate audition recordings against casting requirements |
| Music composition | 3 weeks (parallel) | Compose and produce background music and sound design elements |
| Recording | 2 weeks | Studio recording sessions (estimated 5-6 sessions) |
| Editing | 2 weeks | Clean, edit, and prepare narration stems |
| Mixing | 1 week | Combine narration, music, and sound design |
| Mastering | 1 week | Final loudness, dynamics, and quality control |
| QC and revisions | 1 week | Full listen-through, corrections, pick-up recordings if needed |
| Distribution prep | 1 week | Format conversion, metadata embedding, platform submission |
| **Total** | **~10-12 weeks** | From script lock to distribution |

---

## 8. Credits and Attributions

All audio credits to appear in metadata and on distribution platforms:

- **Written by:** The Resonance Design Collective
- **Narrated by:** [TBD]
- **Music and Sound Design:** [TBD]
- **Audio Engineering:** [TBD]
- **Mastering:** [TBD]
- **Produced by:** Resonance Press
- **Executive Producer:** [TBD]

---

*This specification is a living document and will be updated as production progresses. All changes should be version-controlled and approved by the production lead before implementation.*
