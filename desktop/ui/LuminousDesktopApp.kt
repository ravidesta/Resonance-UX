package com.luminous.resonance.desktop

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.key.*
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.*
import kotlinx.coroutines.launch
import kotlin.math.cos
import kotlin.math.sin

// ---------------------------------------------------------------------------
// Resonance Desktop Color Palette (mirrors Android ResonanceColors)
// ---------------------------------------------------------------------------

private object DesktopColors {
    val BgBaseLight = Color(0xFFFAFAF8)
    val BgBaseDark = Color(0xFF05100B)
    val Green900 = Color(0xFF0A1C14)
    val Green800 = Color(0xFF122E21)
    val Green700 = Color(0xFF1B402E)
    val Green600 = Color(0xFF27573E)
    val Green500 = Color(0xFF347050)
    val Green400 = Color(0xFF5C9A7A)
    val Green300 = Color(0xFF8DBEA4)
    val Green200 = Color(0xFFD1E0D7)
    val Green100 = Color(0xFFECF3EF)
    val Green50 = Color(0xFFF5F9F7)
    val GoldPrimary = Color(0xFFC5A059)
    val GoldLight = Color(0xFFE6D0A1)
    val GoldDark = Color(0xFF9A7A3A)
    val Neutral100 = Color(0xFFEFEFEB)
    val Neutral200 = Color(0xFFDEDED8)
    val Neutral400 = Color(0xFFA0A098)
    val Neutral600 = Color(0xFF5C5C56)
    val Neutral700 = Color(0xFF3E3E3A)
    val GlassLight = Color(0x33FFFFFF)
    val GlassDark = Color(0x1AFFFFFF)
}

// ---------------------------------------------------------------------------
// Desktop Material3 Color Schemes
// ---------------------------------------------------------------------------

private val DesktopLightScheme = lightColorScheme(
    primary = DesktopColors.Green700,
    onPrimary = Color.White,
    primaryContainer = DesktopColors.Green200,
    onPrimaryContainer = DesktopColors.Green900,
    secondary = DesktopColors.GoldPrimary,
    onSecondary = Color.White,
    secondaryContainer = DesktopColors.GoldLight,
    onSecondaryContainer = DesktopColors.GoldDark,
    background = DesktopColors.BgBaseLight,
    onBackground = DesktopColors.Green900,
    surface = DesktopColors.BgBaseLight,
    onSurface = DesktopColors.Green900,
    surfaceVariant = DesktopColors.Neutral100,
    onSurfaceVariant = DesktopColors.Neutral600,
    outline = DesktopColors.Neutral200,
)

private val DesktopDarkScheme = darkColorScheme(
    primary = DesktopColors.Green400,
    onPrimary = DesktopColors.Green900,
    primaryContainer = DesktopColors.Green800,
    onPrimaryContainer = DesktopColors.Green200,
    secondary = DesktopColors.GoldLight,
    onSecondary = DesktopColors.Green900,
    secondaryContainer = DesktopColors.GoldDark,
    onSecondaryContainer = DesktopColors.GoldLight,
    background = DesktopColors.BgBaseDark,
    onBackground = DesktopColors.Neutral100,
    surface = DesktopColors.BgBaseDark,
    onSurface = DesktopColors.Neutral100,
    surfaceVariant = DesktopColors.Green900,
    onSurfaceVariant = DesktopColors.Neutral400,
    outline = DesktopColors.Neutral600,
)

// ---------------------------------------------------------------------------
// Application Entry Point
// ---------------------------------------------------------------------------

/**
 * Main entry point for the Compose Multiplatform desktop application.
 * Creates the primary window with menu bar, system tray for background
 * audio, and optional secondary windows (e.g., notes).
 */
