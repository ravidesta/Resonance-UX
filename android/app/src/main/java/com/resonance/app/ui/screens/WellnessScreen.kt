package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.Canvas
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
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Shield
import androidx.compose.material.icons.filled.Translate
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.outlined.Biotech
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material.icons.outlined.LocalHospital
import androidx.compose.material.icons.outlined.MonitorHeart
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Science
import androidx.compose.material.icons.outlined.Security
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.resonance.app.data.models.Biomarker
import com.resonance.app.data.models.BiomarkerTrend
import com.resonance.app.data.models.Frequency
import com.resonance.app.data.models.Patient
import com.resonance.app.data.models.Protocol
import com.resonance.app.data.models.ProtocolStep
import com.resonance.app.data.models.Provider
import com.resonance.app.data.models.RiskLevel
import com.resonance.app.ui.components.BiomarkerSparkline
import com.resonance.app.ui.components.GlassMorphismCard
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme

@Composable
fun WellnessScreen() {
    val spacing = ResonanceTheme.spacing
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = remember { listOf("Triage", "Encounter", "Protocols", "Messages") }

    Column(modifier = Modifier.fillMaxSize()) {
        // Tab navigation
        TabRow(
            selectedTabIndex = selectedTab,
            containerColor = MaterialTheme.colorScheme.background,
            contentColor = MaterialTheme.colorScheme.onBackground,
            indicator = { tabPositions ->
                if (selectedTab < tabPositions.size) {
                    TabRowDefaults.SecondaryIndicator(
                        modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                        height = 2.dp,
                        color = ResonanceColors.Gold,
                    )
                }
            },
            divider = {},
        ) {
            tabs.forEachIndexed { index, title ->
                Tab(
                    selected = selectedTab == index,
                    onClick = { selectedTab = index },
                    text = {
                        Text(
                            text = title,
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = if (selectedTab == index) FontWeight.SemiBold else FontWeight.Normal,
                        )
                    },
                )
            }
        }

        when (selectedTab) {
            0 -> TriageView()
            1 -> EncounterView()
            2 -> ProtocolsView()
            3 -> SecureMessagingView()
        }
    }
}

// ─────────────────────────────────────────────
// Triage View
// ─────────────────────────────────────────────

