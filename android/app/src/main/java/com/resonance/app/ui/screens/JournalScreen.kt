package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDate
import java.time.LocalTime
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle as DateTextStyle
import java.util.Locale
import java.util.UUID

// ── Design Tokens ──────────────────────────────────────────────────────────────
private val ForestGreen = Color(0xFF2D734D)
private val SageGreen = Color(0xFF7A8B69)
private val WarmGold = Color(0xFFC5A059)
private val Cream = Color(0xFFFAFAF8)
private val LightGreen = Color(0xFFE8F0EC)
private val DeepBg = Color(0xFF0D1A12)
private val DeepCard = Color(0xFF1E3628)

// ── Data Models ────────────────────────────────────────────────────────────────

enum class FlowPhase(val label: String, val color: Color) {
    ASCEND("Ascend", Color(0xFFE3C06E)),
    ZENITH("Zenith", Color(0xFF5BA37B)),
    DESCENT("Descent", Color(0xFFB08D4A)),
    REST("Rest", Color(0xFF78B392))
}

enum class MoodLevel(val label: String, val value: Int) {
    RADIANT("Radiant", 5),
    BRIGHT("Bright", 4),
    STEADY("Steady", 3),
    LOW("Low", 2),
    HEAVY("Heavy", 1)
}

enum class EnergyState(val label: String, val color: Color) {
    HIGH("High", Color(0xFF5BA37B)),
    BALANCED("Balanced", Color(0xFF78B392)),
    MODERATE("Moderate", Color(0xFFE3C06E)),
    LOW("Low", Color(0xFFB08D4A)),
    DEPLETED("Depleted", Color(0xFF9A9A90))
}

data class JournalEntry(
    val id: String = UUID.randomUUID().toString(),
    val date: LocalDate = LocalDate.now(),
    val time: LocalTime = LocalTime.now(),
    val phase: FlowPhase = FlowPhase.ZENITH,
    val mood: MoodLevel = MoodLevel.STEADY,
    val energy: EnergyState = EnergyState.BALANCED,
    val reflectionPrompt: String = "",
    val reflectionText: String = "",
    val gratitudeEntries: List<String> = emptyList(),
    val tags: List<String> = emptyList(),
    val isBookmarked: Boolean = false
)

data class ReflectionPrompt(
    val text: String,
    val phase: FlowPhase,
    val category: String
)

// ── Phase-Aware Prompts ────────────────────────────────────────────────────────

private fun promptsForPhase(phase: FlowPhase): List<ReflectionPrompt> = when (phase) {
    FlowPhase.ASCEND -> listOf(
        ReflectionPrompt("What intention would make today feel spacious?", phase, "intention"),
        ReflectionPrompt("What does your body need as you begin this day?", phase, "body"),
        ReflectionPrompt("If today had a single theme, what would you choose?", phase, "focus"),
    )
    FlowPhase.ZENITH -> listOf(
        ReflectionPrompt("What's energizing you right now?", phase, "energy"),
        ReflectionPrompt("Where are you finding flow in this moment?", phase, "flow"),
        ReflectionPrompt("What thought deserves your full attention today?", phase, "depth"),
    )
    FlowPhase.DESCENT -> listOf(
        ReflectionPrompt("What can you gently release from today?", phase, "release"),
        ReflectionPrompt("What moment brought you unexpected calm?", phase, "calm"),
        ReflectionPrompt("How did your energy shift through the day?", phase, "reflection"),
    )
    FlowPhase.REST -> listOf(
        ReflectionPrompt("What are you grateful for as this day closes?", phase, "gratitude"),
        ReflectionPrompt("What would you carry forward into tomorrow?", phase, "carry"),
        ReflectionPrompt("How does stillness feel right now?", phase, "stillness"),
    )
}

