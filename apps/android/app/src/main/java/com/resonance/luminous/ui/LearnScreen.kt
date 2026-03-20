package com.resonance.luminous.ui

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

data class Chapter(
    val number: Int,
    val title: String,
    val subtitle: String,
    val sections: List<String>,
    val isUnlocked: Boolean = true,
    val progress: Float = 0f,      // 0..1
    val readTimeMinutes: Int = 15,
)

data class GlossaryEntry(
    val term: String,
    val definition: String,
    val chapter: Int,
)

data class Highlight(
    val text: String,
    val chapter: Int,
    val note: String = "",
    val color: Color = Resonance.goldPrimary,
)

data class Bookmark(
    val chapter: Int,
    val section: String,
    val position: Float,
    val label: String,
)

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

private val sampleChapters = listOf(
    Chapter(1, "Awakening", "Recognising the call to inner work", listOf("The Quiet Knock", "Signals of the Soul", "Choosing to Listen"), progress = 1f),
    Chapter(2, "The Mirror", "Seeing yourself without filters", listOf("Honest Reflection", "Masks We Wear", "The Beauty Underneath"), progress = 1f),
    Chapter(3, "Roots & Soil", "Understanding your foundation", listOf("Family Patterns", "Cultural Imprints", "Ancestral Wisdom"), progress = 0.6f),
    Chapter(4, "Embracing Shadow", "Meeting the hidden self", listOf("What Hides in Darkness", "Dialogue with Fear", "Gold in the Shadow"), progress = 0.1f),
    Chapter(5, "The Heart's Forge", "Transforming pain into purpose", listOf("Alchemy of Grief", "Sacred Anger", "Compassion's Fire"), progress = 0f),
    Chapter(6, "Luminous Body", "Embodying your truth", listOf("Somatic Awareness", "Breath as Bridge", "Movement Medicine"), progress = 0f, isUnlocked = false),
    Chapter(7, "Connection", "Relationships as mirrors", listOf("Attachment Styles", "Boundaries as Love", "Co-regulation"), progress = 0f, isUnlocked = false),
    Chapter(8, "Sacred Rest", "The art of restorative stillness", listOf("Permission to Pause", "Sleep Rituals", "Dream Work"), progress = 0f, isUnlocked = false),
    Chapter(9, "Purpose", "Aligning with your calling", listOf("Inner Compass", "Values Inventory", "Meaningful Action"), progress = 0f, isUnlocked = false),
    Chapter(10, "Integration", "Weaving it all together", listOf("Daily Rituals", "Season of Self", "The Ongoing Journey"), progress = 0f, isUnlocked = false),
    Chapter(11, "Giving Back", "Service from overflow", listOf("Compassion in Action", "Mentorship", "Community Healing"), progress = 0f, isUnlocked = false),
    Chapter(12, "Luminous Living", "Walking in your light", listOf("Embodied Presence", "Legacy of Light", "The Eternal Return"), progress = 0f, isUnlocked = false),
)

private val sampleGlossary = listOf(
    GlossaryEntry("Shadow Work", "The practice of exploring unconscious patterns, beliefs, and emotions that influence behaviour.", 4),
    GlossaryEntry("Somatic Awareness", "Conscious attention to bodily sensations as a pathway to emotional understanding.", 6),
    GlossaryEntry("Co-regulation", "The mutual exchange of calming presence between two nervous systems.", 7),
    GlossaryEntry("Alchemy", "Metaphorical transformation of base emotional material into psychological gold.", 5),
    GlossaryEntry("Luminous Body", "A state of embodied presence where inner light is expressed outwardly.", 6),
    GlossaryEntry("Attachment Style", "Patterns of relating to others formed in early life that shape adult relationships.", 7),
    GlossaryEntry("Inner Compass", "An intuitive sense of direction aligned with one's deepest values.", 9),
    GlossaryEntry("Integration", "The ongoing process of unifying disparate aspects of self into a coherent whole.", 10),
)

private val sampleHighlights = listOf(
    Highlight("The wound is the place where the Light enters you.", 4, "This keeps returning to me"),
    Highlight("We do not grow by staying comfortable.", 3),
    Highlight("Your body remembers what your mind forgets.", 6, "For the breathing exercise"),
)

private val sampleBookmarks = listOf(
    Bookmark(3, "Family Patterns", 0.45f, "Left off here"),
    Bookmark(4, "Gold in the Shadow", 0.1f, "Start next"),
)