@Composable
private fun TriageView() {
    val spacing = ResonanceTheme.spacing

    val patients = remember {
        listOf(
            Patient(name = "Sarah M.", dateOfBirth = "1985-06-15", mrn = "MRN-001",
                conditions = listOf("Hypertension", "Anxiety"), riskLevel = RiskLevel.HIGH,
                allergies = listOf("Penicillin"), lastEncounter = "2024-01-10"),
            Patient(name = "David L.", dateOfBirth = "1992-03-22", mrn = "MRN-002",
                conditions = listOf("Type 2 Diabetes"), riskLevel = RiskLevel.MODERATE,
                lastEncounter = "2024-01-12"),
            Patient(name = "Maria G.", dateOfBirth = "1978-11-08", mrn = "MRN-003",
                conditions = listOf("Post-surgical follow-up"), riskLevel = RiskLevel.LOW,
                lastEncounter = "2024-01-14"),
            Patient(name = "James R.", dateOfBirth = "1960-01-30", mrn = "MRN-004",
                conditions = listOf("CHF", "COPD", "CKD Stage 3"), riskLevel = RiskLevel.CRITICAL,
                allergies = listOf("Sulfa", "Iodine"), lastEncounter = "2024-01-08"),
        )
    }

    val providers = remember {
        listOf(
            Provider(name = "Dr. Chen", specialty = "Internal Medicine", activePatients = 12, isOnCall = true),
            Provider(name = "Dr. Patel", specialty = "Cardiology", activePatients = 8),
            Provider(name = "Dr. Kim", specialty = "Endocrinology", activePatients = 6),
        )
    }

    LazyColumn(
        contentPadding = PaddingValues(spacing.screenPadding),
        verticalArrangement = Arrangement.spacedBy(spacing.md),
    ) {
        // Provider cards (horizontal scroll)
        item {
            Text(
                text = "On-Call Providers",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(modifier = Modifier.height(spacing.sm))
            LazyRow(horizontalArrangement = Arrangement.spacedBy(spacing.md)) {
                items(providers) { provider ->
                    ProviderCard(provider = provider)
                }
            }
        }

        item {
            Spacer(modifier = Modifier.height(spacing.md))
            Text(
                text = "Patient Queue",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        // Patient biometric cards
        items(patients, key = { it.id }) { patient ->
            PatientBiometricCard(patient = patient)
        }
    }
}

@Composable
private fun ProviderCard(provider: Provider) {
    GlassMorphismCard {
        Column(
            modifier = Modifier
                .width(160.dp)
                .padding(16.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(32.dp)
                        .clip(CircleShape)
                        .background(ResonanceColors.Green700.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        Icons.Outlined.Person,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = ResonanceColors.Green700,
                    )
                }
                if (provider.isOnCall) {
                    Spacer(modifier = Modifier.width(8.dp))
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(ResonanceColors.Success.copy(alpha = 0.15f))
                            .padding(horizontal = 6.dp, vertical = 2.dp),
                    ) {
                        Text(
                            text = "On Call",
                            style = MaterialTheme.typography.labelSmall,
                            color = ResonanceColors.Success,
                        )
                    }
                }
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = provider.name,
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurface,
            )
            Text(
                text = provider.specialty,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Text(
                text = "${provider.activePatients} active",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

@Composable
private fun PatientBiometricCard(patient: Patient) {
    val spacing = ResonanceTheme.spacing
    var isExpanded by remember { mutableStateOf(false) }

    val riskColor = when (patient.riskLevel) {
        RiskLevel.LOW -> ResonanceColors.Success
        RiskLevel.MODERATE -> ResonanceColors.Gold
        RiskLevel.HIGH -> ResonanceColors.Warning
        RiskLevel.CRITICAL -> ResonanceColors.Error
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { isExpanded = !isExpanded },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    ) {
        Column(modifier = Modifier.padding(spacing.cardPadding)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Risk indicator
                Box(
                    modifier = Modifier
                        .size(10.dp)
                        .clip(CircleShape)
                        .background(riskColor),
                )
                Spacer(modifier = Modifier.width(spacing.md))

                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = patient.name,
                        style = MaterialTheme.typography.titleSmall,
                        color = MaterialTheme.colorScheme.onSurface,
                    )
                    Text(
                        text = "MRN: ${patient.mrn} \u2022 ${patient.riskLevel.displayName} Risk",
                        style = MaterialTheme.typography.bodySmall,
                        color = riskColor,
                    )
                }

                // Biometric mini chart
                val sampleData = remember { List(12) { (60 + Math.random() * 40).toFloat() } }
                BiomarkerSparkline(
                    dataPoints = sampleData,
                    modifier = Modifier
                        .width(60.dp)
                        .height(30.dp),
                    lineColor = riskColor,
                    fillColor = riskColor.copy(alpha = 0.08f),
                )
            }

            // Conditions row
            Row(
                modifier = Modifier.padding(top = spacing.sm),
                horizontalArrangement = Arrangement.spacedBy(spacing.xs),
            ) {
                patient.conditions.take(3).forEach { condition ->
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(4.dp))
                            .background(MaterialTheme.colorScheme.surfaceVariant)
                            .padding(horizontal = 8.dp, vertical = 3.dp),
                    ) {
                        Text(
                            text = condition,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }

            // Expanded details
            AnimatedVisibility(
                visible = isExpanded,
                enter = expandVertically(tween(300)) + fadeIn(),
                exit = shrinkVertically(tween(300)) + fadeOut(),
            ) {
                Column(modifier = Modifier.padding(top = spacing.md)) {
                    HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))
                    Spacer(modifier = Modifier.height(spacing.md))

                    if (patient.allergies.isNotEmpty()) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Filled.Warning,
                                contentDescription = "Allergies",
                                modifier = Modifier.size(14.dp),
                                tint = ResonanceColors.Error,
                            )
                            Spacer(modifier = Modifier.width(spacing.xs))
                            Text(
                                text = "Allergies: ${patient.allergies.joinToString(", ")}",
                                style = MaterialTheme.typography.bodySmall,
                                color = ResonanceColors.Error,
                            )
                        }
                        Spacer(modifier = Modifier.height(spacing.sm))
                    }

                    patient.lastEncounter?.let {
                        Text(
                            text = "Last encounter: $it",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Encounter View with Biomarker Canvas Charts
// ─────────────────────────────────────────────

@Composable
private fun EncounterView() {
    val spacing = ResonanceTheme.spacing

    val biomarkers = remember {
        listOf(
            Biomarker(name = "Heart Rate", value = 72f, unit = "bpm",
                normalRangeLow = 60f, normalRangeHigh = 100f, trend = BiomarkerTrend.STABLE, category = "Cardiac"),
            Biomarker(name = "Blood Pressure (Sys)", value = 138f, unit = "mmHg",
                normalRangeLow = 90f, normalRangeHigh = 130f, trend = BiomarkerTrend.RISING, category = "Cardiac"),
            Biomarker(name = "HbA1c", value = 7.2f, unit = "%",
                normalRangeLow = 4f, normalRangeHigh = 5.7f, trend = BiomarkerTrend.FALLING, category = "Metabolic"),
            Biomarker(name = "Cortisol", value = 18.5f, unit = "mcg/dL",
                normalRangeLow = 6f, normalRangeHigh = 18f, trend = BiomarkerTrend.RISING, category = "Endocrine"),
            Biomarker(name = "TSH", value = 3.2f, unit = "mIU/L",
                normalRangeLow = 0.4f, normalRangeHigh = 4f, trend = BiomarkerTrend.STABLE, category = "Endocrine"),
            Biomarker(name = "HRV", value = 42f, unit = "ms",
                normalRangeLow = 40f, normalRangeHigh = 80f, trend = BiomarkerTrend.RISING, category = "Cardiac"),
        )
    }

    var showTranslation by remember { mutableStateOf(false) }

    LazyColumn(
        contentPadding = PaddingValues(spacing.screenPadding),
        verticalArrangement = Arrangement.spacedBy(spacing.md),
    ) {
        // Patient header
        item {
            Card(
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            ) {
                Column(modifier = Modifier.padding(spacing.cardPadding)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Column {
                            Text(
                                text = "Sarah M.",
                                style = MaterialTheme.typography.headlineSmall,
                                color = MaterialTheme.colorScheme.onSurface,
                            )
                            Text(
                                text = "Follow-up \u2022 Hypertension Management",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }

                        // AI Translation toggle
                        IconButton(onClick = { showTranslation = !showTranslation }) {
                            Icon(
                                Icons.Filled.Translate,
                                contentDescription = "AI Translation",
                                tint = if (showTranslation) ResonanceColors.Gold
                                else MaterialTheme.colorScheme.onSurfaceVariant,
                            )
                        }
                    }
                }
            }
        }

        // AI Translation panel
        item {
            AnimatedVisibility(
                visible = showTranslation,
                enter = expandVertically() + fadeIn(),
                exit = shrinkVertically() + fadeOut(),
            ) {
                Card(
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = ResonanceColors.Gold.copy(alpha = 0.08f),
                    ),
                ) {
                    Column(modifier = Modifier.padding(spacing.cardPadding)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                Icons.Filled.Translate,
                                contentDescription = null,
                                modifier = Modifier.size(18.dp),
                                tint = ResonanceColors.Gold,
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text(
                                text = "AI Translation Active",
                                style = MaterialTheme.typography.titleSmall,
                                color = ResonanceColors.Gold,
                            )
                        }
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "Patient-friendly summary: \"Your blood pressure readings have been running a bit high at 138/85. We'd like to see it closer to 130/80. Your blood sugar control (HbA1c) has actually improved, which is great progress.\"",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurface,
                        )
                    }
                }
            }
        }

        // Biomarker cards
        item {
            Text(
                text = "Biomarkers",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        items(biomarkers, key = { it.id }) { biomarker ->
            BiomarkerCard(biomarker = biomarker)
        }

        // Full biomarker chart
        item {
            Spacer(modifier = Modifier.height(spacing.md))
            Text(
                text = "Trend Analysis",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            Spacer(modifier = Modifier.height(spacing.sm))
            BiomarkerTrendChart(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
            )
        }
    }
}

@Composable
private fun BiomarkerCard(biomarker: Biomarker) {
    val statusColor = if (biomarker.isInRange) ResonanceColors.Success else ResonanceColors.Warning

    val sampleHistory = remember {
        List(20) {
            biomarker.value + (Math.random().toFloat() - 0.5f) * biomarker.value * 0.15f
        }
    }

    Card(
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.5.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = biomarker.name,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurface,
                )
                Spacer(modifier = Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = if (biomarker.value == biomarker.value.toLong().toFloat())
                            "${biomarker.value.toLong()}"
                        else
                            "${biomarker.value}",
                        style = MaterialTheme.typography.headlineSmall,
                        color = statusColor,
                        fontWeight = FontWeight.SemiBold,
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = biomarker.unit,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.padding(bottom = 4.dp),
                    )
                }
                Text(
                    text = "Range: ${biomarker.normalRangeLow} - ${biomarker.normalRangeHigh} ${biomarker.unit}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )

                // Trend indicator
                val trendText = when (biomarker.trend) {
                    BiomarkerTrend.RISING -> "\u2191 Rising"
                    BiomarkerTrend.FALLING -> "\u2193 Falling"
                    BiomarkerTrend.STABLE -> "\u2194 Stable"
                    BiomarkerTrend.VOLATILE -> "\u223F Volatile"
                }
                Text(
                    text = trendText,
                    style = MaterialTheme.typography.labelSmall,
                    color = when (biomarker.trend) {
                        BiomarkerTrend.RISING -> if (biomarker.isInRange) ResonanceColors.TextMuted else ResonanceColors.Warning
                        BiomarkerTrend.FALLING -> if (biomarker.isInRange) ResonanceColors.TextMuted else ResonanceColors.Success
                        BiomarkerTrend.STABLE -> ResonanceColors.Success
                        BiomarkerTrend.VOLATILE -> ResonanceColors.Warning
                    },
                )
            }

            // Sparkline
            BiomarkerSparkline(
                dataPoints = sampleHistory,
                modifier = Modifier
                    .width(80.dp)
                    .height(40.dp),
                lineColor = statusColor,
                fillColor = statusColor.copy(alpha = 0.06f),
                normalRangeLow = biomarker.normalRangeLow,
                normalRangeHigh = biomarker.normalRangeHigh,
            )
        }
    }
}

@Composable
private fun BiomarkerTrendChart(modifier: Modifier = Modifier) {
    val heartRateData = remember { List(24) { 65f + (Math.random() * 20).toFloat() } }
    val bpData = remember { List(24) { 125f + (Math.random() * 20).toFloat() } }

    Card(
        modifier = modifier,
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
    ) {
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
        ) {
            val padding = 40f
            val chartWidth = size.width - padding * 2
            val chartHeight = size.height - padding * 2

            // Grid lines
            for (i in 0..4) {
                val y = padding + chartHeight * (i / 4f)
                drawLine(
                    color = Color.Gray.copy(alpha = 0.1f),
                    start = Offset(padding, y),
                    end = Offset(size.width - padding, y),
                    strokeWidth = 1f,
                )
            }

            // Heart rate line
            val hrPath = Path()
            val hrMin = heartRateData.min()
            val hrMax = heartRateData.max()
            val hrRange = (hrMax - hrMin).coerceAtLeast(1f)

            heartRateData.forEachIndexed { index, value ->
                val x = padding + (index.toFloat() / (heartRateData.size - 1)) * chartWidth
                val y = padding + chartHeight * (1f - (value - hrMin) / hrRange)
                if (index == 0) hrPath.moveTo(x, y) else hrPath.lineTo(x, y)
            }

            drawPath(
                path = hrPath,
                color = ResonanceColors.Success,
                style = Stroke(width = 2.5f, cap = StrokeCap.Round),
            )

            // Blood pressure line
            val bpPath = Path()
            val bpMin = bpData.min()
            val bpMax = bpData.max()
            val bpRange = (bpMax - bpMin).coerceAtLeast(1f)

            bpData.forEachIndexed { index, value ->
                val x = padding + (index.toFloat() / (bpData.size - 1)) * chartWidth
                val y = padding + chartHeight * (1f - (value - bpMin) / bpRange)
                if (index == 0) bpPath.moveTo(x, y) else bpPath.lineTo(x, y)
            }

            drawPath(
                path = bpPath,
                color = ResonanceColors.Warning,
                style = Stroke(width = 2.5f, cap = StrokeCap.Round),
            )
        }
    }
}

// ─────────────────────────────────────────────
// Protocols View
// ─────────────────────────────────────────────

@Composable
private fun ProtocolsView() {
    val spacing = ResonanceTheme.spacing
    val haptic = LocalHapticFeedback.current

    val protocols = remember {
        listOf(
            Protocol(name = "Hypertension Management", description = "Stepped-care approach for BP control",
                frequency = Frequency.DAILY.name, isActive = true,
                steps = listOf(
                    ProtocolStep(1, "Measure blood pressure (morning)", isCompleted = true),
                    ProtocolStep(2, "Administer Lisinopril 10mg", isCompleted = true),
                    ProtocolStep(3, "30-minute moderate exercise"),
                    ProtocolStep(4, "Evening BP check and log"),
                )),
            Protocol(name = "Anxiety Regulation", description = "Nervous system regulation protocol",
                frequency = Frequency.AS_NEEDED.name, isActive = true,
                steps = listOf(
                    ProtocolStep(1, "Grounding exercise (5-4-3-2-1)"),
                    ProtocolStep(2, "Box breathing (4-4-4-4) x 3 cycles"),
                    ProtocolStep(3, "Body scan meditation (10 min)"),
                    ProtocolStep(4, "Journal trigger and response"),
                )),
            Protocol(name = "HbA1c Reduction", description = "Dietary and medication protocol for glucose control",
                frequency = Frequency.DAILY.name,
                steps = listOf(
                    ProtocolStep(1, "Fasting glucose check"),
                    ProtocolStep(2, "Metformin 500mg with breakfast"),
                    ProtocolStep(3, "Low-GI meal plan adherence"),
                )),
        )
    }

    LazyColumn(
        contentPadding = PaddingValues(spacing.screenPadding),
        verticalArrangement = Arrangement.spacedBy(spacing.md),
    ) {
        items(protocols, key = { it.id }) { protocol ->
            ProtocolCard(
                protocol = protocol,
                onDeploy = {
                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                },
            )
        }
    }
}

@Composable
private fun ProtocolCard(
    protocol: Protocol,
    onDeploy: () -> Unit,
) {
    var isExpanded by remember { mutableStateOf(protocol.isActive) }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { isExpanded = !isExpanded },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(1.dp),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = protocol.name,
                            style = MaterialTheme.typography.titleSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = FontWeight.SemiBold,
                        )
                        if (protocol.isActive) {
                            Spacer(modifier = Modifier.width(8.dp))
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(4.dp))
                                    .background(ResonanceColors.Success.copy(alpha = 0.12f))
                                    .padding(horizontal = 6.dp, vertical = 2.dp),
                            ) {
                                Text(
                                    text = "Active",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = ResonanceColors.Success,
                                )
                            }
                        }
                    }
                    Text(
                        text = protocol.description,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }

                Icon(
                    Icons.Outlined.Science,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
                )
            }

            AnimatedVisibility(
                visible = isExpanded,
                enter = expandVertically() + fadeIn(),
                exit = shrinkVertically() + fadeOut(),
            ) {
                Column(modifier = Modifier.padding(top = 12.dp)) {
                    HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f))
                    Spacer(modifier = Modifier.height(12.dp))

                    protocol.steps.forEach { step ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Icon(
                                imageVector = if (step.isCompleted) Icons.Filled.CheckCircle
                                else Icons.Outlined.MonitorHeart,
                                contentDescription = null,
                                modifier = Modifier.size(16.dp),
                                tint = if (step.isCompleted) ResonanceColors.Success
                                else MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
                            )
                            Spacer(modifier = Modifier.width(10.dp))
                            Text(
                                text = step.instruction,
                                style = MaterialTheme.typography.bodySmall,
                                color = if (step.isCompleted)
                                    MaterialTheme.colorScheme.onSurfaceVariant
                                else MaterialTheme.colorScheme.onSurface,
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    // Deploy button
                    if (!protocol.isActive) {
                        Surface(
                            modifier = Modifier
                                .clip(RoundedCornerShape(8.dp))
                                .clickable(onClick = onDeploy),
                            color = ResonanceColors.Gold.copy(alpha = 0.1f),
                            shape = RoundedCornerShape(8.dp),
                        ) {
                            Text(
                                text = "Deploy Protocol",
                                style = MaterialTheme.typography.labelMedium,
                                color = ResonanceColors.Gold,
                                fontWeight = FontWeight.SemiBold,
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Secure Messaging
// ─────────────────────────────────────────────

@Composable
private fun SecureMessagingView() {
    val spacing = ResonanceTheme.spacing

    data class SecureThread(
        val id: String,
        val patientName: String,
        val subject: String,
        val lastMessage: String,
        val time: String,
        val isEncrypted: Boolean = true,
        val unread: Boolean = false,
    )

    val threads = remember {
        listOf(
            SecureThread("1", "Sarah M.", "BP Readings Update",
                "Attached this week's morning readings", "10:30 AM", unread = true),
            SecureThread("2", "David L.", "Glucose Log Question",
                "Should I adjust timing of the metformin?", "Yesterday"),
            SecureThread("3", "Maria G.", "Post-op Recovery",
                "Incision site looking much better", "Mon"),
            SecureThread("4", "James R.", "Medication Refill",
                "Need refill for lisinopril", "Last week"),
        )
    }

    LazyColumn(
        contentPadding = PaddingValues(spacing.screenPadding),
        verticalArrangement = Arrangement.spacedBy(spacing.sm),
    ) {
        item {
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(
                    Icons.Filled.Shield,
                    contentDescription = null,
                    modifier = Modifier.size(16.dp),
                    tint = ResonanceColors.Success,
                )
                Spacer(modifier = Modifier.width(6.dp))
                Text(
                    text = "End-to-end encrypted",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceColors.Success,
                )
            }
            Spacer(modifier = Modifier.height(spacing.md))
        }

        items(threads) { thread ->
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(
                    containerColor = if (thread.unread)
                        MaterialTheme.colorScheme.surface
                    else Color.Transparent,
                ),
                elevation = CardDefaults.cardElevation(if (thread.unread) 1.dp else 0.dp),
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(14.dp),
                    verticalAlignment = Alignment.Top,
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = thread.patientName,
                                style = MaterialTheme.typography.titleSmall,
                                fontWeight = if (thread.unread) FontWeight.Bold else FontWeight.Medium,
                                color = MaterialTheme.colorScheme.onSurface,
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            if (thread.isEncrypted) {
                                Icon(
                                    Icons.Filled.Lock,
                                    contentDescription = "Encrypted",
                                    modifier = Modifier.size(12.dp),
                                    tint = ResonanceColors.Success.copy(alpha = 0.6f),
                                )
                            }
                        }
                        Text(
                            text = thread.subject,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = if (thread.unread) FontWeight.Medium else FontWeight.Normal,
                        )
                        Text(
                            text = thread.lastMessage,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                        )
                    }

                    Text(
                        text = thread.time,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}
