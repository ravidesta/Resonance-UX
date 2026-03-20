package com.luminous.resonance.ui.reader

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.luminous.resonance.ui.theme.*
import kotlinx.coroutines.launch

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

data class Chapter(
    val id: String,
    val title: String,
    val number: Int,
    val pages: List<PageContent>,
)

data class PageContent(
    val text: String,
    val exercises: List<InlineExercise> = emptyList(),
    val somaticPractice: SomaticPractice? = null,
)

sealed class InlineExercise {
    data class ReflectionQuestion(
        val question: String,
        val hint: String = "",
    ) : InlineExercise()

    data class QuadrantMapping(
        val title: String,
        val quadrants: List<String>,
        val description: String,
    ) : InlineExercise()
}

data class SomaticPractice(
    val title: String,
    val instructions: String,
    val breathCycleDurationMs: Int = 4_000,
    val totalCycles: Int = 4,
)

data class ReadingSettings(
    val fontSize: Float = 18f,
    val lineSpacing: Float = 1.6f,
    val isDarkTheme: Boolean = false,
    val fontFamily: ReaderFont = ReaderFont.CORMORANT,
)

enum class ReaderFont(val label: String) {
    CORMORANT("Cormorant Garamond"),
    MANROPE("Manrope"),
    SYSTEM("System Default"),
}

data class Highlight(
    val startOffset: Int,
    val endOffset: Int,
    val note: String = "",
    val color: HighlightColor = HighlightColor.GOLD,
)

enum class HighlightColor { GOLD, GREEN, NEUTRAL }

// ---------------------------------------------------------------------------
// Book Reader Screen
// ---------------------------------------------------------------------------

