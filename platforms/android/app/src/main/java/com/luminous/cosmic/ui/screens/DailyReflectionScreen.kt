package com.luminous.cosmic.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ArrowBack
import androidx.compose.material.icons.outlined.Add
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.components.CosmicBackground
import com.luminous.cosmic.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DailyReflectionScreen(
    dailyInsight: DailyInsight,
    isDarkTheme: Boolean,
    onBack: () -> Unit
) {
    var journalEntries by remember {
        mutableStateOf(
            listOf(
                JournalEntry(
                    prompt = "What patterns are you noticing in your life right now?",
                    content = "",
                    mood = ""
                )
            )
        )
    }
    var showJournalEditor by remember { mutableStateOf(false) }
    var activeEntry by remember { mutableStateOf<JournalEntry?>(null) }

    val prompts = remember {
        listOf(
            "What cosmic patterns are mirroring in your inner world today?",
            "How is the current moon phase influencing your emotional state?",
            "What area of growth is the universe inviting you to explore?",
            "Describe a moment today when you felt aligned with your purpose.",
            "What is your soul asking you to release right now?",
            "How can you honor your natal chart's wisdom today?",
            "What message does the current transit hold for you?",
            "Reflect on how your Sun sign's energy is expressing itself."
        )
    }

    CosmicBackground(isDarkTheme = isDarkTheme) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
        ) {
            // Top bar
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(
                        Icons.Outlined.ArrowBack,
                        contentDescription = "Back",
                        tint = ResonanceColors.GoldPrimary
                    )
                }
                Text(
                    text = "Daily Reflections",
                    style = MaterialTheme.typography.titleLarge,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.Light,
                    modifier = Modifier.weight(1f)
                )
                IconButton(onClick = {
                    val randomPrompt = prompts.random()
                    activeEntry = JournalEntry(prompt = randomPrompt)
                    showJournalEditor = true
                }) {
                    Icon(
                        Icons.Outlined.Add,
                        contentDescription = "New Entry",
                        tint = ResonanceColors.GoldPrimary
                    )
                }
            }

            if (showJournalEditor && activeEntry != null) {
                // Journal Editor
                JournalEditor(
                    entry = activeEntry!!,
                    onSave = { savedEntry ->
                        journalEntries = journalEntries + savedEntry
                        showJournalEditor = false
                        activeEntry = null
                    },
                    onCancel = {
                        showJournalEditor = false
                        activeEntry = null
                    }
                )
            } else {
                // Main content
                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Today's reflection card
                    item {
                        GlassCard(
                            modifier = Modifier.fillMaxWidth(),
                            cornerRadius = 24.dp
                        ) {
                            Column(modifier = Modifier.padding(20.dp)) {
                                Text(
                                    text = "Today's Cosmic Reflection",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = ResonanceColors.GoldPrimary,
                                    fontWeight = FontWeight.SemiBold
                                )
                                Spacer(modifier = Modifier.height(12.dp))

                                Text(
                                    text = dailyInsight.body,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                    lineHeight = 22.sp
                                )

                                Spacer(modifier = Modifier.height(16.dp))

                                // Affirmation
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(12.dp))
                                        .background(ResonanceColors.GoldPrimary.copy(alpha = 0.08f))
                                        .padding(14.dp)
                                ) {
                                    Text(
                                        text = "\u201C${dailyInsight.affirmation}\u201D",
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = ResonanceColors.GoldPrimary,
                                        fontStyle = FontStyle.Italic,
                                        textAlign = TextAlign.Center,
                                        modifier = Modifier.fillMaxWidth()
                                    )
                                }

                                Spacer(modifier = Modifier.height(16.dp))

                                // Journal prompt button
                                Button(
                                    onClick = {
                                        activeEntry = JournalEntry(
                                            prompt = prompts.random()
                                        )
                                        showJournalEditor = true
                                    },
                                    colors = ButtonDefaults.buttonColors(
                                        containerColor = ResonanceColors.GoldPrimary,
                                        contentColor = ResonanceColors.ForestDarkest
                                    ),
                                    shape = RoundedCornerShape(14.dp),
                                    modifier = Modifier.fillMaxWidth()
                                ) {
                                    Text(
                                        "Begin Today's Journal",
                                        fontWeight = FontWeight.SemiBold,
                                        modifier = Modifier.padding(vertical = 4.dp)
                                    )
                                }
                            }
                        }
                    }

                    // Prompt gallery
                    item {
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Reflection Prompts",
                            style = MaterialTheme.typography.titleSmall,
                            color = ResonanceColors.GoldPrimary,
                            fontWeight = FontWeight.SemiBold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                    }

                    items(prompts.take(4)) { prompt ->
                        GlassCard(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    activeEntry = JournalEntry(prompt = prompt)
                                    showJournalEditor = true
                                },
                            cornerRadius = 14.dp
                        ) {
                            Row(
                                modifier = Modifier.padding(14.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Box(
                                    modifier = Modifier
                                        .size(36.dp)
                                        .clip(CircleShape)
                                        .background(ResonanceColors.GoldPrimary.copy(alpha = 0.1f)),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = "\u270D",
                                        fontSize = 16.sp
                                    )
                                }
                                Spacer(modifier = Modifier.width(12.dp))
                                Text(
                                    text = prompt,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    lineHeight = 18.sp,
                                    modifier = Modifier.weight(1f)
                                )
                            }
                        }
                    }

                    // Past entries
                    if (journalEntries.any { it.content.isNotBlank() }) {
                        item {
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Past Entries",
                                style = MaterialTheme.typography.titleSmall,
                                color = ResonanceColors.GoldPrimary,
                                fontWeight = FontWeight.SemiBold
                            )
                        }

                        items(journalEntries.filter { it.content.isNotBlank() }) { entry ->
                            GlassCard(
                                modifier = Modifier.fillMaxWidth(),
                                cornerRadius = 14.dp
                            ) {
                                Column(modifier = Modifier.padding(14.dp)) {
                                    Text(
                                        text = entry.date.format(
                                            DateTimeFormatter.ofPattern("MMM d, yyyy \u2022 h:mm a")
                                        ),
                                        style = MaterialTheme.typography.labelSmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                    if (entry.mood.isNotBlank()) {
                                        Text(
                                            text = "Mood: ${entry.mood}",
                                            style = MaterialTheme.typography.labelSmall,
                                            color = ResonanceColors.GoldPrimary
                                        )
                                    }
                                    Spacer(modifier = Modifier.height(6.dp))
                                    Text(
                                        text = entry.prompt,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = ResonanceColors.GoldPrimary,
                                        fontStyle = FontStyle.Italic
                                    )
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(
                                        text = entry.content,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurface,
                                        maxLines = 4,
                                        lineHeight = 18.sp
                                    )
                                }
                            }
                        }
                    }

                    item { Spacer(modifier = Modifier.height(24.dp)) }
                }
            }
        }
    }
}

