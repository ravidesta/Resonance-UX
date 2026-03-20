package com.luminous.cosmic.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.LocalDate
import java.time.LocalTime

import com.luminous.cosmic.data.models.BirthData
import com.luminous.cosmic.ui.components.CosmicBackground
import com.luminous.cosmic.ui.theme.*

@Composable
fun OnboardingScreen(
    isDarkTheme: Boolean,
    onComplete: (BirthData) -> Unit
) {
    var currentStep by remember { mutableIntStateOf(0) }
    var name by remember { mutableStateOf("") }
    var birthYear by remember { mutableStateOf("") }
    var birthMonth by remember { mutableStateOf("") }
    var birthDay by remember { mutableStateOf("") }
    var birthHour by remember { mutableStateOf("") }
    var birthMinute by remember { mutableStateOf("") }
    var birthPlace by remember { mutableStateOf("") }

    val totalSteps = 4

    CosmicBackground(isDarkTheme = isDarkTheme) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(horizontal = 28.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(48.dp))

            // Step indicator
            StepIndicator(
                currentStep = currentStep,
                totalSteps = totalSteps
            )

            Spacer(modifier = Modifier.height(48.dp))

            // Animated step content
            AnimatedContent(
                targetState = currentStep,
                transitionSpec = {
                    slideInHorizontally { it } + fadeIn() togetherWith
                        slideOutHorizontally { -it } + fadeOut()
                },
                modifier = Modifier.weight(1f),
                label = "onboarding_step"
            ) { step ->
                Column(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    when (step) {
                        0 -> WelcomeStep()
                        1 -> NameStep(name = name, onNameChange = { name = it })
                        2 -> BirthDateStep(
                            year = birthYear, month = birthMonth, day = birthDay,
                            hour = birthHour, minute = birthMinute,
                            onYearChange = { birthYear = it },
                            onMonthChange = { birthMonth = it },
                            onDayChange = { birthDay = it },
                            onHourChange = { birthHour = it },
                            onMinuteChange = { birthMinute = it }
                        )
                        3 -> BirthPlaceStep(
                            place = birthPlace,
                            onPlaceChange = { birthPlace = it }
                        )
                    }
                }
            }

            // Navigation buttons
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 32.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (currentStep > 0) {
                    TextButton(onClick = { currentStep-- }) {
                        Text(
                            "Back",
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                } else {
                    Spacer(modifier = Modifier.width(64.dp))
                }

                Button(
                    onClick = {
                        if (currentStep < totalSteps - 1) {
                            currentStep++
                        } else {
                            val birthData = BirthData(
                                name = name.ifBlank { "Cosmic Traveler" },
                                birthDate = try {
                                    LocalDate.of(
                                        birthYear.toIntOrNull() ?: 1990,
                                        birthMonth.toIntOrNull() ?: 1,
                                        birthDay.toIntOrNull() ?: 1
                                    )
                                } catch (e: Exception) {
                                    LocalDate.of(1990, 1, 1)
                                },
                                birthTime = try {
                                    LocalTime.of(
                                        birthHour.toIntOrNull() ?: 12,
                                        birthMinute.toIntOrNull() ?: 0
                                    )
                                } catch (e: Exception) {
                                    LocalTime.NOON
                                },
                                birthPlace = birthPlace.ifBlank { "Unknown" }
                            )
                            onComplete(birthData)
                        }
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = ResonanceColors.GoldPrimary,
                        contentColor = ResonanceColors.ForestDarkest
                    ),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier.height(52.dp)
                ) {
                    Text(
                        text = if (currentStep < totalSteps - 1) "Continue" else "Begin Your Journey",
                        style = MaterialTheme.typography.labelLarge,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.padding(horizontal = 16.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun StepIndicator(currentStep: Int, totalSteps: Int) {
    Row(
        horizontalArrangement = Arrangement.Center,
        verticalAlignment = Alignment.CenterVertically
    ) {
        repeat(totalSteps) { index ->
            val isActive = index <= currentStep
            val width by animateDpAsState(
                targetValue = if (index == currentStep) 28.dp else 8.dp,
                animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
                label = "step_width"
            )
            Box(
                modifier = Modifier
                    .padding(horizontal = 3.dp)
                    .height(8.dp)
                    .width(width)
                    .clip(CircleShape)
                    .background(
                        if (isActive) ResonanceColors.GoldPrimary
                        else ResonanceColors.GoldPrimary.copy(alpha = 0.2f)
                    )
            )
        }
    }
}

@Composable
private fun WelcomeStep() {
    val alpha by animateFloatAsState(
        targetValue = 1f,
        animationSpec = tween(800),
        label = "welcome_alpha"
    )

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(top = 40.dp)
    ) {
        Text(
            text = "\u2728",
            fontSize = 64.sp
        )

        Spacer(modifier = Modifier.height(28.dp))

        Text(
            text = "Luminous Cosmic\nArchitecture",
            style = MaterialTheme.typography.displaySmall,
            color = ResonanceColors.GoldPrimary,
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Light,
            lineHeight = 44.sp
        )

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "Your Developmental Map of the Stars",
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            fontStyle = FontStyle.Italic
        )

        Spacer(modifier = Modifier.height(32.dp))

        Text(
            text = "Discover the cosmic architecture that was present " +
                "at the moment of your first breath. This is your map\u2014" +
                "not of fate, but of potential.",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center,
            lineHeight = 26.sp
        )
    }
}

@Composable
private fun NameStep(name: String, onNameChange: (String) -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(top = 40.dp)
    ) {
        Text(
            text = "What shall the stars call you?",
            style = MaterialTheme.typography.headlineMedium,
            color = ResonanceColors.GoldPrimary,
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Light
        )

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = "Your name anchors your cosmic identity.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(40.dp))

        OutlinedTextField(
            value = name,
            onValueChange = onNameChange,
            label = { Text("Your Name") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ResonanceColors.GoldPrimary,
                unfocusedBorderColor = ResonanceColors.GoldPrimary.copy(alpha = 0.3f),
                cursorColor = ResonanceColors.GoldPrimary,
                focusedLabelColor = ResonanceColors.GoldPrimary
            )
        )
    }
}

@Composable
private fun BirthDateStep(
    year: String, month: String, day: String,
    hour: String, minute: String,
    onYearChange: (String) -> Unit,
    onMonthChange: (String) -> Unit,
    onDayChange: (String) -> Unit,
    onHourChange: (String) -> Unit,
    onMinuteChange: (String) -> Unit
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .padding(top = 24.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Text(
            text = "When did you arrive?",
            style = MaterialTheme.typography.headlineMedium,
            color = ResonanceColors.GoldPrimary,
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Light
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Your birth date and time determine the exact arrangement of the cosmos at your arrival.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Date inputs
        Text(
            text = "Date of Birth",
            style = MaterialTheme.typography.labelLarge,
            color = ResonanceColors.GoldPrimary
        )
        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            CosmicTextField(
                value = year,
                onValueChange = onYearChange,
                label = "Year",
                modifier = Modifier.weight(1.2f),
                keyboardType = KeyboardType.Number
            )
            CosmicTextField(
                value = month,
                onValueChange = onMonthChange,
                label = "Month",
                modifier = Modifier.weight(1f),
                keyboardType = KeyboardType.Number
            )
            CosmicTextField(
                value = day,
                onValueChange = onDayChange,
                label = "Day",
                modifier = Modifier.weight(1f),
                keyboardType = KeyboardType.Number
            )
        }

        Spacer(modifier = Modifier.height(28.dp))

        // Time inputs
        Text(
            text = "Time of Birth (if known)",
            style = MaterialTheme.typography.labelLarge,
            color = ResonanceColors.GoldPrimary
        )
        Spacer(modifier = Modifier.height(12.dp))

        Row(
            modifier = Modifier.fillMaxWidth(0.6f),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            CosmicTextField(
                value = hour,
                onValueChange = onHourChange,
                label = "Hour",
                modifier = Modifier.weight(1f),
                keyboardType = KeyboardType.Number
            )
            CosmicTextField(
                value = minute,
                onValueChange = onMinuteChange,
                label = "Min",
                modifier = Modifier.weight(1f),
                keyboardType = KeyboardType.Number
            )
        }

        Spacer(modifier = Modifier.height(12.dp))

        Text(
            text = "Use 24-hour format. If unknown, noon will be used.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f),
            textAlign = TextAlign.Center
        )
    }
}

@Composable
private fun BirthPlaceStep(place: String, onPlaceChange: (String) -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(top = 40.dp)
    ) {
        Text(
            text = "Where did your journey begin?",
            style = MaterialTheme.typography.headlineMedium,
            color = ResonanceColors.GoldPrimary,
            textAlign = TextAlign.Center,
            fontWeight = FontWeight.Light
        )

        Spacer(modifier = Modifier.height(8.dp))

        Text(
            text = "Your birth location determines the houses and ascendant of your chart.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(40.dp))

        OutlinedTextField(
            value = place,
            onValueChange = onPlaceChange,
            label = { Text("City, Country") },
            singleLine = true,
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(14.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = ResonanceColors.GoldPrimary,
                unfocusedBorderColor = ResonanceColors.GoldPrimary.copy(alpha = 0.3f),
                cursorColor = ResonanceColors.GoldPrimary,
                focusedLabelColor = ResonanceColors.GoldPrimary
            )
        )

        Spacer(modifier = Modifier.height(32.dp))

        GlassCard(
            modifier = Modifier.fillMaxWidth(),
            cornerRadius = 16.dp
        ) {
            Column(modifier = Modifier.padding(20.dp)) {
                Text(
                    text = "A note on accuracy",
                    style = MaterialTheme.typography.titleSmall,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "For the most accurate chart, knowing your exact birth time " +
                        "and location is essential. The Ascendant changes roughly every " +
                        "two hours, so even an approximate time offers valuable insight.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    lineHeight = 18.sp
                )
            }
        }
    }
}

@Composable
private fun CosmicTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label, fontSize = 12.sp) },
        singleLine = true,
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = ResonanceColors.GoldPrimary,
            unfocusedBorderColor = ResonanceColors.GoldPrimary.copy(alpha = 0.3f),
            cursorColor = ResonanceColors.GoldPrimary,
            focusedLabelColor = ResonanceColors.GoldPrimary
        )
    )
}

@Composable
private fun GlassCard(
    modifier: Modifier = Modifier,
    cornerRadius: androidx.compose.ui.unit.Dp = 20.dp,
    content: @Composable BoxScope.() -> Unit
) {
    com.luminous.cosmic.ui.theme.GlassCard(
        modifier = modifier,
        cornerRadius = cornerRadius,
        content = content
    )
}