/**
 * Full ebook reader composable with paged reading, chapter navigation,
 * inline interactive exercises, somatic practice cards, and reading settings.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookReaderScreen(
    chapters: List<Chapter>,
    currentChapterIndex: Int,
    currentPageIndex: Int,
    readingSettings: ReadingSettings,
    highlights: List<Highlight>,
    onChapterSelected: (Int) -> Unit,
    onPageChanged: (Int) -> Unit,
    onSettingsChanged: (ReadingSettings) -> Unit,
    onHighlightCreated: (Highlight) -> Unit,
    onNavigateBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val scope = rememberCoroutineScope()
    val drawerState = rememberDrawerState(DrawerValue.Closed)
    var showSettingsSheet by rememberSaveable { mutableStateOf(false) }

    val currentChapter = chapters.getOrNull(currentChapterIndex) ?: return
    val totalPages = currentChapter.pages.size
    val pagerState = rememberPagerState(initialPage = currentPageIndex) { totalPages }

    // Sync pager position with callback
    LaunchedEffect(pagerState.currentPage) {
        onPageChanged(pagerState.currentPage)
    }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ChapterDrawerContent(
                chapters = chapters,
                currentChapterIndex = currentChapterIndex,
                onChapterSelected = { index ->
                    onChapterSelected(index)
                    scope.launch { drawerState.close() }
                },
            )
        },
        modifier = modifier,
    ) {
        Scaffold(
            topBar = {
                ReaderTopBar(
                    chapterTitle = currentChapter.title,
                    onNavigateBack = onNavigateBack,
                    onOpenChapters = { scope.launch { drawerState.open() } },
                    onOpenSettings = { showSettingsSheet = true },
                )
            },
            bottomBar = {
                ReadingProgressBar(
                    currentPage = pagerState.currentPage,
                    totalPages = totalPages,
                    chapterNumber = currentChapter.number,
                    totalChapters = chapters.size,
                )
            },
        ) { padding ->
            Box(modifier = Modifier.padding(padding)) {
                OrganicBlobBackground(
                    modifier = Modifier.fillMaxSize(),
                    blobCount = 2,
                    baseColor = ResonanceColors.Green200.copy(alpha = 0.06f),
                    accentColor = ResonanceColors.GoldPrimary.copy(alpha = 0.04f),
                )

                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize(),
                ) { pageIndex ->
                    val page = currentChapter.pages.getOrNull(pageIndex)
                    if (page != null) {
                        ReaderPage(
                            page = page,
                            settings = readingSettings,
                            highlights = highlights,
                            onHighlightCreated = onHighlightCreated,
                        )
                    }
                }
            }
        }

        // Reading Settings Bottom Sheet
        if (showSettingsSheet) {
            ReadingSettingsSheet(
                settings = readingSettings,
                onSettingsChanged = onSettingsChanged,
                onDismiss = { showSettingsSheet = false },
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Reader Top Bar
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ReaderTopBar(
    chapterTitle: String,
    onNavigateBack: () -> Unit,
    onOpenChapters: () -> Unit,
    onOpenSettings: () -> Unit,
) {
    TopAppBar(
        title = {
            Text(
                text = chapterTitle,
                style = MaterialTheme.typography.titleMedium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
        },
        navigationIcon = {
            IconButton(
                onClick = onNavigateBack,
                modifier = Modifier.semantics { contentDescription = "Navigate back" },
            ) {
                Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
            }
        },
        actions = {
            IconButton(
                onClick = onOpenChapters,
                modifier = Modifier.semantics { contentDescription = "Open chapter list" },
            ) {
                Icon(Icons.AutoMirrored.Filled.MenuBook, contentDescription = null)
            }
            IconButton(
                onClick = onOpenSettings,
                modifier = Modifier.semantics { contentDescription = "Reading settings" },
            ) {
                Icon(Icons.Default.Settings, contentDescription = null)
            }
        },
        colors = TopAppBarDefaults.topAppBarColors(
            containerColor = MaterialTheme.colorScheme.surface.copy(alpha = 0.92f),
        ),
    )
}

// ---------------------------------------------------------------------------
// Chapter Drawer
// ---------------------------------------------------------------------------

@Composable
private fun ChapterDrawerContent(
    chapters: List<Chapter>,
    currentChapterIndex: Int,
    onChapterSelected: (Int) -> Unit,
) {
    ModalDrawerSheet(
        drawerContainerColor = MaterialTheme.colorScheme.surface,
        modifier = Modifier.width(300.dp),
    ) {
        Spacer(Modifier.height(24.dp))
        Text(
            text = "Chapters",
            style = MaterialTheme.typography.headlineSmall,
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
        )
        HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
        Spacer(Modifier.height(8.dp))

        LazyColumn {
            items(chapters.size) { index ->
                val chapter = chapters[index]
                val isSelected = index == currentChapterIndex
                NavigationDrawerItem(
                    label = {
                        Text(
                            text = "${chapter.number}. ${chapter.title}",
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    },
                    selected = isSelected,
                    onClick = { onChapterSelected(index) },
                    modifier = Modifier.padding(horizontal = 12.dp),
                    colors = NavigationDrawerItemDefaults.colors(
                        selectedContainerColor = MaterialTheme.colorScheme.primaryContainer,
                    ),
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Reader Page
// ---------------------------------------------------------------------------

@Composable
private fun ReaderPage(
    page: PageContent,
    settings: ReadingSettings,
    highlights: List<Highlight>,
    onHighlightCreated: (Highlight) -> Unit,
) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState)
            .padding(horizontal = 24.dp, vertical = 16.dp),
    ) {
        // Main reading text
        SelectionContainer {
            Text(
                text = AnnotatedString(page.text),
                style = MaterialTheme.typography.bodyLarge.copy(
                    fontSize = settings.fontSize.sp,
                    lineHeight = (settings.fontSize * settings.lineSpacing).sp,
                ),
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = "Book content" },
            )
        }

        Spacer(Modifier.height(24.dp))

        // Inline exercises
        page.exercises.forEach { exercise ->
            when (exercise) {
                is InlineExercise.ReflectionQuestion -> {
                    ReflectionQuestionCard(exercise)
                }
                is InlineExercise.QuadrantMapping -> {
                    QuadrantMappingCard(exercise)
                }
            }
            Spacer(Modifier.height(16.dp))
        }

        // Somatic practice card
        page.somaticPractice?.let { practice ->
            SomaticPracticeCard(practice)
            Spacer(Modifier.height(16.dp))
        }

        Spacer(Modifier.height(80.dp))
    }
}

// ---------------------------------------------------------------------------
// Reflection Question Card
// ---------------------------------------------------------------------------

@Composable
private fun ReflectionQuestionCard(question: InlineExercise.ReflectionQuestion) {
    var response by rememberSaveable { mutableStateOf("") }
    var isExpanded by rememberSaveable { mutableStateOf(false) }

    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Default.Lightbulb,
                    contentDescription = null,
                    tint = ResonanceTheme.extendedColors.gold,
                    modifier = Modifier.size(20.dp),
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "Reflection",
                    style = MaterialTheme.typography.labelLarge,
                    color = ResonanceTheme.extendedColors.gold,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = question.question,
                style = MaterialTheme.typography.bodyLarge,
            )

            AnimatedVisibility(visible = isExpanded) {
                Column {
                    Spacer(Modifier.height(12.dp))
                    if (question.hint.isNotEmpty()) {
                        Text(
                            text = question.hint,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                        Spacer(Modifier.height(8.dp))
                    }
                    OutlinedTextField(
                        value = response,
                        onValueChange = { response = it },
                        label = { Text("Your reflection") },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 3,
                    )
                }
            }

            Spacer(Modifier.height(8.dp))
            TextButton(onClick = { isExpanded = !isExpanded }) {
                Text(if (isExpanded) "Collapse" else "Reflect on this")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Quadrant Mapping Card
// ---------------------------------------------------------------------------

@Composable
private fun QuadrantMappingCard(mapping: InlineExercise.QuadrantMapping) {
    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text(
                text = mapping.title,
                style = MaterialTheme.typography.titleMedium,
                color = ResonanceTheme.extendedColors.gold,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = mapping.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(Modifier.height(16.dp))

            // 2x2 Quadrant grid
            if (mapping.quadrants.size >= 4) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(ResonanceShapes.small)
                        .border(
                            1.dp,
                            MaterialTheme.colorScheme.outlineVariant,
                            ResonanceShapes.small,
                        ),
                ) {
                    Row(Modifier.fillMaxWidth()) {
                        QuadrantCell(mapping.quadrants[0], Modifier.weight(1f))
                        VerticalDivider(modifier = Modifier.height(80.dp))
                        QuadrantCell(mapping.quadrants[1], Modifier.weight(1f))
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth()) {
                        QuadrantCell(mapping.quadrants[2], Modifier.weight(1f))
                        VerticalDivider(modifier = Modifier.height(80.dp))
                        QuadrantCell(mapping.quadrants[3], Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

@Composable
private fun QuadrantCell(text: String, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .heightIn(min = 80.dp)
            .padding(12.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodySmall,
            textAlign = TextAlign.Center,
        )
    }
}

// ---------------------------------------------------------------------------
// Somatic Practice Card
// ---------------------------------------------------------------------------

@Composable
private fun SomaticPracticeCard(practice: SomaticPractice) {
    var isActive by rememberSaveable { mutableStateOf(false) }
    var cyclesCompleted by rememberSaveable { mutableIntStateOf(0) }
    val breathScale by rememberBreathingAnimation(
        min = 0.8f,
        max = 1.2f,
        durationMs = practice.breathCycleDurationMs,
    )

    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.medium,
    ) {
        Column(
            modifier = Modifier.padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Default.SelfImprovement,
                    contentDescription = null,
                    tint = ResonanceColors.Green500,
                    modifier = Modifier.size(20.dp),
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "Somatic Practice",
                    style = MaterialTheme.typography.labelLarge,
                    color = ResonanceColors.Green500,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = practice.title,
                style = MaterialTheme.typography.titleMedium,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = practice.instructions,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            Spacer(Modifier.height(20.dp))

            // Breathing circle animation
            AnimatedVisibility(visible = isActive) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        modifier = Modifier
                            .size(120.dp)
                            .scale(breathScale)
                            .clip(CircleShape)
                            .background(
                                ResonanceColors.Green400.copy(alpha = 0.2f),
                                CircleShape,
                            )
                            .semantics {
                                contentDescription = "Breathing animation circle"
                            },
                        contentAlignment = Alignment.Center,
                    ) {
                        Box(
                            modifier = Modifier
                                .size(60.dp)
                                .clip(CircleShape)
                                .background(
                                    ResonanceColors.Green500.copy(alpha = 0.3f),
                                    CircleShape,
                                ),
                        )
                    }
                    Spacer(Modifier.height(12.dp))
                    Text(
                        text = if (breathScale > 1f) "Breathe in..." else "Breathe out...",
                        style = MaterialTheme.typography.bodyMedium,
                        color = ResonanceColors.Green500,
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = "$cyclesCompleted / ${practice.totalCycles} cycles",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(Modifier.height(16.dp))
                }
            }

            FilledTonalButton(
                onClick = { isActive = !isActive },
                colors = ButtonDefaults.filledTonalButtonColors(
                    containerColor = ResonanceColors.Green200,
                    contentColor = ResonanceColors.Green800,
                ),
            ) {
                Text(if (isActive) "End Practice" else "Begin Practice")
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Reading Progress Bar
// ---------------------------------------------------------------------------

@Composable
private fun ReadingProgressBar(
    currentPage: Int,
    totalPages: Int,
    chapterNumber: Int,
    totalChapters: Int,
) {
    val progress = if (totalPages > 1) (currentPage + 1).toFloat() / totalPages else 1f

    Surface(
        color = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f),
        tonalElevation = 2.dp,
    ) {
        Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp)
                    .clip(RoundedCornerShape(2.dp))
                    .semantics {
                        contentDescription =
                            "Reading progress: page ${currentPage + 1} of $totalPages"
                    },
                color = ResonanceTheme.extendedColors.gold,
                trackColor = MaterialTheme.colorScheme.surfaceVariant,
            )
            Spacer(Modifier.height(4.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text(
                    text = "Chapter $chapterNumber of $totalChapters",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = "Page ${currentPage + 1} of $totalPages",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Reading Settings Bottom Sheet
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ReadingSettingsSheet(
    settings: ReadingSettings,
    onSettingsChanged: (ReadingSettings) -> Unit,
    onDismiss: () -> Unit,
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = MaterialTheme.colorScheme.surface,
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp),
        ) {
            Text(
                text = "Reading Settings",
                style = MaterialTheme.typography.titleLarge,
            )
            Spacer(Modifier.height(24.dp))

            // Font Size
            Text("Font Size", style = MaterialTheme.typography.labelLarge)
            Spacer(Modifier.height(8.dp))
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Text(
                    "A",
                    style = MaterialTheme.typography.bodySmall,
                    modifier = Modifier.width(24.dp),
                )
                Slider(
                    value = settings.fontSize,
                    onValueChange = { onSettingsChanged(settings.copy(fontSize = it)) },
                    valueRange = 14f..28f,
                    modifier = Modifier.weight(1f),
                    colors = SliderDefaults.colors(
                        thumbColor = ResonanceTheme.extendedColors.gold,
                        activeTrackColor = ResonanceTheme.extendedColors.gold,
                    ),
                )
                Text(
                    "A",
                    style = MaterialTheme.typography.headlineSmall,
                    modifier = Modifier.width(32.dp),
                )
            }

            Spacer(Modifier.height(20.dp))

            // Line Spacing
            Text("Line Spacing", style = MaterialTheme.typography.labelLarge)
            Spacer(Modifier.height(8.dp))
            Slider(
                value = settings.lineSpacing,
                onValueChange = { onSettingsChanged(settings.copy(lineSpacing = it)) },
                valueRange = 1.2f..2.2f,
                modifier = Modifier.fillMaxWidth(),
                colors = SliderDefaults.colors(
                    thumbColor = ResonanceTheme.extendedColors.gold,
                    activeTrackColor = ResonanceTheme.extendedColors.gold,
                ),
            )
            Text(
                text = "%.1fx".format(settings.lineSpacing),
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )

            Spacer(Modifier.height(20.dp))

            // Font selection
            Text("Font", style = MaterialTheme.typography.labelLarge)
            Spacer(Modifier.height(8.dp))
            SingleChoiceSegmentedButtonRow(modifier = Modifier.fillMaxWidth()) {
                ReaderFont.entries.forEachIndexed { index, font ->
                    SegmentedButton(
                        selected = settings.fontFamily == font,
                        onClick = { onSettingsChanged(settings.copy(fontFamily = font)) },
                        shape = SegmentedButtonDefaults.itemShape(
                            index = index,
                            count = ReaderFont.entries.size,
                        ),
                    ) {
                        Text(
                            text = font.label,
                            style = MaterialTheme.typography.labelSmall,
                            maxLines = 1,
                        )
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // Theme toggle
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text("Dark Reading Mode", style = MaterialTheme.typography.labelLarge)
                Switch(
                    checked = settings.isDarkTheme,
                    onCheckedChange = { onSettingsChanged(settings.copy(isDarkTheme = it)) },
                    colors = SwitchDefaults.colors(
                        checkedTrackColor = ResonanceColors.Green700,
                    ),
                )
            }
        }
    }
}
