# Resonance GitHub Backup Portal — Design Specification

## Visual Language Integration

This document specifies how the Luminous Design System integrates with the
Resonance GitHub Backup Portal.

### Bioluminescent Indicators

Status lights use the ChromaticOrb pattern from the Luminous spec:

| Status       | Color     | Animation        | Glow Radius |
|-------------|-----------|-----------------|-------------|
| Synced      | `#59C9A5` | 3s breathe      | 8-16px      |
| Pending     | `#F4A261` | 3s breathe      | 8-16px      |
| Error       | `#EF6461` | 3s breathe      | 8-16px      |
| Backing Up  | `#7B8CDE` | 1s fast pulse   | 8-16px      |

All indicators glow **from within** using radial-gradient luminescence, not
external box-shadows. This matches the Luminous "bioluminescence not neon" rule.

### Living Surfaces

Portfolio cards use the Living Surface pattern:
- Background opacity oscillates: `0.04 ± 0.02` (6s sine wave)
- Border opacity follows: `0.06 ± 0.04`
- Hover: `translateY(-2px)`, border brightens to `0.14`
- Inner radial glow from `30% x, 50% y` using portfolio's chromatic color

### Chromatic Orb Logos

Each portfolio gets a ChromaticOrb logo:
- 48x48px rounded square (14px radius)
- Gradient background using portfolio's assigned chromatic color
- Initials rendered in JetBrains Mono Bold
- Subtle inner radial glow overlay
- 4s breathing pulse animation

### Chromatic Palette Assignment

Portfolios receive colors in rotation:
1. `#59C9A5` — Growth Green
2. `#7B8CDE` — Strategic Blue
3. `#E040FB` — Creative Magenta
4. `#F4A261` — Warmth Amber
5. `#4ECDC4` — Signal Teal
6. `#EF6461` — Rhythm Coral

### Background Elements

- **Paper noise texture**: SVG fractal Perlin noise at 3.5% opacity
- **Breathing blobs**: Three blurred gradient circles with 15s breathe animation
- **Glass morphism panels**: `backdrop-filter: blur(16px)` with 3% white background

### Typography

- Headlines: Cormorant Garamond (serif), weight 300-600
- UI/Body: Manrope (sans-serif), weight 300-700
- Code/Hashes: JetBrains Mono (monospace), weight 400-500

### Callsign Convention

Each portfolio receives a callsign: `Operation: {Adjective} {Name}`
The adjective is deterministically derived from the repository name hash.
This provides a memorable, professional identifier for each project.
