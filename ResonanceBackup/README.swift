// README.swift
// Resonance UX GitHub Backup
//
// ╔══════════════════════════════════════════════════════════════╗
// ║          RESONANCE BACKUP — GitHub Replacement              ║
// ║     Bioluminescent Portfolio-Based Repository Manager       ║
// ╚══════════════════════════════════════════════════════════════╝
//
// ARCHITECTURE
// ============
//
// Shared/
// ├── DesignSystem/
// │   ├── ResonanceTheme.swift          — Colors, typography, spacing (Resonance UX + Luminous OS)
// │   └── BioluminescentEffects.swift   — Breathing blobs, chromatic orbs, glass panels, indicator lights
// │
// ├── Models/
// │   ├── PortfolioModels.swift         — Portfolio, ChangeLogEntry, BitstampRecord, FileSlot, Collaborator, Secret
// │   ├── KopiaConfig.swift             — Kopia backup config, server commands, storage backends
// │   └── MarketplaceModels.swift       — Listings, trades, transactions, licenses, reviews
// │
// ├── Services/
// │   └── GitHubBackupService.swift     — CLI command execution, Kopia ops, GitHub ops, bitstamp, analysis
// │
// ├── ViewModels/
// │   └── BackupViewModel.swift         — Central state: portfolios, marketplace, sync, changelog
// │
// └── Views/
//     ├── MainAppView.swift             — App entry point, macOS/iOS/visionOS navigation, system calendar
//     ├── GalleryView.swift             — Gallery/List/Database views, portfolio cells with callsigns
//     ├── PortfolioDetailView.swift     — Full detail: database, calendar, files, secrets, team, notes
//     ├── CalendarLedgerView.swift       — Timeline/Calendar/Ledger with bitstamp verification
//     ├── MarketplaceView.swift         — Buy, sell, license, trade repositories
//     ├── CommandLineView.swift         — CLI interface, server commands menu, integrated terminal
//     ├── SettingsView.swift            — Kopia config, storage, scheduling, retention, GitHub, security
//     └── PrintBriefView.swift          — Printable project brief with logos and all portfolio info
//
// watchOS/
// └── WatchView.swift                   — Watch companion: status, sync, bitstamp, coherence gauge
//
// PLATFORMS
// =========
// • macOS   — Full NavigationSplitView with sidebar, terminal, print
// • iPadOS  — Tab-based with full gallery and split views
// • iOS     — Tab-based compact gallery and detail views
// • visionOS — Spatial computing with ornament navigation bar
// • watchOS — Companion app for portfolio status and sync triggers
//
// FEATURES
// ========
// • Each repository → one Portfolio (slide) with callsign: "OPERATION : REPO_NAME"
// • Database properties (text, number, date, select, URL, email, checkbox)
// • Calendar serving as ledger (timeline, calendar, table views)
// • Server commands as file menu (Kopia CLI: backup, restore, maintenance, server, policy)
// • Secrets vault (encrypted API keys, tokens, credentials)
// • File slots (Design Files, Documentation, Assets, Configuration, Tests, Releases)
// • Collaborator invitations with roles (Owner, Admin, Contributor, Viewer)
// • Notes / landing page embedded per portfolio
// • Original URL and upload date attached to each cell
// • Bitstamp verification from openbitstamp.org on every change
// • Gallery mode with bioluminescent logos and emoji callsigns
// • Language detection and breakdown per project
// • Marketplace for buying, selling, licensing, and trading repos
// • CLI interface with integrated terminal
// • Print brief system with project logos
// • Field coherence indicator (aggregate backup health)
//
// DESIGN LANGUAGE
// ===============
// Ported from Resonance-UX + Luminous OS (design repo):
// • Bioluminescent indicator lights (not neon — glows from within)
// • Breathing/living surfaces with sine-wave opacity animation
// • Chromatic orbs for status (radial gradient + pulse)
// • Glass panels with ultra-thin material + subtle borders
// • Paper noise texture overlay
// • Forest green + gold palette with portfolio accent colors
// • Cormorant Garamond (headings) + Manrope (body) typography
// • Organic breathing blob ambient backgrounds
