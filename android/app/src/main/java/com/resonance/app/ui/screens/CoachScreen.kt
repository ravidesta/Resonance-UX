package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.slideInVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
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
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalTime
import java.util.UUID

// ── Design Tokens ──────────────────────────────────────────────────────────────
private val ForestGreen = Color(0xFF2D734D)
private val SageGreen = Color(0xFF7A8B69)
private val WarmGold = Color(0xFFC5A059)
private val Cream = Color(0xFFFAFAF8)
private val DeepBg = Color(0xFF0D1A12)
private val DeepCard = Color(0xFF1E3628)

// ── Data Models ────────────────────────────────────────────────────────────────

enum class CoachMessageType {
    USER, COACH, INSIGHT, BREATHWORK, SUGGESTION
}

data class CoachMessage(
    val id: String = UUID.randomUUID().toString(),
    val text: String,
    val type: CoachMessageType,
    val timestamp: LocalTime = LocalTime.now()
)

data class EnergyInsight(
    val title: String,
    val description: String,
    val trend: String, // "rising" | "steady" | "falling"
    val suggestion: String
)

// ── Phase-Aware Greetings ──────────────────────────────────────────────────────

private fun coachGreeting(): CoachMessage {
    val hour = LocalTime.now().hour
    val greeting = when {
        hour in 6..9 -> "Good morning. As your day begins, what would you like to bring your attention to?"
        hour in 10..14 -> "You're in the heart of your day. How is your energy flowing?"
        hour in 15..19 -> "The afternoon is a time of gentle transition. What would you like to release?"
        else -> "Evening is for rest and reflection. How are you settling in?"
    }
    return CoachMessage(text = greeting, type = CoachMessageType.COACH)
}

private fun coachResponses(): List<String> = listOf(
    "That's a meaningful observation. What does that tell you about what you need right now?",
    "I notice you mentioned energy. Your biomarkers have shown a pattern of afternoon dips — have you noticed that too?",
    "It sounds like you're carrying something. Would a brief breathwork pause feel helpful right now?",
    "That resonates with what you wrote in your journal two days ago. There may be a thread worth following.",
    "Sometimes the most productive thing we can do is create space. What would spaciousness look like for you today?",
    "Your HRV has been trending upward this week. Whatever you've been doing, your body seems to appreciate it.",
    "I hear you. There's no rush to resolve anything — just noticing is enough.",
    "What would feel like enough for today? Not the maximum, but the amount that leaves room to breathe."
)

private fun breathworkSuggestions(): List<CoachMessage> = listOf(
    CoachMessage(
        text = "Let's try a brief coherence breath. Inhale for 5 counts, exhale for 5 counts. Just 6 cycles — about a minute.",
        type = CoachMessageType.BREATHWORK
    ),
    CoachMessage(
        text = "A 4-7-8 pattern can help settle the nervous system. Inhale 4, hold 7, exhale 8. Three rounds is enough.",
        type = CoachMessageType.BREATHWORK
    ),
    CoachMessage(
        text = "Try box breathing: 4 counts in, 4 hold, 4 out, 4 hold. It brings a gentle structure to the present moment.",
        type = CoachMessageType.BREATHWORK
    )
)

