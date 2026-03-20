package com.resonance.luminous.widgets

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.*
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.*
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.*
import androidx.glance.text.*
import androidx.glance.unit.ColorProvider

// ---------------------------------------------------------------------------
// Resonance Glance colour tokens
// ---------------------------------------------------------------------------

private object GlanceColors {
    val green900     = Color(0xFF0A1C14)
    val green800     = Color(0xFF122E21)
    val green700     = Color(0xFF1B402E)
    val green200     = Color(0xFFD1E0D7)
    val goldPrimary  = Color(0xFFC5A059)
    val goldLight    = Color(0xFFE6D0A1)
    val goldDark     = Color(0xFF9A7A3A)
    val bgLight      = Color(0xFFFAFAF8)
    val bgDark       = Color(0xFF05100B)
    val textLight    = Color(0xFF1A1A18)
    val textDark     = Color(0xFFF0EDE6)
    val textMuted    = Color(0xFF8A8A86)
    val glassDark    = Color(0x1AFFFFFF) // 10% white
    val glassLight   = Color(0xA6FFFFFF) // 65% white
}

// ---------------------------------------------------------------------------
// 1. Daily Insight Widget
// ---------------------------------------------------------------------------

class DailyInsightWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            DailyInsightContent()
        }
    }
}

@Composable
private fun DailyInsightContent() {
    val quote = "The wound is the place where the Light enters you."
    val author = "Rumi"
    val chapter = "Chapter 4"

    GlanceTheme {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(24.dp)
                .background(GlanceColors.green900)
                .padding(16.dp),
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
            ) {
                // Header row
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.Start,
                ) {
                    Text(
                        text = "Daily Insight",
                        style = TextStyle(
                            color = ColorProvider(GlanceColors.goldPrimary),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Medium,
                        ),
                    )
                }

                Spacer(modifier = GlanceModifier.height(4.dp))

                // Gold accent
                Box(
                    modifier = GlanceModifier
                        .width(24.dp)
                        .height(2.dp)
                        .background(GlanceColors.goldPrimary)
                        .cornerRadius(1.dp),
                ) {}

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Quote
                Text(
                    text = "\u201C$quote\u201D",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.textDark),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Normal,
                        fontStyle = FontStyle.Italic,
                    ),
                    maxLines = 4,
                )

                Spacer(modifier = GlanceModifier.height(8.dp))

                // Author
                Text(
                    text = "\u2014 $author",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.goldPrimary),
                        fontSize = 12.sp,
                    ),
                )

                Spacer(modifier = GlanceModifier.defaultWeight())

                // Footer
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    Text(
                        text = "$chapter \u2022 Luminous Attachment",
                        style = TextStyle(
                            color = ColorProvider(GlanceColors.textMuted),
                            fontSize = 10.sp,
                        ),
                    )
                }
            }
        }
    }
}

class DailyInsightWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = DailyInsightWidget()
}

// ---------------------------------------------------------------------------
// 2. Mood Check-in Widget
// ---------------------------------------------------------------------------

class MoodWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            MoodWidgetContent()
        }
    }
}

@Composable
private fun MoodWidgetContent() {
    val moods = listOf(
        "\uD83D\uDE14" to "Low",
        "\uD83D\uDE10" to "Flat",
        "\uD83D\uDE42" to "Calm",
        "\uD83D\uDE0A" to "Good",
        "\u2728" to "Radiant",
    )

    GlanceTheme {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(24.dp)
                .background(GlanceColors.green900)
                .padding(16.dp),
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
            ) {
                Text(
                    text = "How are you feeling?",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.textDark),
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )

                Spacer(modifier = GlanceModifier.height(4.dp))

                Text(
                    text = "Tap to check in",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.goldPrimary),
                        fontSize = 11.sp,
                    ),
                )

                Spacer(modifier = GlanceModifier.height(12.dp))

                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    moods.forEach { (emoji, label) ->
                        Column(
                            modifier = GlanceModifier
                                .padding(horizontal = 6.dp)
                                .clickable(actionStartActivity<MoodWidgetActionActivity>()),
                            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                        ) {
                            Text(
                                text = emoji,
                                style = TextStyle(fontSize = 24.sp),
                            )
                            Spacer(modifier = GlanceModifier.height(2.dp))
                            Text(
                                text = label,
                                style = TextStyle(
                                    color = ColorProvider(GlanceColors.textMuted),
                                    fontSize = 9.sp,
                                ),
                            )
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    Text(
                        text = "Luminous Attachment",
                        style = TextStyle(
                            color = ColorProvider(GlanceColors.textMuted),
                            fontSize = 10.sp,
                        ),
                    )
                }
            }
        }
    }
}

// Placeholder activity to handle mood widget taps
class MoodWidgetActionActivity : android.app.Activity()

class MoodWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MoodWidget()
}

// ---------------------------------------------------------------------------
// 3. Breathing Widget
// ---------------------------------------------------------------------------

class BreathingWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            BreathingWidgetContent()
        }
    }
}

