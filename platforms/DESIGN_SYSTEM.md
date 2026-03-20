# Resonance UX - Luminous Cosmic Architecture Design System

## Color Palette

### Light Mode (Day)
| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#FAFAF8` | Page background |
| `bg-surface` | `#F5F4EE` | Card/surface background |
| `bg-glass` | `rgba(255,255,255,0.7)` | Glassmorphism panels |
| `green-900` | `#0A1C14` | Deepest green, primary text |
| `green-800` | `#122E21` | Headers, strong emphasis |
| `green-700` | `#1B402E` | Secondary emphasis |
| `green-200` | `#D1E0D7` | Light green tints |
| `green-100` | `#E8F0EA` | Subtle green backgrounds |
| `gold-primary` | `#C5A059` | Primary accent, CTAs |
| `gold-light` | `#E6D0A1` | Light gold accents |
| `gold-dark` | `#9A7A3A` | Dark gold, hover states |
| `text-main` | `#122E21` | Body text |
| `text-muted` | `#5C7065` | Secondary text |
| `text-light` | `#8A9C91` | Tertiary text |

### Dark Mode (Night / Deep Rest)
| Token | Hex | Usage |
|-------|-----|-------|
| `bg-base` | `#05100B` | Page background |
| `bg-surface` | `#0A1C14` | Card/surface background |
| `bg-glass` | `rgba(10,28,20,0.55)` | Glassmorphism panels |
| `text-main` | `#FAFAF8` | Body text |
| `text-muted` | `#8A9C91` | Secondary text |
| `text-light` | `#5C7065` | Tertiary text |
| `border-light` | `rgba(27,64,46,0.7)` | Borders |

## Typography

### Font Families
- **Serif (Display)**: Cormorant Garamond — headers, titles, quotes
- **Sans-serif (Body)**: Manrope — body text, UI elements, labels

### Scale
| Level | Size | Weight | Font |
|-------|------|--------|------|
| Display | 34pt | Light (300) | Serif |
| H1 | 28pt | SemiBold (600) | Serif |
| H2 | 22pt | Medium (500) | Serif |
| H3 | 18pt | Medium (500) | Serif |
| Body | 16pt | Regular (400) | Sans |
| Caption | 13pt | Regular (400) | Sans |
| Small | 11pt | Medium (500) | Sans |

## Effects

### Glassmorphism
```
background: var(--bg-glass)
backdrop-filter: blur(12px)
border: 1px solid var(--border-light)
border-radius: 16px
```

### Organic Blobs
```
border-radius: 50%
filter: blur(60px)
opacity: 0.5 (light) / 0.35 (dark)
animation: breathe 15s infinite alternate ease-in-out
```

### Paper Noise Texture
SVG feTurbulence overlay at 3.5% opacity

### Animations
- **Spring**: `cubic-bezier(0.34, 1.56, 0.64, 1)` — bouncy interactions
- **Smooth**: `cubic-bezier(0.165, 0.84, 0.44, 1)` — fluid transitions
- **Breathe**: 15s infinite alternate scale(1) → scale(1.05)

### Shadows
- **Glass**: `0 16px 40px rgba(154, 122, 58, 0.12)`
- **Card**: `0 8px 24px rgba(154, 122, 58, 0.08)`
- **Card Hover**: `0 24px 48px rgba(154, 122, 58, 0.18)`

## Spacing
Base unit: 4px
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px
- 3xl: 64px

## Platform Adaptations

### iOS / macOS
- Use `.ultraThinMaterial` for glass effects
- SF Pro as system font fallback
- Spring animations via SwiftUI `.spring()`
- Haptic feedback on interactions

### Android
- Material3 with custom color scheme
- `Modifier.blur()` for glass effects
- `spring()` animation spec
- Ripple effects on touch

### Web
- CSS `backdrop-filter: blur()`
- CSS custom properties for theming
- `@media (prefers-color-scheme)` support
- Responsive breakpoints: 640px, 768px, 1024px, 1280px

### Windows
- Mica/Acrylic backdrop materials
- WinUI 3 NavigationView
- Composition animations
- Windows 11 design integration

### watchOS
- Compact layouts, essential info only
- Deep green backgrounds (always dark)
- Gold accent for highlights
- Watch complications for at-a-glance info
