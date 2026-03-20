package com.luminous.cosmic.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ArrowBack
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.components.CosmicBackground
import com.luminous.cosmic.ui.theme.*

@Composable
fun ChapterLibraryScreen(
    isDarkTheme: Boolean,
    onBack: () -> Unit
) {
    val chapters = remember { ChartCalculator.getSampleChapters() }
    var selectedChapter by remember { mutableStateOf<Chapter?>(null) }

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
                IconButton(onClick = {
                    if (selectedChapter != null) {
                        selectedChapter = null
                    } else {
                        onBack()
                    }
                }) {
                    Icon(
                        Icons.Outlined.ArrowBack,
                        contentDescription = "Back",
                        tint = ResonanceColors.GoldPrimary
                    )
                }
                Text(
                    text = if (selectedChapter != null) "Chapter ${selectedChapter!!.number}"
                    else "Chapter Library",
                    style = MaterialTheme.typography.titleLarge,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.Light,
                    modifier = Modifier.weight(1f)
                )
            }

            AnimatedContent(
                targetState = selectedChapter,
                transitionSpec = {
                    slideInHorizontally { it } + fadeIn() togetherWith
                        slideOutHorizontally { -it } + fadeOut()
                },
                label = "chapter_content"
            ) { chapter ->
                if (chapter != null) {
                    ChapterReader(chapter = chapter)
                } else {
                    ChapterList(
                        chapters = chapters,
                        onChapterSelect = { selectedChapter = it }
                    )
                }
            }
        }
    }
}

@Composable
private fun ChapterList(
    chapters: List<Chapter>,
    onChapterSelect: (Chapter) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        item {
            // Library header
            GlassCard(
                modifier = Modifier.fillMaxWidth(),
                cornerRadius = 24.dp
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = "Luminous Cosmic\nArchitecture",
                        style = MaterialTheme.typography.headlineMedium,
                        color = ResonanceColors.GoldPrimary,
                        fontWeight = FontWeight.Light,
                        textAlign = TextAlign.Center,
                        lineHeight = 36.sp
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "A Developmental Map of the Stars",
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        fontStyle = FontStyle.Italic
                    )
                    Spacer(modifier = Modifier.height(16.dp))

                    // Gold divider
                    Box(
                        modifier = Modifier
                            .width(60.dp)
                            .height(2.dp)
                            .background(
                                brush = Brush.horizontalGradient(
                                    colors = listOf(
                                        ResonanceColors.GoldDark.copy(alpha = 0.3f),
                                        ResonanceColors.GoldPrimary,
                                        ResonanceColors.GoldDark.copy(alpha = 0.3f)
                                    )
                                )
                            )
                    )

                    Spacer(modifier = Modifier.height(16.dp))

                    Text(
                        text = "${chapters.size} chapters available",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        }

        itemsIndexed(chapters) { index, chapter ->
            ChapterCard(
                chapter = chapter,
                index = index,
                onClick = { if (chapter.isUnlocked) onChapterSelect(chapter) }
            )
        }

        item { Spacer(modifier = Modifier.height(24.dp)) }
    }
}

@Composable
private fun ChapterCard(
    chapter: Chapter,
    index: Int,
    onClick: () -> Unit
) {
    val entryAnimation = remember { Animatable(0f) }
    LaunchedEffect(Unit) {
        entryAnimation.animateTo(
            1f,
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioMediumBouncy,
                stiffness = Spring.StiffnessLow
            )
        )
    }

    GlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(enabled = chapter.isUnlocked, onClick = onClick),
        cornerRadius = 18.dp
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(18.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Chapter number
            Box(
                modifier = Modifier
                    .size(44.dp)
                    .clip(CircleShape)
                    .background(
                        if (chapter.isUnlocked)
                            ResonanceColors.GoldPrimary.copy(alpha = 0.15f)
                        else
                            ResonanceColors.TextSage.copy(alpha = 0.1f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                if (chapter.isUnlocked) {
                    Text(
                        text = "${chapter.number}",
                        style = MaterialTheme.typography.titleMedium,
                        color = ResonanceColors.GoldPrimary,
                        fontWeight = FontWeight.Bold
                    )
                } else {
                    Icon(
                        Icons.Outlined.Lock,
                        contentDescription = "Locked",
                        tint = ResonanceColors.TextSage,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = chapter.title,
                    style = MaterialTheme.typography.titleSmall,
                    color = if (chapter.isUnlocked)
                        MaterialTheme.colorScheme.onSurface
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant,
                    fontWeight = FontWeight.SemiBold
                )
                Text(
                    text = chapter.subtitle,
                    style = MaterialTheme.typography.bodySmall,
                    color = if (chapter.isUnlocked)
                        ResonanceColors.GoldPrimary
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                    fontStyle = FontStyle.Italic
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = chapter.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    lineHeight = 18.sp
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "${chapter.sections.size} sections",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f)
                )
            }
        }
    }
}

@Composable
private fun ChapterReader(chapter: Chapter) {
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Chapter header
        item {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Chapter ${chapter.number}",
                    style = MaterialTheme.typography.labelLarge,
                    color = ResonanceColors.GoldPrimary,
                    letterSpacing = 3.sp
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = chapter.title,
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.Light,
                    textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = chapter.subtitle,
                    style = MaterialTheme.typography.titleSmall,
                    color = ResonanceColors.GoldPrimary,
                    fontStyle = FontStyle.Italic
                )

                Spacer(modifier = Modifier.height(16.dp))

                Box(
                    modifier = Modifier
                        .width(40.dp)
                        .height(1.5.dp)
                        .background(
                            brush = Brush.horizontalGradient(
                                colors = listOf(
                                    ResonanceColors.GoldDark.copy(alpha = 0.2f),
                                    ResonanceColors.GoldPrimary,
                                    ResonanceColors.GoldDark.copy(alpha = 0.2f)
                                )
                            )
                        )
                )
            }
        }

        // Sections
        items(chapter.sections) { section ->
            SectionContent(section = section)
        }

        item { Spacer(modifier = Modifier.height(32.dp)) }
    }
}

@Composable
private fun SectionContent(section: ChapterSection) {
    Column(modifier = Modifier.fillMaxWidth()) {
        // Section header
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(bottom = 10.dp)
        ) {
            if (section.relatedSign != null) {
                val elementColor = when (section.relatedSign.element) {
                    Element.FIRE -> ResonanceColors.FireElement
                    Element.EARTH -> ResonanceColors.EarthElement
                    Element.AIR -> ResonanceColors.AirElement
                    Element.WATER -> ResonanceColors.WaterElement
                }
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(elementColor.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = section.relatedSign.unicode,
                        fontSize = 14.sp,
                        color = elementColor
                    )
                }
                Spacer(modifier = Modifier.width(10.dp))
            }

            Text(
                text = section.title,
                style = MaterialTheme.typography.titleMedium,
                color = ResonanceColors.GoldPrimary,
                fontWeight = FontWeight.SemiBold
            )
        }

        // Section body
        Text(
            text = section.content,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface,
            lineHeight = 24.sp
        )
    }
}