@Composable
private fun BreathingWidgetContent() {
    GlanceTheme {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(24.dp)
                .background(GlanceColors.green800)
                .padding(16.dp)
                .clickable(actionStartActivity<BreathingWidgetActionActivity>()),
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.CenterVertically,
                horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
            ) {
                Text(
                    text = "Breathing Space",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.goldPrimary),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )

                Spacer(modifier = GlanceModifier.height(16.dp))

                // Static circle representation
                Box(
                    modifier = GlanceModifier
                        .size(64.dp)
                        .cornerRadius(32.dp)
                        .background(GlanceColors.goldDark),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = "\u25B6",
                        style = TextStyle(
                            color = ColorProvider(Color.White),
                            fontSize = 20.sp,
                        ),
                    )
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                Text(
                    text = "Tap to breathe",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.textDark),
                        fontSize = 13.sp,
                    ),
                )

                Spacer(modifier = GlanceModifier.height(4.dp))

                Text(
                    text = "4-4-6 pattern \u2022 1 minute",
                    style = TextStyle(
                        color = ColorProvider(GlanceColors.textMuted),
                        fontSize = 10.sp,
                    ),
                )
            }
        }
    }
}

class BreathingWidgetActionActivity : android.app.Activity()

class BreathingWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = BreathingWidget()
}

// ---------------------------------------------------------------------------
// 4. Streak Widget
// ---------------------------------------------------------------------------

class StreakWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            StreakWidgetContent()
        }
    }
}

@Composable
private fun StreakWidgetContent() {
    // In production these values come from SharedPreferences / DataStore
    val streakDays = 12
    val chaptersRead = 4
    val totalChapters = 12
    val journalEntries = 23
    val coachSessions = 8

    // Last 7 days check-in status
    val weekDays = listOf("M", "T", "W", "T", "F", "S", "S")
    val checkedIn = listOf(true, true, true, true, true, true, false)

    GlanceTheme {
        Box(
            modifier = GlanceModifier
                .fillMaxSize()
                .cornerRadius(24.dp)
                .background(GlanceColors.green900)
                .padding(16.dp),
        ) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
            ) {
                // Header
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.Start,
                    verticalAlignment = Alignment.Vertical.CenterVertically,
                ) {
                    Text(
                        text = "\uD83D\uDD25",
                        style = TextStyle(fontSize = 20.sp),
                    )
                    Spacer(modifier = GlanceModifier.width(8.dp))
                    Column {
                        Text(
                            text = "$streakDays Day Streak",
                            style = TextStyle(
                                color = ColorProvider(GlanceColors.goldPrimary),
                                fontSize = 16.sp,
                                fontWeight = FontWeight.Bold,
                            ),
                        )
                        Text(
                            text = "Keep going!",
                            style = TextStyle(
                                color = ColorProvider(GlanceColors.textMuted),
                                fontSize = 11.sp,
                            ),
                        )
                    }
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Week tracker
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    weekDays.forEachIndexed { idx, day ->
                        Column(
                            modifier = GlanceModifier.padding(horizontal = 4.dp),
                            horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                        ) {
                            Text(
                                text = day,
                                style = TextStyle(
                                    color = ColorProvider(GlanceColors.textMuted),
                                    fontSize = 10.sp,
                                ),
                            )
                            Spacer(modifier = GlanceModifier.height(4.dp))
                            Box(
                                modifier = GlanceModifier
                                    .size(20.dp)
                                    .cornerRadius(10.dp)
                                    .background(
                                        if (checkedIn[idx]) GlanceColors.goldPrimary
                                        else GlanceColors.green700
                                    ),
                                contentAlignment = Alignment.Center,
                            ) {
                                if (checkedIn[idx]) {
                                    Text(
                                        text = "\u2713",
                                        style = TextStyle(
                                            color = ColorProvider(Color.White),
                                            fontSize = 10.sp,
                                        ),
                                    )
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = GlanceModifier.height(12.dp))

                // Stats row
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    StatItem("$chaptersRead/$totalChapters", "Chapters")
                    Spacer(modifier = GlanceModifier.width(16.dp))
                    StatItem("$journalEntries", "Entries")
                    Spacer(modifier = GlanceModifier.width(16.dp))
                    StatItem("$coachSessions", "Sessions")
                }

                Spacer(modifier = GlanceModifier.defaultWeight())

                // Footer
                Row(
                    modifier = GlanceModifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.Horizontal.CenterHorizontally,
                ) {
                    Text(
                        text = "Luminous Attachment",
                        style = TextStyle(
                            color = ColorProvider(GlanceColors.textMuted),
                            fontSize = 10.sp,
                        ),
                    )
                }
            }
        }
    }
}

@Composable
private fun StatItem(value: String, label: String) {
    Column(horizontalAlignment = Alignment.Horizontal.CenterHorizontally) {
        Text(
            text = value,
            style = TextStyle(
                color = ColorProvider(GlanceColors.textDark),
                fontSize = 14.sp,
                fontWeight = FontWeight.Bold,
            ),
        )
        Text(
            text = label,
            style = TextStyle(
                color = ColorProvider(GlanceColors.textMuted),
                fontSize = 10.sp,
            ),
        )
    }
}

class StreakWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = StreakWidget()
}