// ── Main Coach Screen ──────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CoachScreen(
    isDeepRest: Boolean = false,
    onBack: () -> Unit = {}
) {
    val bgColor = if (isDeepRest) DeepBg else Cream
    val surfaceColor = if (isDeepRest) DeepCard else Color.White
    val textColor = if (isDeepRest) Color(0xFFC5DDD0) else Color(0xFF3A4840)

    val messages = remember { mutableStateListOf(coachGreeting()) }
    var inputText by remember { mutableStateOf("") }
    var responseIndex by remember { mutableStateOf(0) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        CoachAvatar()
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("Resonance Coach", fontWeight = FontWeight.Medium, color = textColor, fontSize = 16.sp)
                            Text("Calm mentor", fontSize = 12.sp, color = textColor.copy(alpha = 0.5f))
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back", tint = textColor)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = bgColor)
            )
        },
        containerColor = bgColor
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // Messages
            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                reverseLayout = true
            ) {
                items(messages.reversed()) { message ->
                    MessageBubble(message, surfaceColor, textColor, isDeepRest)
                }

                // Energy insight card at top
                item { EnergyInsightCard(surfaceColor, textColor, isDeepRest) }
            }

            // Quick actions
            QuickActions(
                isDeepRest = isDeepRest,
                textColor = textColor,
                onBreathwork = {
                    val suggestion = breathworkSuggestions().random()
                    messages.add(suggestion)
                },
                onInsight = {
                    messages.add(CoachMessage(
                        text = "Based on your patterns this week: your most spacious hours are between 10am and noon. " +
                               "Your journal entries during Descent phase tend to mention gratitude most often.",
                        type = CoachMessageType.INSIGHT
                    ))
                }
            )

            // Input bar
            InputBar(
                inputText = inputText,
                onInputChange = { inputText = it },
                surfaceColor = surfaceColor,
                textColor = textColor,
                isDeepRest = isDeepRest,
                onSend = {
                    if (inputText.isNotBlank()) {
                        messages.add(CoachMessage(text = inputText, type = CoachMessageType.USER))
                        inputText = ""
                        // Simulated coach response
                        val responses = coachResponses()
                        messages.add(CoachMessage(
                            text = responses[responseIndex % responses.size],
                            type = CoachMessageType.COACH
                        ))
                        responseIndex++
                    }
                }
            )
        }
    }
}

// ── Coach Avatar ───────────────────────────────────────────────────────────────

@Composable
private fun CoachAvatar() {
    val transition = rememberInfiniteTransition(label = "avatar-breathe")
    val breathe by transition.animateFloat(
        initialValue = 0.7f, targetValue = 1f,
        animationSpec = infiniteRepeatable(tween(4000, easing = FastOutSlowInEasing), RepeatMode.Reverse),
        label = "breathe"
    )

    Box(
        modifier = Modifier
            .size(36.dp)
            .clip(CircleShape)
            .background(
                Brush.radialGradient(
                    listOf(
                        ForestGreen.copy(alpha = breathe),
                        SageGreen.copy(alpha = 0.3f)
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .size(12.dp)
                .clip(CircleShape)
                .background(WarmGold.copy(alpha = breathe))
        )
    }
}

// ── Message Bubble ─────────────────────────────────────────────────────────────

@Composable
private fun MessageBubble(
    message: CoachMessage,
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean
) {
    val isUser = message.type == CoachMessageType.USER
    val alignment = if (isUser) Alignment.CenterEnd else Alignment.CenterStart

    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = alignment
    ) {
        val bubbleColor = when (message.type) {
            CoachMessageType.USER -> ForestGreen
            CoachMessageType.BREATHWORK -> if (isDeepRest) Color(0xFF1A3A2A) else Color(0xFFF0F8F4)
            CoachMessageType.INSIGHT -> if (isDeepRest) Color(0xFF2A3420) else Color(0xFFFBF5E8)
            else -> surfaceColor
        }
        val bubbleTextColor = when (message.type) {
            CoachMessageType.USER -> Color.White
            CoachMessageType.BREATHWORK -> ForestGreen
            CoachMessageType.INSIGHT -> if (isDeepRest) WarmGold else Color(0xFF7C612F)
            else -> textColor
        }

        Card(
            shape = RoundedCornerShape(
                topStart = 20.dp, topEnd = 20.dp,
                bottomStart = if (isUser) 20.dp else 4.dp,
                bottomEnd = if (isUser) 4.dp else 20.dp
            ),
            colors = CardDefaults.cardColors(containerColor = bubbleColor),
            elevation = CardDefaults.cardElevation(defaultElevation = 0.dp),
            modifier = Modifier.fillMaxWidth(0.82f)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                when (message.type) {
                    CoachMessageType.BREATHWORK -> {
                        Text("Breathwork", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = SageGreen, letterSpacing = 1.sp)
                        Spacer(Modifier.height(4.dp))
                    }
                    CoachMessageType.INSIGHT -> {
                        Text("Pattern Insight", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = WarmGold, letterSpacing = 1.sp)
                        Spacer(Modifier.height(4.dp))
                    }
                    else -> {}
                }
                Text(
                    message.text,
                    fontSize = 15.sp,
                    color = bubbleTextColor,
                    lineHeight = 22.sp,
                    fontStyle = if (message.type == CoachMessageType.COACH) FontStyle.Normal else FontStyle.Normal
                )
            }
        }
    }
}