// ── Main Journal Screen ────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun JournalScreen(
    isDeepRest: Boolean = false,
    onBack: () -> Unit = {}
) {
    val bgColor = if (isDeepRest) DeepBg else Cream
    val surfaceColor = if (isDeepRest) DeepCard else Color.White
    val textColor = if (isDeepRest) Color(0xFFC5DDD0) else Color(0xFF3A4840)

    var selectedView by remember { mutableStateOf("today") } // "today" | "calendar" | "entry"
    var editingEntry by remember { mutableStateOf<JournalEntry?>(null) }
    val entries = remember { mutableStateListOf<JournalEntry>() }
    val currentPhase = remember { getCurrentPhase() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        when (selectedView) {
                            "entry" -> "New Entry"
                            "calendar" -> "Journal History"
                            else -> "Journal"
                        },
                        fontWeight = FontWeight.Medium,
                        color = textColor
                    )
                },
                navigationIcon = {
                    if (selectedView != "today") {
                        IconButton(onClick = { selectedView = "today"; editingEntry = null }) {
                            Icon(Icons.Default.ArrowBack, "Back", tint = textColor)
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = bgColor),
                actions = {
                    if (selectedView == "today") {
                        IconButton(onClick = { selectedView = "calendar" }) {
                            Text("Cal", color = WarmGold, fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }
            )
        },
        floatingActionButton = {
            if (selectedView == "today") {
                FloatingActionButton(
                    onClick = {
                        editingEntry = JournalEntry(phase = currentPhase)
                        selectedView = "entry"
                    },
                    containerColor = ForestGreen,
                    contentColor = Color.White,
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Icon(Icons.Default.Add, "New Entry")
                }
            }
        },
        containerColor = bgColor
    ) { padding ->
        AnimatedContent(
            targetState = selectedView,
            label = "journal-view"
        ) { view ->
            when (view) {
                "today" -> TodayView(
                    modifier = Modifier.padding(padding),
                    entries = entries,
                    currentPhase = currentPhase,
                    isDeepRest = isDeepRest,
                    surfaceColor = surfaceColor,
                    textColor = textColor,
                    onEntryClick = { editingEntry = it; selectedView = "entry" }
                )
                "calendar" -> CalendarHeatMap(
                    modifier = Modifier.padding(padding),
                    entries = entries,
                    isDeepRest = isDeepRest,
                    surfaceColor = surfaceColor,
                    textColor = textColor
                )
                "entry" -> EntryEditor(
                    modifier = Modifier.padding(padding),
                    entry = editingEntry ?: JournalEntry(phase = currentPhase),
                    isDeepRest = isDeepRest,
                    surfaceColor = surfaceColor,
                    textColor = textColor,
                    onSave = { saved ->
                        val idx = entries.indexOfFirst { it.id == saved.id }
                        if (idx >= 0) entries[idx] = saved else entries.add(0, saved)
                        selectedView = "today"
                        editingEntry = null
                    }
                )
            }
        }
    }
}

// ── Today View ─────────────────────────────────────────────────────────────────

@Composable
private fun TodayView(
    modifier: Modifier,
    entries: List<JournalEntry>,
    currentPhase: FlowPhase,
    isDeepRest: Boolean,
    surfaceColor: Color,
    textColor: Color,
    onEntryClick: (JournalEntry) -> Unit
) {
    val todayEntries = entries.filter { it.date == LocalDate.now() }
    val prompts = promptsForPhase(currentPhase)

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Phase indicator
        item {
            PhaseHeader(currentPhase, isDeepRest, textColor)
        }

        // Daily prompt card
        item {
            PromptCard(
                prompts = prompts,
                surfaceColor = surfaceColor,
                textColor = textColor,
                isDeepRest = isDeepRest
            )
        }

        // Mood & Energy quick entry
        item {
            MoodEnergyCard(surfaceColor, textColor, isDeepRest)
        }

        // Today's entries
        if (todayEntries.isNotEmpty()) {
            item {
                Text(
                    "Today's Reflections",
                    style = MaterialTheme.typography.titleMedium,
                    color = textColor,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
            items(todayEntries) { entry ->
                EntryCard(entry, surfaceColor, textColor, isDeepRest, onClick = { onEntryClick(entry) })
            }
        }

        // Gratitude section
        item {
            GratitudeSection(surfaceColor, textColor, isDeepRest)
        }

        item { Spacer(Modifier.height(80.dp)) }
    }
}

// ── Phase Header ───────────────────────────────────────────────────────────────

@Composable
private fun PhaseHeader(phase: FlowPhase, isDeepRest: Boolean, textColor: Color) {
    val transition = rememberInfiniteTransition(label = "phase-pulse")
    val pulseAlpha by transition.animateFloat(
        initialValue = 0.6f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(3000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "pulse"
    )

    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(
                Brush.horizontalGradient(
                    listOf(phase.color.copy(alpha = 0.15f), Color.Transparent)
                )
            )
            .padding(16.dp)
    ) {
        Box(
            modifier = Modifier
                .size(12.dp)
                .alpha(pulseAlpha)
                .clip(CircleShape)
                .background(phase.color)
        )
        Spacer(Modifier.width(12.dp))
        Column {
            Text(
                "Current Phase",
                fontSize = 12.sp,
                color = textColor.copy(alpha = 0.6f),
                fontWeight = FontWeight.Medium
            )
            Text(
                phase.label,
                fontSize = 20.sp,
                fontWeight = FontWeight.SemiBold,
                color = phase.color
            )
        }
        Spacer(Modifier.weight(1f))
        Text(
            LocalDate.now().format(DateTimeFormatter.ofPattern("EEEE, MMM d")),
            fontSize = 14.sp,
            color = textColor.copy(alpha = 0.5f)
        )
    }
}

// ── Prompt Card ────────────────────────────────────────────────────────────────

@Composable
private fun PromptCard(
    prompts: List<ReflectionPrompt>,
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean
) {
    var currentPromptIndex by remember { mutableIntStateOf(0) }
    val prompt = prompts[currentPromptIndex % prompts.size]

    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = surfaceColor),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isDeepRest) 0.dp else 2.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clickable { currentPromptIndex++ }
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Text(
                "Reflection Prompt",
                fontSize = 12.sp,
                fontWeight = FontWeight.Bold,
                color = WarmGold,
                letterSpacing = 1.sp
            )
            Spacer(Modifier.height(12.dp))
            Text(
                prompt.text,
                fontSize = 22.sp,
                fontWeight = FontWeight.Normal,
                fontStyle = FontStyle.Italic,
                color = textColor,
                lineHeight = 30.sp
            )
            Spacer(Modifier.height(16.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(prompt.phase.color)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    prompt.category.replaceFirstChar { it.uppercase() },
                    fontSize = 12.sp,
                    color = textColor.copy(alpha = 0.5f)
                )
                Spacer(Modifier.weight(1f))
                Text(
                    "Tap for another",
                    fontSize = 11.sp,
                    color = textColor.copy(alpha = 0.3f)
                )
            }
        }
    }
}