@Composable
private fun JournalEditor(
    entry: JournalEntry,
    onSave: (JournalEntry) -> Unit,
    onCancel: () -> Unit
) {
    var content by remember { mutableStateOf(entry.content) }
    var selectedMood by remember { mutableStateOf("") }

    val moods = listOf(
        "\uD83C\uDF1F" to "Luminous",
        "\u2728" to "Inspired",
        "\uD83C\uDF3F" to "Grounded",
        "\uD83C\uDF0A" to "Flowing",
        "\uD83D\uDD25" to "Fiery",
        "\uD83C\uDF19" to "Reflective",
        "\u2601\uFE0F" to "Clouded",
        "\uD83C\uDF31" to "Growing"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 20.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Spacer(modifier = Modifier.height(8.dp))

        // Prompt
        GlassCard(
            modifier = Modifier.fillMaxWidth(),
            cornerRadius = 16.dp
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Prompt",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceColors.GoldPrimary
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = entry.prompt,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    fontStyle = FontStyle.Italic,
                    lineHeight = 22.sp
                )
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Mood selector
        Text(
            text = "How do you feel?",
            style = MaterialTheme.typography.labelLarge,
            color = ResonanceColors.GoldPrimary
        )
        Spacer(modifier = Modifier.height(8.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            moods.forEach { (emoji, label) ->
                val isSelected = selectedMood == label
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(10.dp))
                        .background(
                            if (isSelected) ResonanceColors.GoldPrimary.copy(alpha = 0.2f)
                            else Color.Transparent
                        )
                        .border(
                            width = 1.dp,
                            color = if (isSelected) ResonanceColors.GoldPrimary
                            else ResonanceColors.GoldPrimary.copy(alpha = 0.15f),
                            shape = RoundedCornerShape(10.dp)
                        )
                        .clickable { selectedMood = label }
                        .padding(horizontal = 8.dp, vertical = 6.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(text = emoji, fontSize = 18.sp)
                }
            }
        }

        if (selectedMood.isNotBlank()) {
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = selectedMood,
                style = MaterialTheme.typography.labelSmall,
                color = ResonanceColors.GoldPrimary,
                modifier = Modifier.padding(start = 4.dp)
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Journal text input
        OutlinedTextField(
            value = content,
            onValueChange = { content = it },
            label = { Text("Write your reflection...") },
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 200.dp),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ResonanceColors.GoldPrimary,
                unfocusedBorderColor = ResonanceColors.GoldPrimary.copy(alpha = 0.3f),
                cursorColor = ResonanceColors.GoldPrimary,
                focusedLabelColor = ResonanceColors.GoldPrimary
            ),
            maxLines = 12
        )

        Spacer(modifier = Modifier.height(20.dp))

        // Action buttons
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            OutlinedButton(
                onClick = onCancel,
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = MaterialTheme.colorScheme.onSurfaceVariant
                )
            ) {
                Text("Cancel")
            }
            Button(
                onClick = {
                    onSave(
                        entry.copy(
                            content = content,
                            mood = selectedMood,
                            date = LocalDateTime.now()
                        )
                    )
                },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = ResonanceColors.GoldPrimary,
                    contentColor = ResonanceColors.ForestDarkest
                ),
                enabled = content.isNotBlank()
            ) {
                Text("Save", fontWeight = FontWeight.SemiBold)
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}
