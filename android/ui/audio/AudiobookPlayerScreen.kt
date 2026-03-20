package com.luminous.resonance.ui.audio

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.luminous.resonance.ui.theme.*
import kotlinx.coroutines.launch

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

data class AudiobookState(
    val title: String = "",
    val author: String = "",
    val coverUrl: String = "",
    val isPlaying: Boolean = false,
    val currentPositionMs: Long = 0L,
    val durationMs: Long = 0L,
    val currentChapterIndex: Int = 0,
    val chapters: List<AudioChapter> = emptyList(),
    val playbackSpeed: Float = 1.0f,
    val sleepTimerMinutes: Int? = null,
    val isFollowAlongMode: Boolean = false,
    val followAlongText: String = "",
)

data class AudioChapter(
    val id: String,
    val title: String,
    val startMs: Long,
    val durationMs: Long,
)

// ---------------------------------------------------------------------------
// Now Playing Screen
// ---------------------------------------------------------------------------

/**
 * Full audiobook player with organic blob background animation,
 * playback controls, chapter navigation, sleep timer, and
 * text-sync follow-along mode.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AudiobookPlayerScreen(
    state: AudiobookState,
    onPlayPause: () -> Unit,
    onSkipForward: () -> Unit,
    onSkipBackward: () -> Unit,
    onSeek: (Long) -> Unit,
    onSpeedChange: (Float) -> Unit,
    onChapterSelected: (Int) -> Unit,
    onSleepTimerSet: (Int?) -> Unit,
    onToggleFollowAlong: () -> Unit,
    onNavigateBack: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var showChapterList by rememberSaveable { mutableStateOf(false) }
    var showSleepTimer by rememberSaveable { mutableStateOf(false) }
    var showSpeedSelector by rememberSaveable { mutableStateOf(false) }

    Box(modifier = modifier.fillMaxSize()) {
        // Animated organic blob background
        OrganicBlobBackground(
            blobCount = 5,
            baseColor = if (state.isPlaying) {
                ResonanceColors.Green600.copy(alpha = 0.15f)
            } else {
                ResonanceColors.Green700.copy(alpha = 0.08f)
            },
            accentColor = ResonanceColors.GoldPrimary.copy(alpha = 0.10f),
            breathDuration = if (state.isPlaying) 6_000 else 10_000,
        )

        // Gradient overlay
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            MaterialTheme.colorScheme.background.copy(alpha = 0.3f),
                            MaterialTheme.colorScheme.background.copy(alpha = 0.85f),
                        ),
                    ),
                ),
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding(),
        ) {
            // Top bar
            NowPlayingTopBar(
                onNavigateBack = onNavigateBack,
                onShowChapters = { showChapterList = true },
                onToggleFollowAlong = onToggleFollowAlong,
                isFollowAlongMode = state.isFollowAlongMode,
            )

            // Content
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center,
            ) {
                // Album art / title area
                NowPlayingInfo(
                    title = state.title,
                    author = state.author,
                    chapterTitle = state.chapters.getOrNull(state.currentChapterIndex)?.title
                        ?: "",
                    isPlaying = state.isPlaying,
                )

                Spacer(Modifier.height(32.dp))

                // Follow-along text
                AnimatedVisibility(
                    visible = state.isFollowAlongMode && state.followAlongText.isNotEmpty(),
                    enter = fadeIn() + expandVertically(),
                    exit = fadeOut() + shrinkVertically(),
                ) {
                    FollowAlongText(text = state.followAlongText)
                }

                Spacer(Modifier.height(24.dp))

                // Seek bar
                SeekBar(
                    currentPositionMs = state.currentPositionMs,
                    durationMs = state.durationMs,
                    onSeek = onSeek,
                )

                Spacer(Modifier.height(24.dp))

                // Playback controls
                PlaybackControls(
                    isPlaying = state.isPlaying,
                    playbackSpeed = state.playbackSpeed,
                    onPlayPause = onPlayPause,
                    onSkipForward = onSkipForward,
                    onSkipBackward = onSkipBackward,
                    onSpeedClick = { showSpeedSelector = true },
                    onSleepTimerClick = { showSleepTimer = true },
                    sleepTimerActive = state.sleepTimerMinutes != null,
                )
            }
        }
    }

    // Chapter list bottom sheet
    if (showChapterList) {
        ChapterListSheet(
            chapters = state.chapters,
            currentIndex = state.currentChapterIndex,
            onChapterSelected = { index ->
                onChapterSelected(index)
                showChapterList = false
            },
            onDismiss = { showChapterList = false },
        )
    }

    // Sleep timer dialog
    if (showSleepTimer) {
        SleepTimerDialog(
            currentMinutes = state.sleepTimerMinutes,
            onTimerSet = {
                onSleepTimerSet(it)
                showSleepTimer = false
            },
            onDismiss = { showSleepTimer = false },
        )
    }

    // Speed selector dialog
    if (showSpeedSelector) {
        SpeedSelectorDialog(
            currentSpeed = state.playbackSpeed,
            onSpeedSelected = {
                onSpeedChange(it)
                showSpeedSelector = false
            },
            onDismiss = { showSpeedSelector = false },
        )
    }
}

// ---------------------------------------------------------------------------
// Top Bar
// ---------------------------------------------------------------------------

@Composable
private fun NowPlayingTopBar(
    onNavigateBack: () -> Unit,
    onShowChapters: () -> Unit,
    onToggleFollowAlong: () -> Unit,
    isFollowAlongMode: Boolean,
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 8.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically,
    ) {
        IconButton(
            onClick = onNavigateBack,
            modifier = Modifier.semantics { contentDescription = "Close player" },
        ) {
            Icon(
                Icons.Default.KeyboardArrowDown,
                contentDescription = null,
                modifier = Modifier.size(28.dp),
            )
        }

        Text(
            text = "Now Playing",
            style = MaterialTheme.typography.titleSmall,
        )

        Row {
            IconButton(
                onClick = onToggleFollowAlong,
                modifier = Modifier.semantics {
                    contentDescription = "Toggle follow-along text"
                },
            ) {
                Icon(
                    Icons.Default.TextFields,
                    contentDescription = null,
                    tint = if (isFollowAlongMode) {
                        ResonanceTheme.extendedColors.gold
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    },
                )
            }
            IconButton(
                onClick = onShowChapters,
                modifier = Modifier.semantics { contentDescription = "Show chapters" },
            ) {
                Icon(Icons.Default.PlaylistPlay, contentDescription = null)
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Now Playing Info
// ---------------------------------------------------------------------------

@Composable
private fun NowPlayingInfo(
    title: String,
    author: String,
    chapterTitle: String,
    isPlaying: Boolean,
) {
    val breathScale by rememberBreathingAnimation(
        min = 0.95f,
        max = 1.05f,
        durationMs = 4_000,
    )

    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        // Organic animated circle representing the audiobook
        Box(
            modifier = Modifier
                .size(200.dp)
                .graphicsLayer {
                    scaleX = if (isPlaying) breathScale else 1f
                    scaleY = if (isPlaying) breathScale else 1f
                }
                .clip(CircleShape)
                .background(
                    Brush.radialGradient(
                        colors = listOf(
                            ResonanceColors.Green600.copy(alpha = 0.3f),
                            ResonanceColors.Green700.copy(alpha = 0.15f),
                            ResonanceColors.GoldPrimary.copy(alpha = 0.08f),
                        ),
                    ),
                    CircleShape,
                )
                .semantics { contentDescription = "Audiobook cover art" },
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                Icons.Default.Headphones,
                contentDescription = null,
                modifier = Modifier.size(64.dp),
                tint = ResonanceTheme.extendedColors.gold.copy(alpha = 0.7f),
            )
        }

        Spacer(Modifier.height(24.dp))

        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
        )
        Spacer(Modifier.height(4.dp))
        Text(
            text = author,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
        if (chapterTitle.isNotEmpty()) {
            Spacer(Modifier.height(4.dp))
            Text(
                text = chapterTitle,
                style = MaterialTheme.typography.labelMedium,
                color = ResonanceTheme.extendedColors.gold,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Follow-Along Text
// ---------------------------------------------------------------------------

@Composable
private fun FollowAlongText(text: String) {
    GlassSurface(
        modifier = Modifier
            .fillMaxWidth()
            .heightIn(min = 80.dp, max = 160.dp),
        shape = ResonanceShapes.medium,
    ) {
        Text(
            text = text,
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.padding(16.dp),
        )
    }
}

// ---------------------------------------------------------------------------
// Seek Bar
// ---------------------------------------------------------------------------

@Composable
private fun SeekBar(
    currentPositionMs: Long,
    durationMs: Long,
    onSeek: (Long) -> Unit,
) {
    val progress = if (durationMs > 0) currentPositionMs.toFloat() / durationMs else 0f

    Column(modifier = Modifier.fillMaxWidth()) {
        Slider(
            value = progress,
            onValueChange = { onSeek((it * durationMs).toLong()) },
            modifier = Modifier
                .fillMaxWidth()
                .semantics {
                    contentDescription =
                        "Playback position: ${formatDuration(currentPositionMs)} of ${formatDuration(durationMs)}"
                },
            colors = SliderDefaults.colors(
                thumbColor = ResonanceTheme.extendedColors.gold,
                activeTrackColor = ResonanceTheme.extendedColors.gold,
                inactiveTrackColor = MaterialTheme.colorScheme.surfaceVariant,
            ),
        )
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = formatDuration(currentPositionMs),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = formatDuration(durationMs),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Playback Controls
// ---------------------------------------------------------------------------

@Composable
private fun PlaybackControls(
    isPlaying: Boolean,
    playbackSpeed: Float,
    onPlayPause: () -> Unit,
    onSkipForward: () -> Unit,
    onSkipBackward: () -> Unit,
    onSpeedClick: () -> Unit,
    onSleepTimerClick: () -> Unit,
    sleepTimerActive: Boolean,
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        // Main transport controls
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            // Speed button
            TextButton(
                onClick = onSpeedClick,
                modifier = Modifier.semantics {
                    contentDescription = "Playback speed: ${playbackSpeed}x"
                },
            ) {
                Text(
                    text = "${playbackSpeed}x",
                    style = MaterialTheme.typography.labelLarge,
                )
            }

            // Skip backward 15s
            IconButton(
                onClick = onSkipBackward,
                modifier = Modifier
                    .size(48.dp)
                    .semantics { contentDescription = "Skip backward 15 seconds" },
            ) {
                Icon(
                    Icons.Default.Replay10,
                    contentDescription = null,
                    modifier = Modifier.size(32.dp),
                )
            }

            // Play/Pause
            FilledIconButton(
                onClick = onPlayPause,
                modifier = Modifier
                    .size(72.dp)
                    .semantics {
                        contentDescription = if (isPlaying) "Pause" else "Play"
                        role = Role.Button
                    },
                colors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = ResonanceTheme.extendedColors.gold,
                    contentColor = ResonanceColors.Green900,
                ),
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = null,
                    modifier = Modifier.size(36.dp),
                )
            }

            // Skip forward 30s
            IconButton(
                onClick = onSkipForward,
                modifier = Modifier
                    .size(48.dp)
                    .semantics { contentDescription = "Skip forward 30 seconds" },
            ) {
                Icon(
                    Icons.Default.Forward30,
                    contentDescription = null,
                    modifier = Modifier.size(32.dp),
                )
            }

            // Sleep timer
            IconButton(
                onClick = onSleepTimerClick,
                modifier = Modifier.semantics {
                    contentDescription =
                        if (sleepTimerActive) "Sleep timer active" else "Set sleep timer"
                },
            ) {
                Icon(
                    Icons.Default.Bedtime,
                    contentDescription = null,
                    tint = if (sleepTimerActive) {
                        ResonanceTheme.extendedColors.gold
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    },
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Chapter List Bottom Sheet
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ChapterListSheet(
    chapters: List<AudioChapter>,
    currentIndex: Int,
    onChapterSelected: (Int) -> Unit,
    onDismiss: () -> Unit,
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
    ) {
        Column(modifier = Modifier.padding(bottom = 24.dp)) {
            Text(
                text = "Chapters",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.padding(horizontal = 24.dp, vertical = 8.dp),
            )
            HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))

            LazyColumn(
                modifier = Modifier.heightIn(max = 400.dp),
            ) {
                itemsIndexed(chapters) { index, chapter ->
                    val isActive = index == currentIndex
                    ListItem(
                        headlineContent = {
                            Text(
                                text = chapter.title,
                                style = MaterialTheme.typography.bodyMedium,
                                color = if (isActive) {
                                    ResonanceTheme.extendedColors.gold
                                } else {
                                    MaterialTheme.colorScheme.onSurface
                                },
                            )
                        },
                        trailingContent = {
                            Text(
                                text = formatDuration(chapter.durationMs),
                                style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        },
                        leadingContent = {
                            if (isActive) {
                                Icon(
                                    Icons.Default.GraphicEq,
                                    contentDescription = "Currently playing",
                                    tint = ResonanceTheme.extendedColors.gold,
                                    modifier = Modifier.size(20.dp),
                                )
                            } else {
                                Text(
                                    text = "${index + 1}",
                                    style = MaterialTheme.typography.labelMedium,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                        },
                        modifier = Modifier.clickable { onChapterSelected(index) },
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Sleep Timer Dialog
// ---------------------------------------------------------------------------

@Composable
private fun SleepTimerDialog(
    currentMinutes: Int?,
    onTimerSet: (Int?) -> Unit,
    onDismiss: () -> Unit,
) {
    val options = listOf(
        null to "Off",
        15 to "15 minutes",
        30 to "30 minutes",
        45 to "45 minutes",
        60 to "1 hour",
        90 to "1.5 hours",
        120 to "2 hours",
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sleep Timer") },
        text = {
            Column {
                options.forEach { (minutes, label) ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onTimerSet(minutes) }
                            .padding(vertical = 12.dp, horizontal = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        RadioButton(
                            selected = currentMinutes == minutes,
                            onClick = { onTimerSet(minutes) },
                            colors = RadioButtonDefaults.colors(
                                selectedColor = ResonanceTheme.extendedColors.gold,
                            ),
                        )
                        Spacer(Modifier.width(12.dp))
                        Text(
                            text = label,
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) { Text("Done") }
        },
    )
}

// ---------------------------------------------------------------------------
// Speed Selector Dialog
// ---------------------------------------------------------------------------

@Composable
private fun SpeedSelectorDialog(
    currentSpeed: Float,
    onSpeedSelected: (Float) -> Unit,
    onDismiss: () -> Unit,
) {
    val speeds = listOf(0.5f, 0.75f, 1.0f, 1.25f, 1.5f, 1.75f, 2.0f, 2.5f, 3.0f)

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Playback Speed") },
        text = {
            Column {
                speeds.forEach { speed ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onSpeedSelected(speed) }
                            .padding(vertical = 10.dp, horizontal = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        RadioButton(
                            selected = currentSpeed == speed,
                            onClick = { onSpeedSelected(speed) },
                            colors = RadioButtonDefaults.colors(
                                selectedColor = ResonanceTheme.extendedColors.gold,
                            ),
                        )
                        Spacer(Modifier.width(12.dp))
                        Text(
                            text = "${speed}x",
                            style = MaterialTheme.typography.bodyMedium,
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) { Text("Done") }
        },
    )
}

// ---------------------------------------------------------------------------
// Collapsible Mini Player
// ---------------------------------------------------------------------------

/**
 * A compact mini player bar intended for display at the bottom of other
 * screens while audio is playing in the background. Tapping expands to
 * the full AudiobookPlayerScreen.
 *
 * Integration note: The actual media session and notification controls
 * should be implemented via [androidx.media3.session.MediaSession] and
 * [androidx.media3.session.MediaSessionService] for system-level
 * notification media controls and lock-screen integration.
 */