// ── Mood & Energy Card ─────────────────────────────────────────────────────────

@OptIn(ExperimentalLayoutApi::class)
@Composable
private fun MoodEnergyCard(
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean
) {
    var selectedMood by remember { mutableStateOf<MoodLevel?>(null) }
    var selectedEnergy by remember { mutableStateOf<EnergyState?>(null) }

    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = surfaceColor),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isDeepRest) 0.dp else 2.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text("How are you feeling?", fontSize = 16.sp, fontWeight = FontWeight.Medium, color = textColor)
            Spacer(Modifier.height(12.dp))

            // Mood selector
            Text("Mood", fontSize = 12.sp, color = textColor.copy(alpha = 0.5f), fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                MoodLevel.entries.forEach { mood ->
                    val isSelected = selectedMood == mood
                    val bgColor by animateColorAsState(
                        if (isSelected) ForestGreen.copy(alpha = 0.15f) else Color.Transparent,
                        label = "mood-bg"
                    )
                    Surface(
                        shape = RoundedCornerShape(12.dp),
                        color = bgColor,
                        modifier = Modifier
                            .clip(RoundedCornerShape(12.dp))
                            .clickable { selectedMood = mood }
                            .then(
                                if (isSelected) Modifier.border(1.dp, ForestGreen, RoundedCornerShape(12.dp))
                                else Modifier.border(1.dp, textColor.copy(alpha = 0.1f), RoundedCornerShape(12.dp))
                            )
                    ) {
                        Text(
                            mood.label,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
                            fontSize = 13.sp,
                            fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                            color = if (isSelected) ForestGreen else textColor.copy(alpha = 0.7f)
                        )
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // Energy selector
            Text("Energy", fontSize = 12.sp, color = textColor.copy(alpha = 0.5f), fontWeight = FontWeight.Bold)
            Spacer(Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                EnergyState.entries.forEach { energy ->
                    val isSelected = selectedEnergy == energy
                    val barHeight by animateFloatAsState(
                        if (isSelected) 40f else 24f,
                        animationSpec = tween(300),
                        label = "bar"
                    )
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier
                            .weight(1f)
                            .clickable { selectedEnergy = energy }
                    ) {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(barHeight.dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(
                                    if (isSelected) energy.color
                                    else energy.color.copy(alpha = 0.3f)
                                )
                        )
                        Spacer(Modifier.height(4.dp))
                        Text(
                            energy.label,
                            fontSize = 9.sp,
                            color = if (isSelected) energy.color else textColor.copy(alpha = 0.4f),
                            textAlign = TextAlign.Center
                        )
                    }
                }
            }
        }
    }
}

// ── Entry Card ─────────────────────────────────────────────────────────────────