fun main() = application {
    var isDarkTheme by remember { mutableStateOf(false) }
    var isFullScreen by remember { mutableStateOf(false) }
    var showNotesWindow by remember { mutableStateOf(false) }
    var isExitRequested by remember { mutableStateOf(false) }

    // System tray for background audio playback
    val trayState = rememberTrayState()
    Tray(
        state = trayState,
        tooltip = "Luminous Integral Architecture",
        menu = {
            Item("Open", onClick = { /* bring to front */ })
            Separator()
            Item("Play/Pause", onClick = { /* delegate to audio controller */ })
            Item("Next Chapter", onClick = { /* delegate to audio controller */ })
            Separator()
            Item("Quit", onClick = { isExitRequested = true })
        },
    )

    if (isExitRequested) {
        exitApplication()
        return@application
    }

    // Primary application window
    val windowState = rememberWindowState(
        size = DpSize(1280.dp, 820.dp),
        placement = if (isFullScreen) WindowPlacement.Fullscreen else WindowPlacement.Floating,
    )

    Window(
        onCloseRequest = ::exitApplication,
        state = windowState,
        title = "Luminous Integral Architecture",
    ) {
        // Menu bar
        MenuBar {
            Menu("File") {
                Item(
                    text = "Open Book...",
                    onClick = { /* file picker */ },
                    shortcut = KeyShortcut(Key.O, ctrl = true),
                )
                Separator()
                Item(
                    text = "Preferences",
                    onClick = { /* open preferences */ },
                    shortcut = KeyShortcut(Key.Comma, ctrl = true),
                )
                Separator()
                Item(
                    text = "Quit",
                    onClick = { isExitRequested = true },
                    shortcut = KeyShortcut(Key.Q, ctrl = true),
                )
            }
            Menu("View") {
                Item(
                    text = if (isDarkTheme) "Light Mode" else "Dark Mode",
                    onClick = { isDarkTheme = !isDarkTheme },
                    shortcut = KeyShortcut(Key.D, ctrl = true, shift = true),
                )
                Item(
                    text = if (isFullScreen) "Exit Full Screen" else "Full Screen",
                    onClick = {
                        isFullScreen = !isFullScreen
                        windowState.placement = if (isFullScreen) {
                            WindowPlacement.Fullscreen
                        } else {
                            WindowPlacement.Floating
                        }
                    },
                    shortcut = KeyShortcut(Key.F11),
                )
                Separator()
                Item(
                    text = "Show Notes Panel",
                    onClick = { showNotesWindow = !showNotesWindow },
                    shortcut = KeyShortcut(Key.N, ctrl = true, shift = true),
                )
            }
            Menu("Navigate") {
                Item(
                    text = "Next Page",
                    onClick = { /* delegate to reader */ },
                    shortcut = KeyShortcut(Key.DirectionRight),
                )
                Item(
                    text = "Previous Page",
                    onClick = { /* delegate to reader */ },
                    shortcut = KeyShortcut(Key.DirectionLeft),
                )
                Separator()
                Item(
                    text = "Go to Chapter...",
                    onClick = { /* open chapter picker */ },
                    shortcut = KeyShortcut(Key.G, ctrl = true),
                )
                Item(
                    text = "Find in Book",
                    onClick = { /* open search */ },
                    shortcut = KeyShortcut(Key.F, ctrl = true),
                )
            }
            Menu("Help") {
                Item(text = "Documentation", onClick = { /* open docs */ })
                Item(text = "About Luminous", onClick = { /* open about */ })
            }
        }

        // Apply theme
        MaterialTheme(
            colorScheme = if (isDarkTheme) DesktopDarkScheme else DesktopLightScheme,
        ) {
            LuminousDesktopContent(
                isDarkTheme = isDarkTheme,
                isFullScreen = isFullScreen,
                onToggleFullScreen = {
                    isFullScreen = !isFullScreen
                    windowState.placement = if (isFullScreen) {
                        WindowPlacement.Fullscreen
                    } else {
                        WindowPlacement.Floating
                    }
                },
            )
        }
    }

    // Secondary notes window
    if (showNotesWindow) {
        Window(
            onCloseRequest = { showNotesWindow = false },
            state = rememberWindowState(size = DpSize(400.dp, 600.dp)),
            title = "Notes - Luminous",
        ) {
            MaterialTheme(
                colorScheme = if (isDarkTheme) DesktopDarkScheme else DesktopLightScheme,
            ) {
                NotesPanel()
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Main Desktop Content
// ---------------------------------------------------------------------------

/**
 * Main content layout with resizable sidebar, central reader/player area,
 * and optional notes panel. Supports keyboard navigation for page turning,
 * search, and other shortcuts.
 */
@Composable
private fun LuminousDesktopContent(
    isDarkTheme: Boolean,
    isFullScreen: Boolean,
    onToggleFullScreen: () -> Unit,
) {
    var selectedSection by remember { mutableStateOf(DesktopSection.READER) }
    var isSidebarVisible by remember { mutableStateOf(true) }
    var isNotesVisible by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }
    var showSearch by remember { mutableStateOf(false) }
    var currentPage by remember { mutableIntStateOf(0) }

    // Keyboard shortcut handling
    Box(
        modifier = Modifier
            .fillMaxSize()
            .onPreviewKeyEvent { event ->
                if (event.type == KeyEventType.KeyDown) {
                    when {
                        event.key == Key.DirectionRight -> {
                            currentPage++
                            true
                        }
                        event.key == Key.DirectionLeft -> {
                            currentPage = (currentPage - 1).coerceAtLeast(0)
                            true
                        }
                        event.isCtrlPressed && event.key == Key.F -> {
                            showSearch = !showSearch
                            true
                        }
                        event.key == Key.Escape -> {
                            if (showSearch) {
                                showSearch = false
                                true
                            } else if (isFullScreen) {
                                onToggleFullScreen()
                                true
                            } else {
                                false
                            }
                        }
                        event.isCtrlPressed && event.key == Key.B -> {
                            isSidebarVisible = !isSidebarVisible
                            true
                        }
                        else -> false
                    }
                } else false
            },
    ) {
        Row(modifier = Modifier.fillMaxSize()) {
            // Sidebar
            AnimatedVisibility(
                visible = isSidebarVisible && !isFullScreen,
                enter = expandHorizontally() + fadeIn(),
                exit = shrinkHorizontally() + fadeOut(),
            ) {
                DesktopSidebar(
                    selectedSection = selectedSection,
                    onSectionSelected = { selectedSection = it },
                    modifier = Modifier.width(260.dp),
                )
            }

            // Divider
            if (isSidebarVisible && !isFullScreen) {
                VerticalDivider(
                    modifier = Modifier.fillMaxHeight(),
                    color = MaterialTheme.colorScheme.outlineVariant,
                )
            }

            // Main content area
            Column(modifier = Modifier.weight(1f)) {
                // Search bar
                AnimatedVisibility(
                    visible = showSearch,
                    enter = expandVertically() + fadeIn(),
                    exit = shrinkVertically() + fadeOut(),
                ) {
                    DesktopSearchBar(
                        query = searchQuery,
                        onQueryChange = { searchQuery = it },
                        onClose = { showSearch = false },
                    )
                }

                // Content
                Box(modifier = Modifier.weight(1f)) {
                    when (selectedSection) {
                        DesktopSection.READER -> DesktopReaderContent(currentPage = currentPage)
                        DesktopSection.AUDIOBOOK -> DesktopAudioContent()
                        DesktopSection.COACH -> DesktopCoachContent()
                        DesktopSection.COMMUNITY -> DesktopCommunityContent()
                        DesktopSection.LIBRARY -> DesktopLibraryContent()
                    }
                }

                // Bottom status bar
                DesktopStatusBar(
                    currentPage = currentPage,
                    selectedSection = selectedSection,
                    isSidebarVisible = isSidebarVisible,
                    onToggleSidebar = { isSidebarVisible = !isSidebarVisible },
                )
            }

            // Notes panel (inline)
            AnimatedVisibility(
                visible = isNotesVisible && !isFullScreen,
                enter = expandHorizontally() + fadeIn(),
                exit = shrinkHorizontally() + fadeOut(),
            ) {
                VerticalDivider(
                    modifier = Modifier.fillMaxHeight(),
                    color = MaterialTheme.colorScheme.outlineVariant,
                )
                NotesPanel(modifier = Modifier.width(320.dp))
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Desktop Sections
// ---------------------------------------------------------------------------

enum class DesktopSection(val label: String, val icon: @Composable () -> Unit) {
    LIBRARY("Library", { Icon(Icons.Default.LocalLibrary, contentDescription = null) }),
    READER("Reader", { Icon(Icons.AutoMirrored.Filled.MenuBook, contentDescription = null) }),
    AUDIOBOOK("Audiobook", { Icon(Icons.Default.Headphones, contentDescription = null) }),
    COACH("Coach", { Icon(Icons.Default.Psychology, contentDescription = null) }),
    COMMUNITY("Community", { Icon(Icons.Default.Groups, contentDescription = null) }),
}

// ---------------------------------------------------------------------------
// Sidebar
// ---------------------------------------------------------------------------

@Composable
private fun DesktopSidebar(
    selectedSection: DesktopSection,
    onSectionSelected: (DesktopSection) -> Unit,
    modifier: Modifier = Modifier,
) {
    Surface(
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
        modifier = modifier.fillMaxHeight(),
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            // App logo / title
            Text(
                text = "Luminous",
                style = MaterialTheme.typography.headlineSmall.copy(
                    fontSize = 24.sp,
                ),
                color = DesktopColors.GoldPrimary,
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 16.dp),
            )

            HorizontalDivider(
                modifier = Modifier.padding(vertical = 8.dp),
                color = MaterialTheme.colorScheme.outlineVariant,
            )

            // Navigation items
            DesktopSection.entries.forEach { section ->
                val isSelected = section == selectedSection
                NavigationDrawerItem(
                    label = {
                        Text(
                            text = section.label,
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    },
                    icon = section.icon,
                    selected = isSelected,
                    onClick = { onSectionSelected(section) },
                    colors = NavigationDrawerItemDefaults.colors(
                        selectedContainerColor = DesktopColors.GoldPrimary.copy(alpha = 0.12f),
                        selectedTextColor = MaterialTheme.colorScheme.onSurface,
                        selectedIconColor = DesktopColors.GoldPrimary,
                    ),
                    modifier = Modifier.padding(vertical = 2.dp),
                )
            }

            Spacer(Modifier.weight(1f))

            // Chapter list (context-sensitive)
            Text(
                text = "Chapters",
                style = MaterialTheme.typography.labelLarge,
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
            )
            HorizontalDivider(
                color = MaterialTheme.colorScheme.outlineVariant,
            )

            val sampleChapters = listOf(
                "1. Introduction",
                "2. Foundations",
                "3. The Integral Map",
                "4. Quadrant Dynamics",
                "5. Stages of Growth",
                "6. Lines of Development",
                "7. States of Consciousness",
                "8. Types and Styles",
                "9. Integration Practice",
                "10. Living Architecture",
            )

            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(vertical = 4.dp),
            ) {
                items(sampleChapters) { chapter ->
                    Text(
                        text = chapter,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { /* navigate to chapter */ }
                            .padding(horizontal = 12.dp, vertical = 6.dp),
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Desktop Search Bar
// ---------------------------------------------------------------------------

@Composable
private fun DesktopSearchBar(
    query: String,
    onQueryChange: (String) -> Unit,
    onClose: () -> Unit,
) {
    Surface(
        color = MaterialTheme.colorScheme.surfaceVariant,
        tonalElevation = 2.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Icon(
                Icons.Default.Search,
                contentDescription = null,
                modifier = Modifier.size(20.dp),
            )
            Spacer(Modifier.width(8.dp))
            TextField(
                value = query,
                onValueChange = onQueryChange,
                placeholder = { Text("Search in book...") },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = TextFieldDefaults.colors(
                    focusedContainerColor = Color.Transparent,
                    unfocusedContainerColor = Color.Transparent,
                    focusedIndicatorColor = Color.Transparent,
                    unfocusedIndicatorColor = Color.Transparent,
                ),
            )
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close search")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Desktop Status Bar
// ---------------------------------------------------------------------------

@Composable
private fun DesktopStatusBar(
    currentPage: Int,
    selectedSection: DesktopSection,
    isSidebarVisible: Boolean,
    onToggleSidebar: () -> Unit,
) {
    Surface(
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.7f),
        tonalElevation = 1.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(28.dp)
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                IconButton(
                    onClick = onToggleSidebar,
                    modifier = Modifier.size(20.dp),
                ) {
                    Icon(
                        imageVector = if (isSidebarVisible) Icons.Default.ChevronLeft else Icons.Default.ChevronRight,
                        contentDescription = "Toggle sidebar",
                        modifier = Modifier.size(16.dp),
                    )
                }
                Text(
                    text = selectedSection.label,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Text(
                text = "Page ${currentPage + 1}",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Reader Content
// ---------------------------------------------------------------------------

@Composable
private fun DesktopReaderContent(currentPage: Int) {
    // Organic blob background
    Box(modifier = Modifier.fillMaxSize()) {
        DesktopBlobBackground()

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(48.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            SelectionContainer {
                Text(
                    text = buildString {
                        appendLine("Chapter ${currentPage / 5 + 1}")
                        appendLine()
                        append(
                            "This is the reading content for page ${currentPage + 1}. " +
                            "In a production application, this would render the actual " +
                            "ebook content with proper pagination, text selection for " +
                            "highlighting, and inline interactive exercises including " +
                            "reflection questions and quadrant mapping diagrams."
                        )
                        appendLine()
                        appendLine()
                        append(
                            "The desktop reader supports keyboard navigation with " +
                            "arrow keys for page turning, Ctrl+F for search, and " +
                            "full-screen immersive mode via F11."
                        )
                    },
                    style = MaterialTheme.typography.bodyLarge.copy(
                        lineHeight = 32.sp,
                    ),
                    modifier = Modifier.widthIn(max = 680.dp),
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Audio Content
// ---------------------------------------------------------------------------

@Composable
private fun DesktopAudioContent() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        DesktopBlobBackground()

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(48.dp),
        ) {
            // Animated circle
            val breathScale by animateBreathingDesktop()
            Box(
                modifier = Modifier
                    .size(160.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.radialGradient(
                            colors = listOf(
                                DesktopColors.Green600.copy(alpha = 0.25f),
                                DesktopColors.Green700.copy(alpha = 0.12f),
                                DesktopColors.GoldPrimary.copy(alpha = 0.06f),
                            ),
                        ),
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    Icons.Default.Headphones,
                    contentDescription = null,
                    modifier = Modifier.size(56.dp),
                    tint = DesktopColors.GoldPrimary.copy(alpha = 0.7f),
                )
            }

            Spacer(Modifier.height(24.dp))
            Text(
                text = "Audiobook Player",
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = "Desktop playback with system tray controls",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            Spacer(Modifier.height(32.dp))

            // Playback controls
            Row(
                horizontalArrangement = Arrangement.spacedBy(16.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = { /* skip back */ }) {
                    Icon(Icons.Default.Replay10, contentDescription = "Skip back")
                }
                FilledIconButton(
                    onClick = { /* play/pause */ },
                    modifier = Modifier.size(64.dp),
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = DesktopColors.GoldPrimary,
                        contentColor = DesktopColors.Green900,
                    ),
                ) {
                    Icon(
                        Icons.Default.PlayArrow,
                        contentDescription = "Play",
                        modifier = Modifier.size(32.dp),
                    )
                }
                IconButton(onClick = { /* skip forward */ }) {
                    Icon(Icons.Default.Forward30, contentDescription = "Skip forward")
                }
            }

            Spacer(Modifier.height(16.dp))

            // Seek bar
            Slider(
                value = 0.35f,
                onValueChange = { /* seek */ },
                modifier = Modifier.widthIn(max = 500.dp),
                colors = SliderDefaults.colors(
                    thumbColor = DesktopColors.GoldPrimary,
                    activeTrackColor = DesktopColors.GoldPrimary,
                ),
            )
            Row(
                modifier = Modifier.widthIn(max = 500.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text("12:34", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Text("45:20", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Coach Content (Desktop)
// ---------------------------------------------------------------------------

@Composable
private fun DesktopCoachContent() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(48.dp),
        ) {
            Icon(
                Icons.Default.Psychology,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = DesktopColors.GoldPrimary.copy(alpha = 0.6f),
            )
            Spacer(Modifier.height(16.dp))
            Text(
                text = "AI Coach",
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = "Desktop coaching interface with text and voice modes",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Community Content (Desktop)
// ---------------------------------------------------------------------------

@Composable
private fun DesktopCommunityContent() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(48.dp),
        ) {
            Icon(
                Icons.Default.Groups,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = DesktopColors.Green500.copy(alpha = 0.6f),
            )
            Spacer(Modifier.height(16.dp))
            Text(
                text = "Community Hub",
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = "Study groups, practice circles, and community feed",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Library Content (Desktop)
// ---------------------------------------------------------------------------

@Composable
private fun DesktopLibraryContent() {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(48.dp),
        ) {
            Icon(
                Icons.Default.LocalLibrary,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = DesktopColors.Green500.copy(alpha = 0.6f),
            )
            Spacer(Modifier.height(16.dp))
            Text(
                text = "Library",
                style = MaterialTheme.typography.headlineMedium,
            )
            Text(
                text = "Your collection of books and audiobooks",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Notes Panel
// ---------------------------------------------------------------------------

@Composable
private fun NotesPanel(modifier: Modifier = Modifier) {
    Surface(
        color = MaterialTheme.colorScheme.surface,
        modifier = modifier.fillMaxHeight(),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = "Notes & Highlights",
                style = MaterialTheme.typography.titleMedium,
            )
            Spacer(Modifier.height(12.dp))
            HorizontalDivider(color = MaterialTheme.colorScheme.outlineVariant)
            Spacer(Modifier.height(12.dp))

            // Placeholder notes list
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.weight(1f),
            ) {
                items(
                    listOf(
                        "The integral map provides a comprehensive framework...",
                        "Key insight: all quadrants are equally important.",
                        "Practice note: morning meditation, 20 minutes.",
                    )
                ) { note ->
                    Surface(
                        color = DesktopColors.GoldPrimary.copy(alpha = 0.08f),
                        shape = RoundedCornerShape(8.dp),
                    ) {
                        Text(
                            text = note,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.padding(12.dp),
                        )
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            // Add note input
            var noteText by remember { mutableStateOf("") }
            OutlinedTextField(
                value = noteText,
                onValueChange = { noteText = it },
                placeholder = { Text("Add a note...") },
                modifier = Modifier.fillMaxWidth(),
                minLines = 2,
                maxLines = 4,
            )
            Spacer(Modifier.height(8.dp))
            Button(
                onClick = { noteText = "" },
                modifier = Modifier.align(Alignment.End),
                colors = ButtonDefaults.buttonColors(
                    containerColor = DesktopColors.GoldPrimary,
                    contentColor = DesktopColors.Green900,
                ),
            ) {
                Text("Save Note")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Desktop Blob Background
// ---------------------------------------------------------------------------

@Composable
private fun DesktopBlobBackground(modifier: Modifier = Modifier) {
    val infiniteTransition = rememberInfiniteTransition(label = "desktop_blobs")

    val phases = (0 until 3).map { index ->
        infiniteTransition.animateFloat(
            initialValue = 0f,
            targetValue = 1f,
            animationSpec = infiniteRepeatable(
                animation = tween(
                    durationMillis = 8_000 + index * 1_000,
                    easing = FastOutSlowInEasing,
                ),
                repeatMode = RepeatMode.Reverse,
            ),
            label = "desktop_blob_$index",
        )
    }

    Canvas(modifier = modifier.fillMaxSize()) {
        val w = size.width
        val h = size.height

        for (i in 0 until 3) {
            val phase = phases[i].value
            val cx = w * (0.2f + 0.6f * (i.toFloat() / 3f + 0.05f * sin(phase * Math.PI.toFloat() * 2f)))
            val cy = h * (0.3f + 0.4f * (i.toFloat() / 3f + 0.04f * cos(phase * Math.PI.toFloat() * 2f)))
            val radius = (w.coerceAtMost(h) * 0.2f) * (0.9f + 0.2f * phase)

            val color = if (i % 2 == 0) {
                DesktopColors.Green700.copy(alpha = 0.06f)
            } else {
                DesktopColors.GoldPrimary.copy(alpha = 0.04f)
            }

            drawCircle(
                brush = Brush.radialGradient(
                    colors = listOf(color, color.copy(alpha = 0f)),
                    center = androidx.compose.ui.geometry.Offset(cx, cy),
                    radius = radius,
                ),
                radius = radius,
                center = androidx.compose.ui.geometry.Offset(cx, cy),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Desktop Breathing Animation
// ---------------------------------------------------------------------------

@Composable
private fun animateBreathingDesktop(
    min: Float = 0.95f,
    max: Float = 1.05f,
    durationMs: Int = 4_000,
): State<Float> {
    val transition = rememberInfiniteTransition(label = "desktop_breathing")
    return transition.animateFloat(
        initialValue = min,
        targetValue = max,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMs, easing = EaseInOutCubic),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "desktop_breath_scale",
    )
}