@Composable
fun CollapsibleMiniPlayer(
    state: AudiobookState,
    onPlayPause: () -> Unit,
    onExpand: () -> Unit,
    modifier: Modifier = Modifier,
) {
    AnimatedVisibility(
        visible = state.title.isNotEmpty(),
        enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
        modifier = modifier,
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .clickable(
                    onClickLabel = "Open full player",
                    onClick = onExpand,
                ),
            color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.95f),
            tonalElevation = 4.dp,
            shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Mini cover indicator
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(
                            ResonanceColors.Green600.copy(alpha = 0.2f),
                            CircleShape,
                        ),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        Icons.Default.Headphones,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
                        tint = ResonanceTheme.extendedColors.gold,
                    )
                }
                Spacer(Modifier.width(12.dp))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = state.title,
                        style = MaterialTheme.typography.titleSmall,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                    Text(
                        text = state.chapters.getOrNull(state.currentChapterIndex)?.title ?: "",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }

                // Progress ring + play/pause
                IconButton(
                    onClick = onPlayPause,
                    modifier = Modifier.semantics {
                        contentDescription = if (state.isPlaying) "Pause" else "Play"
                    },
                ) {
                    Icon(
                        imageVector = if (state.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                        contentDescription = null,
                        tint = ResonanceTheme.extendedColors.gold,
                    )
                }
            }

            // Mini progress indicator
            val progress = if (state.durationMs > 0) {
                state.currentPositionMs.toFloat() / state.durationMs
            } else 0f

            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(2.dp)
                    .align(Alignment.BottomStart),
                color = ResonanceTheme.extendedColors.gold,
                trackColor = MaterialTheme.colorScheme.surfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Utilities
// ---------------------------------------------------------------------------

private fun formatDuration(ms: Long): String {
    val totalSeconds = ms / 1000
    val hours = totalSeconds / 3600
    val minutes = (totalSeconds % 3600) / 60
    val seconds = totalSeconds % 60
    return if (hours > 0) {
        "%d:%02d:%02d".format(hours, minutes, seconds)
    } else {
        "%d:%02d".format(minutes, seconds)
    }
}