@Composable
private fun EntryCard(
    entry: JournalEntry,
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean,
    onClick: () -> Unit
) {
    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = surfaceColor),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isDeepRest) 0.dp else 1.dp),
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(8.dp)
                        .clip(CircleShape)
                        .background(entry.phase.color)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    entry.time.format(DateTimeFormatter.ofPattern("h:mm a")),
                    fontSize = 13.sp,
                    color = textColor.copy(alpha = 0.5f)
                )
                Spacer(Modifier.weight(1f))
                if (entry.isBookmarked) {
                    Icon(Icons.Default.Favorite, "Bookmarked", tint = WarmGold, modifier = Modifier.size(16.dp))
                }
            }
            if (entry.reflectionText.isNotEmpty()) {
                Spacer(Modifier.height(8.dp))
                Text(
                    entry.reflectionText.take(120) + if (entry.reflectionText.length > 120) "..." else "",
                    fontSize = 14.sp,
                    color = textColor,
                    lineHeight = 20.sp
                )
            }
            if (entry.gratitudeEntries.isNotEmpty()) {
                Spacer(Modifier.height(8.dp))
                entry.gratitudeEntries.take(2).forEach { g ->
                    Text("  $g", fontSize = 13.sp, color = SageGreen, lineHeight = 18.sp)
                }
            }
        }
    }
}

// ── Gratitude Section ──────────────────────────────────────────────────────────

@Composable
private fun GratitudeSection(
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean
) {
    val gratitudeItems = remember { mutableStateListOf<String>() }
    var newGratitude by remember { mutableStateOf("") }

    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = surfaceColor),
        elevation = CardDefaults.cardElevation(defaultElevation = if (isDeepRest) 0.dp else 2.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp).animateContentSize()) {
            Text("Gratitude", fontSize = 16.sp, fontWeight = FontWeight.Medium, color = textColor)
            Text(
                "Three things you appreciate today",
                fontSize = 12.sp,
                color = textColor.copy(alpha = 0.5f)
            )
            Spacer(Modifier.height(12.dp))

            gratitudeItems.forEachIndexed { index, item ->
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(vertical = 4.dp)
                ) {
                    Icon(
                        Icons.Outlined.FavoriteBorder,
                        contentDescription = null,
                        tint = WarmGold,
                        modifier = Modifier.size(16.dp)
                    )
                    Spacer(Modifier.width(8.dp))
                    Text(item, fontSize = 14.sp, color = textColor)
                }
            }

            if (gratitudeItems.size < 3) {
                Spacer(Modifier.height(8.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    BasicTextField(
                        value = newGratitude,
                        onValueChange = { newGratitude = it },
                        textStyle = TextStyle(fontSize = 14.sp, color = textColor),
                        modifier = Modifier.weight(1f),
                        decorationBox = { inner ->
                            Box {
                                if (newGratitude.isEmpty()) {
                                    Text(
                                        "I'm grateful for...",
                                        fontSize = 14.sp,
                                        color = textColor.copy(alpha = 0.3f)
                                    )
                                }
                                inner()
                            }
                        }
                    )
                    if (newGratitude.isNotEmpty()) {
                        IconButton(onClick = {
                            gratitudeItems.add(newGratitude)
                            newGratitude = ""
                        }) {
                            Icon(Icons.Default.Check, "Add", tint = ForestGreen, modifier = Modifier.size(20.dp))
                        }
                    }
                }
            }
        }
    }
}

// ── Entry Editor ───────────────────────────────────────────────────────────────