// ---------------------------------------------------------------------------
// Learn Screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LearnScreen(isDark: Boolean) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Chapters", "Reader", "Glossary", "Highlights", "Bookmarks")

    var currentChapter by remember { mutableStateOf(sampleChapters[2]) }
    var isAudioPlaying by remember { mutableStateOf(false) }
    var audioProgress by remember { mutableFloatStateOf(0.35f) }
    var audioSpeed by remember { mutableFloatStateOf(1f) }

    Column(modifier = Modifier.fillMaxSize()) {
        // Top bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Text(
                text = "Learn",
                style = MaterialTheme.typography.headlineMedium,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.weight(1f),
            )
            // Overall progress
            val totalProgress = sampleChapters.sumOf { it.progress.toDouble() } / sampleChapters.size
            Text(
                text = "${(totalProgress * 100).toInt()}% complete",
                style = MaterialTheme.typography.labelMedium,
                color = Resonance.goldPrimary,
            )
        }

        // Tab row
        ScrollableTabRow(
            selectedTabIndex = selectedTab,
            containerColor = Color.Transparent,
            contentColor = MaterialTheme.colorScheme.onBackground,
            edgePadding = 20.dp,
            indicator = { tabPositions ->
                if (selectedTab < tabPositions.size) {
                    TabRowDefaults.SecondaryIndicator(
                        modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                        color = Resonance.goldPrimary,
                    )
                }
            },
            divider = {},
        ) {
            tabs.forEachIndexed { idx, title ->
                Tab(
                    selected = idx == selectedTab,
                    onClick = { selectedTab = idx },
                    text = {
                        Text(
                            title,
                            color = if (idx == selectedTab) Resonance.goldPrimary
                            else MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    },
                )
            }
        }

        // Content
        when (selectedTab) {
            0 -> ChapterListView(
                chapters = sampleChapters,
                isDark = isDark,
                onSelectChapter = { ch ->
                    currentChapter = ch
                    selectedTab = 1
                },
            )
            1 -> ReaderView(
                chapter = currentChapter,
                isDark = isDark,
                isAudioPlaying = isAudioPlaying,
                audioProgress = audioProgress,
                audioSpeed = audioSpeed,
                onToggleAudio = { isAudioPlaying = !isAudioPlaying },
                onAudioProgressChange = { audioProgress = it },
                onSpeedChange = { audioSpeed = it },
            )
            2 -> GlossaryView(glossary = sampleGlossary, isDark = isDark)
            3 -> HighlightsView(highlights = sampleHighlights, isDark = isDark)
            4 -> BookmarksView(
                bookmarks = sampleBookmarks,
                chapters = sampleChapters,
                isDark = isDark,
                onJump = { bm ->
                    currentChapter = sampleChapters.first { it.number == bm.chapter }
                    selectedTab = 1
                },
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Chapter list
// ---------------------------------------------------------------------------

@Composable
private fun ChapterListView(
    chapters: List<Chapter>,
    isDark: Boolean,
    onSelectChapter: (Chapter) -> Unit,
) {
    LazyColumn(
        contentPadding = PaddingValues(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        itemsIndexed(chapters) { _, chapter ->
            Card(
                onClick = { if (chapter.isUnlocked) onSelectChapter(chapter) },
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (chapter.isUnlocked)
                        LuminousThemeExt.colors.glassSurface
                    else
                        LuminousThemeExt.colors.glassSurface.copy(alpha = .4f),
                ),
                border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    // Chapter number badge
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(
                                if (chapter.progress >= 1f)
                                    Brush.linearGradient(listOf(Resonance.goldDark, Resonance.goldPrimary))
                                else if (chapter.isUnlocked)
                                    Brush.linearGradient(listOf(Resonance.green700, Resonance.green600))
                                else
                                    Brush.linearGradient(listOf(Resonance.green800, Resonance.green900))
                            ),
                        contentAlignment = Alignment.Center,
                    ) {
                        if (!chapter.isUnlocked) {
                            Icon(Icons.Filled.Lock, contentDescription = "Locked", tint = Resonance.green200.copy(alpha = .5f), modifier = Modifier.size(20.dp))
                        } else if (chapter.progress >= 1f) {
                            Icon(Icons.Filled.Check, contentDescription = "Complete", tint = Color.White, modifier = Modifier.size(20.dp))
                        } else {
                            Text(
                                text = "${chapter.number}",
                                style = MaterialTheme.typography.titleMedium,
                                color = Color.White,
                                fontWeight = FontWeight.Bold,
                            )
                        }
                    }

                    Spacer(Modifier.width(16.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Chapter ${chapter.number}",
                            style = MaterialTheme.typography.labelSmall,
                            color = Resonance.goldPrimary,
                        )
                        Text(
                            text = chapter.title,
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                        Text(
                            text = chapter.subtitle,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )

                        if (chapter.isUnlocked && chapter.progress > 0f && chapter.progress < 1f) {
                            Spacer(Modifier.height(8.dp))
                            LinearProgressIndicator(
                                progress = { chapter.progress },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(4.dp)
                                    .clip(RoundedCornerShape(2.dp)),
                                color = Resonance.goldPrimary,
                                trackColor = Resonance.goldPrimary.copy(alpha = .15f),
                            )
                        }
                    }

                    Spacer(Modifier.width(8.dp))

                    if (chapter.isUnlocked) {
                        Text(
                            text = "${chapter.readTimeMinutes} min",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Reader view
// ---------------------------------------------------------------------------

@Composable
private fun ReaderView(
    chapter: Chapter,
    isDark: Boolean,
    isAudioPlaying: Boolean,
    audioProgress: Float,
    audioSpeed: Float,
    onToggleAudio: () -> Unit,
    onAudioProgressChange: (Float) -> Unit,
    onSpeedChange: (Float) -> Unit,
) {
    val scrollState = rememberScrollState()
    var showAudioControls by remember { mutableStateOf(false) }
    var fontSize by remember { mutableFloatStateOf(16f) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 24.dp),
    ) {
        Spacer(Modifier.height(16.dp))

        // Chapter header
        Text(
            text = "Chapter ${chapter.number}",
            style = MaterialTheme.typography.labelLarge,
            color = Resonance.goldPrimary,
        )
        Text(
            text = chapter.title,
            style = MaterialTheme.typography.displaySmall,
            color = MaterialTheme.colorScheme.onBackground,
        )
        Text(
            text = chapter.subtitle,
            style = MaterialTheme.typography.bodyLarge.copy(fontStyle = FontStyle.Italic),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )

        Spacer(Modifier.height(8.dp))

        // Controls row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            // Audio toggle
            AssistChip(
                onClick = { showAudioControls = !showAudioControls },
                label = { Text(if (isAudioPlaying) "Listening" else "Audiobook") },
                leadingIcon = {
                    Icon(
                        if (isAudioPlaying) Icons.Filled.VolumeUp else Icons.Outlined.Headphones,
                        contentDescription = null,
                        modifier = Modifier.size(16.dp),
                    )
                },
                colors = AssistChipDefaults.assistChipColors(
                    containerColor = if (isAudioPlaying)
                        Resonance.goldPrimary.copy(alpha = .15f)
                    else Color.Transparent,
                ),
            )
            // Font size
            AssistChip(
                onClick = { fontSize = if (fontSize >= 22f) 14f else fontSize + 2f },
                label = { Text("Aa") },
                leadingIcon = {
                    Icon(Icons.Filled.TextFields, contentDescription = null, modifier = Modifier.size(16.dp))
                },
            )
            // Bookmark
            AssistChip(
                onClick = { /* add bookmark */ },
                label = { Text("Bookmark") },
                leadingIcon = {
                    Icon(Icons.Outlined.BookmarkAdd, contentDescription = null, modifier = Modifier.size(16.dp))
                },
            )
        }

        // Audiobook controls
        AnimatedVisibility(visible = showAudioControls) {
            AudiobookControls(
                isPlaying = isAudioPlaying,
                progress = audioProgress,
                speed = audioSpeed,
                onTogglePlay = onToggleAudio,
                onProgressChange = onAudioProgressChange,
                onSpeedChange = onSpeedChange,
                isDark = isDark,
            )
        }

        Spacer(Modifier.height(24.dp))

        // Sections
        chapter.sections.forEachIndexed { idx, section ->
            Text(
                text = section,
                style = MaterialTheme.typography.headlineSmall,
                color = MaterialTheme.colorScheme.onBackground,
            )
            Spacer(Modifier.height(12.dp))

            // Simulated body text
            val bodyText = generateSectionBody(chapter.number, idx)
            Text(
                text = bodyText,
                style = MaterialTheme.typography.bodyLarge.copy(
                    fontSize = fontSize.sp,
                    lineHeight = (fontSize * 1.6).sp,
                ),
                color = MaterialTheme.colorScheme.onSurface,
            )
            Spacer(Modifier.height(24.dp))

            if (idx < chapter.sections.lastIndex) {
                HorizontalDivider(
                    color = Resonance.goldPrimary.copy(alpha = .15f),
                    modifier = Modifier.padding(vertical = 8.dp),
                )
            }
        }

        Spacer(Modifier.height(40.dp))
    }
}

// ---------------------------------------------------------------------------
// Audiobook controls
// ---------------------------------------------------------------------------

@Composable
private fun AudiobookControls(
    isPlaying: Boolean,
    progress: Float,
    speed: Float,
    onTogglePlay: () -> Unit,
    onProgressChange: (Float) -> Unit,
    onSpeedChange: (Float) -> Unit,
    isDark: Boolean,
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = LuminousThemeExt.colors.glassSurface,
        ),
        border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Progress slider
            Slider(
                value = progress,
                onValueChange = onProgressChange,
                colors = SliderDefaults.colors(
                    thumbColor = Resonance.goldPrimary,
                    activeTrackColor = Resonance.goldPrimary,
                    inactiveTrackColor = Resonance.goldPrimary.copy(alpha = .2f),
                ),
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text(
                    text = formatTime((progress * 900).toInt()),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = formatTime(900),
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Spacer(Modifier.height(8.dp))

            // Playback controls
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                IconButton(onClick = {
                    onProgressChange((progress - 0.033f).coerceAtLeast(0f))
                }) {
                    Icon(Icons.Filled.Replay30, contentDescription = "Back 30s", tint = MaterialTheme.colorScheme.onSurface)
                }

                FilledIconButton(
                    onClick = onTogglePlay,
                    colors = IconButtonDefaults.filledIconButtonColors(
                        containerColor = Resonance.goldPrimary,
                        contentColor = Color.White,
                    ),
                    modifier = Modifier.size(56.dp),
                ) {
                    Icon(
                        if (isPlaying) Icons.Filled.Pause else Icons.Filled.PlayArrow,
                        contentDescription = if (isPlaying) "Pause" else "Play",
                        modifier = Modifier.size(32.dp),
                    )
                }

                IconButton(onClick = {
                    onProgressChange((progress + 0.033f).coerceAtMost(1f))
                }) {
                    Icon(Icons.Filled.Forward30, contentDescription = "Forward 30s", tint = MaterialTheme.colorScheme.onSurface)
                }
            }

            Spacer(Modifier.height(8.dp))

            // Speed control
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                val speeds = listOf(0.75f, 1f, 1.25f, 1.5f, 2f)
                speeds.forEach { s ->
                    FilterChip(
                        selected = speed == s,
                        onClick = { onSpeedChange(s) },
                        label = { Text("${s}x", style = MaterialTheme.typography.labelSmall) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Resonance.goldPrimary.copy(alpha = .2f),
                            selectedLabelColor = Resonance.goldPrimary,
                        ),
                        modifier = Modifier.padding(horizontal = 2.dp),
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Glossary view
// ---------------------------------------------------------------------------

@Composable
private fun GlossaryView(glossary: List<GlossaryEntry>, isDark: Boolean) {
    var searchQuery by remember { mutableStateOf("") }
    val filtered = glossary.filter {
        searchQuery.isEmpty() ||
                it.term.contains(searchQuery, ignoreCase = true) ||
                it.definition.contains(searchQuery, ignoreCase = true)
    }.sortedBy { it.term }

    Column {
        OutlinedTextField(
            value = searchQuery,
            onValueChange = { searchQuery = it },
            label = { Text("Search glossary") },
            leadingIcon = { Icon(Icons.Filled.Search, contentDescription = null) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 8.dp),
            singleLine = true,
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Resonance.goldPrimary,
                cursorColor = Resonance.goldPrimary,
            ),
        )

        LazyColumn(
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
        ) {
            items(filtered) { entry ->
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = LuminousThemeExt.colors.glassSurface),
                    border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                        ) {
                            Text(
                                text = entry.term,
                                style = MaterialTheme.typography.titleMedium,
                                color = Resonance.goldPrimary,
                                fontWeight = FontWeight.Bold,
                            )
                            Text(
                                text = "Ch. ${entry.chapter}",
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = entry.definition,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Highlights view
// ---------------------------------------------------------------------------

@Composable
private fun HighlightsView(highlights: List<Highlight>, isDark: Boolean) {
    LazyColumn(
        contentPadding = PaddingValues(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(highlights) { hl ->
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = LuminousThemeExt.colors.glassSurface),
                border = BorderStroke(1.dp, hl.color.copy(alpha = .3f)),
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(8.dp)
                                .clip(CircleShape)
                                .background(hl.color),
                        )
                        Spacer(Modifier.width(8.dp))
                        Text(
                            text = "Chapter ${hl.chapter}",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = buildAnnotatedString {
                            withStyle(SpanStyle(background = hl.color.copy(alpha = .15f))) {
                                append("\u201C${hl.text}\u201D")
                            }
                        },
                        style = MaterialTheme.typography.bodyLarge.copy(fontStyle = FontStyle.Italic),
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    if (hl.note.isNotEmpty()) {
                        Spacer(Modifier.height(8.dp))
                        Text(
                            text = "Note: ${hl.note}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }

                    Spacer(Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.End, modifier = Modifier.fillMaxWidth()) {
                        IconButton(onClick = { /* share highlight */ }) {
                            Icon(Icons.Outlined.Share, contentDescription = "Share", tint = Resonance.goldPrimary, modifier = Modifier.size(18.dp))
                        }
                        IconButton(onClick = { /* delete */ }) {
                            Icon(Icons.Outlined.Delete, contentDescription = "Delete", tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(18.dp))
                        }
                    }
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Bookmarks view
// ---------------------------------------------------------------------------

@Composable
private fun BookmarksView(
    bookmarks: List<Bookmark>,
    chapters: List<Chapter>,
    isDark: Boolean,
    onJump: (Bookmark) -> Unit,
) {
    LazyColumn(
        contentPadding = PaddingValues(20.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(bookmarks) { bm ->
            val ch = chapters.firstOrNull { it.number == bm.chapter }
            Card(
                onClick = { onJump(bm) },
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = LuminousThemeExt.colors.glassSurface),
                border = BorderStroke(1.dp, LuminousThemeExt.colors.glassBorder),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Filled.Bookmark, contentDescription = null, tint = Resonance.goldPrimary)
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = ch?.title ?: "Chapter ${bm.chapter}",
                            style = MaterialTheme.typography.titleSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                        Text(
                            text = "${bm.section} \u2022 ${bm.label}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                    Icon(Icons.Filled.ArrowForward, contentDescription = null, tint = Resonance.goldPrimary, modifier = Modifier.size(18.dp))
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

private fun formatTime(seconds: Int): String {
    val m = seconds / 60
    val s = seconds % 60
    return "%d:%02d".format(m, s)
}

private fun generateSectionBody(chapter: Int, section: Int): String {
    val bodies = mapOf(
        Pair(3, 0) to """
            Every family carries invisible threads — patterns of relating, believing, and coping that weave through generations like a melody heard but never quite named. To understand your roots is not to assign blame; it is to map the terrain you walk upon.

            Begin by noticing: which of your automatic reactions feel older than you? Which phrases leave your lips before you have chosen them? These are the echoes of your lineage, and they deserve your curiosity rather than your judgement.

            Journaling prompt: Write a letter to the version of your parent or caregiver who was once a frightened child. What do you imagine they needed?
        """.trimIndent(),
        Pair(3, 1) to """
            Culture shapes the lens through which we interpret every experience — success, failure, love, grief, even silence. Some cultures prize stoicism; others celebrate expressive emotion. Neither is wrong, but when a cultural norm conflicts with your authentic experience, a quiet fracture forms inside.

            Recognising cultural imprints is an act of gentle archaeology. You are not rejecting your heritage; you are choosing which threads to carry forward with intention.

            Practice: Name three beliefs you hold that you can trace to a cultural source. For each, ask: does this still serve the person I am becoming?
        """.trimIndent(),
        Pair(3, 2) to """
            There is a deeper layer beneath family patterns and cultural scripts — the ancestral field. Whether you understand this through genetics, epigenetics, or a more spiritual frame, the invitation is the same: your ancestors survived. Their resilience lives in your bones.

            Honouring ancestral wisdom does not require you to repeat ancestral pain. You can be the one who metabolises what they could not, transforming inherited weight into grounded strength.

            Ritual: Light a candle and sit quietly for five minutes. Imagine yourself as the newest leaf on a very old tree. Feel the roots beneath you. Breathe.
        """.trimIndent(),
    )

    return bodies[Pair(chapter, section)]
        ?: """
            This section invites you to slow down and sit with what you are discovering. There is no rush. The work of inner transformation does not follow a schedule — it follows readiness.

            As you read, notice where you feel resistance and where you feel relief. Both are valuable signals from your deeper self, pointing toward the edges of your current understanding.

            Take a moment to breathe before continuing. Place a hand on your heart. Feel the rhythm that has sustained you through every chapter of your life so far. That same rhythm will carry you through this one.
        """.trimIndent()
}