// ── Energy Insight Card ────────────────────────────────────────────────────────

@Composable
private fun EnergyInsightCard(
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean
) {
    Card(
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(
            containerColor = if (isDeepRest) Color(0xFF1A3020) else Color(0xFFF8FBF9)
        ),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text("This Week's Energy Pattern", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = WarmGold, letterSpacing = 1.sp)
            Spacer(Modifier.height(12.dp))

            // Simple energy bar visualization
            val dayLabels = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
            val energyLevels = listOf(0.6f, 0.8f, 0.7f, 0.9f, 0.5f, 0.75f, 0.85f)

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly,
                verticalAlignment = Alignment.Bottom
            ) {
                dayLabels.zip(energyLevels).forEach { (day, level) ->
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Box(
                            modifier = Modifier
                                .width(28.dp)
                                .height((level * 60).dp)
                                .clip(RoundedCornerShape(6.dp))
                                .background(
                                    Brush.verticalGradient(
                                        listOf(ForestGreen.copy(alpha = level), SageGreen.copy(alpha = 0.3f))
                                    )
                                )
                        )
                        Spacer(Modifier.height(4.dp))
                        Text(day, fontSize = 10.sp, color = textColor.copy(alpha = 0.5f))
                    }
                }
            }

            Spacer(Modifier.height(12.dp))
            Text(
                "Your energy peaks mid-week. Consider scheduling deep work on Tuesday-Thursday.",
                fontSize = 13.sp,
                color = textColor.copy(alpha = 0.7f),
                fontStyle = FontStyle.Italic,
                lineHeight = 18.sp
            )
        }
    }
}

// ── Quick Actions ──────────────────────────────────────────────────────────────

@Composable
private fun QuickActions(
    isDeepRest: Boolean,
    textColor: Color,
    onBreathwork: () -> Unit,
    onInsight: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        listOf(
            "Breathwork" to onBreathwork,
            "Energy Insights" to onInsight
        ).forEach { (label, action) ->
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = if (isDeepRest) DeepCard else Color(0xFFF0F0EB),
                modifier = Modifier
                    .clip(RoundedCornerShape(12.dp))
                    .clickable(onClick = action)
            ) {
                Text(
                    label,
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = ForestGreen
                )
            }
        }
    }
}

// ── Input Bar ──────────────────────────────────────────────────────────────────

@Composable
private fun InputBar(
    inputText: String,
    onInputChange: (String) -> Unit,
    surfaceColor: Color,
    textColor: Color,
    isDeepRest: Boolean,
    onSend: () -> Unit
) {
    Surface(
        color = surfaceColor,
        tonalElevation = 2.dp,
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            BasicTextField(
                value = inputText,
                onValueChange = onInputChange,
                textStyle = TextStyle(fontSize = 15.sp, color = textColor),
                modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(16.dp))
                    .background(if (isDeepRest) Color(0xFF0D1A12) else Color(0xFFF5F5F0))
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                decorationBox = { inner ->
                    Box {
                        if (inputText.isEmpty()) {
                            Text(
                                "Share what's on your mind...",
                                fontSize = 15.sp,
                                color = textColor.copy(alpha = 0.3f)
                            )
                        }
                        inner()
                    }
                }
            )
            Spacer(Modifier.width(8.dp))
            AnimatedVisibility(visible = inputText.isNotBlank()) {
                IconButton(
                    onClick = onSend,
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(ForestGreen)
                ) {
                    Icon(Icons.Default.Send, "Send", tint = Color.White, modifier = Modifier.size(18.dp))
                }
            }
        }
    }
}