@Composable
private fun EntryEditor(
    modifier: Modifier,
    entry: JournalEntry,
    isDeepRest: Boolean,
    surfaceColor: Color,
    textColor: Color,
    onSave: (JournalEntry) -> Unit
) {
    var reflectionText by remember { mutableStateOf(entry.reflectionText) }
    var isBookmarked by remember { mutableStateOf(entry.isBookmarked) }
    val prompt = promptsForPhase(entry.phase).firstOrNull()

    LazyColumn(
        modifier = modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Prompt display
        if (prompt != null) {
            item {
                Text(
                    prompt.text,
                    fontSize = 20.sp,
                    fontStyle = FontStyle.Italic,
                    color = textColor.copy(alpha = 0.7f),
                    lineHeight = 28.sp,
                    modifier = Modifier.padding(vertical = 8.dp)
                )
            }
        }

        // Text editor
        item {
            Card(
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = surfaceColor),
                modifier = Modifier.fillMaxWidth()
            ) {
                BasicTextField(
                    value = reflectionText,
                    onValueChange = { reflectionText = it },
                    textStyle = TextStyle(
                        fontSize = 16.sp,
                        color = textColor,
                        lineHeight = 26.sp
                    ),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(300.dp)
                        .padding(20.dp),
                    decorationBox = { inner ->
                        Box {
                            if (reflectionText.isEmpty()) {
                                Text(
                                    "Begin writing...",
                                    fontSize = 16.sp,
                                    color = textColor.copy(alpha = 0.25f)
                                )
                            }
                            inner()
                        }
                    }
                )
            }
        }

        // Actions
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = { isBookmarked = !isBookmarked }) {
                    Icon(
                        if (isBookmarked) Icons.Default.Favorite else Icons.Outlined.FavoriteBorder,
                        "Bookmark",
                        tint = if (isBookmarked) WarmGold else textColor.copy(alpha = 0.3f)
                    )
                }
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = ForestGreen,
                    modifier = Modifier.clickable {
                        onSave(entry.copy(reflectionText = reflectionText, isBookmarked = isBookmarked))
                    }
                ) {
                    Text(
                        "Save Entry",
                        modifier = Modifier.padding(horizontal = 24.dp, vertical = 12.dp),
                        color = Color.White,
                        fontWeight = FontWeight.SemiBold,
                        fontSize = 14.sp
                    )
                }
            }
        }
    }
}

// ── Calendar Heat Map ──────────────────────────────────────────────────────────

@Composable
private fun CalendarHeatMap(
    modifier: Modifier,
    entries: List<JournalEntry>,
    isDeepRest: Boolean,
    surfaceColor: Color,
    textColor: Color
) {
    val currentMonth = remember { YearMonth.now() }
    val daysInMonth = currentMonth.lengthOfMonth()
    val entriesByDate = entries.groupBy { it.date }

    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            currentMonth.month.getDisplayName(DateTextStyle.FULL, Locale.getDefault()) + " " + currentMonth.year,
            fontSize = 20.sp,
            fontWeight = FontWeight.SemiBold,
            color = textColor
        )
        Spacer(Modifier.height(4.dp))
        Text(
            "${entries.count { it.date.month == currentMonth.month }} entries this month",
            fontSize = 13.sp,
            color = textColor.copy(alpha = 0.5f)
        )
        Spacer(Modifier.height(24.dp))

        // Day labels
        Row(modifier = Modifier.fillMaxWidth()) {
            listOf("S", "M", "T", "W", "T", "F", "S").forEach { day ->
                Text(
                    day,
                    modifier = Modifier.weight(1f),
                    textAlign = TextAlign.Center,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = textColor.copy(alpha = 0.4f)
                )
            }
        }
        Spacer(Modifier.height(8.dp))

        // Calendar grid
        val firstDayOfWeek = currentMonth.atDay(1).dayOfWeek.value % 7
        val totalCells = firstDayOfWeek + daysInMonth
        val rows = (totalCells + 6) / 7

        for (row in 0 until rows) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                for (col in 0..6) {
                    val cellIndex = row * 7 + col
                    val dayNum = cellIndex - firstDayOfWeek + 1

                    if (dayNum in 1..daysInMonth) {
                        val date = currentMonth.atDay(dayNum)
                        val dayEntries = entriesByDate[date] ?: emptyList()
                        val intensity = (dayEntries.size.coerceAtMost(3) / 3f)
                        val isToday = date == LocalDate.now()

                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .padding(2.dp)
                                .size(40.dp)
                                .clip(RoundedCornerShape(10.dp))
                                .background(
                                    if (dayEntries.isNotEmpty()) ForestGreen.copy(alpha = 0.15f + intensity * 0.5f)
                                    else Color.Transparent
                                )
                                .then(
                                    if (isToday) Modifier.border(1.5.dp, WarmGold, RoundedCornerShape(10.dp))
                                    else Modifier
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                "$dayNum",
                                fontSize = 13.sp,
                                fontWeight = if (isToday) FontWeight.Bold else FontWeight.Normal,
                                color = if (dayEntries.isNotEmpty()) ForestGreen
                                else textColor.copy(alpha = 0.4f)
                            )
                        }
                    } else {
                        Spacer(Modifier.weight(1f))
                    }
                }
            }
        }
    }
}

// ── Utility ────────────────────────────────────────────────────────────────────

private fun getCurrentPhase(): FlowPhase {
    val hour = LocalTime.now().hour
    return when {
        hour in 6..9 -> FlowPhase.ASCEND
        hour in 10..14 -> FlowPhase.ZENITH
        hour in 15..19 -> FlowPhase.DESCENT
        else -> FlowPhase.REST
    }
}
