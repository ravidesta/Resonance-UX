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
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.components.*
import com.luminous.cosmic.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NatalChartScreen(
    chart: NatalChart,
    isDarkTheme: Boolean,
    onBack: () -> Unit
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    var highlightedPlanet by remember { mutableStateOf<Planet?>(null) }
    var showAspects by remember { mutableStateOf(true) }

    val tabs = listOf("Chart", "Planets", "Houses", "Aspects")

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
                    text = "Your Natal Chart",
                    style = MaterialTheme.typography.titleLarge,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.Light,
                    modifier = Modifier.weight(1f)
                )
            }

            // Tab row
            ScrollableTabRow(
                selectedTabIndex = selectedTab,
                containerColor = Color.Transparent,
                contentColor = ResonanceColors.GoldPrimary,
                edgePadding = 16.dp,
                indicator = { tabPositions ->
                    if (selectedTab < tabPositions.size) {
                        TabRowDefaults.SecondaryIndicator(
                            Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                            color = ResonanceColors.GoldPrimary,
                            height = 2.dp
                        )
                    }
                },
                divider = {}
            ) {
                tabs.forEachIndexed { index, title ->
                    Tab(
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        text = {
                            Text(
                                text = title,
                                fontWeight = if (selectedTab == index) FontWeight.SemiBold else FontWeight.Normal
                            )
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Content
            AnimatedContent(
                targetState = selectedTab,
                transitionSpec = {
                    fadeIn(tween(300)) togetherWith fadeOut(tween(200))
                },
                label = "chart_tab"
            ) { tab ->
                when (tab) {
                    0 -> ChartView(chart, highlightedPlanet, showAspects)
                    1 -> PlanetsList(chart, onPlanetSelect = { highlightedPlanet = it; selectedTab = 0 })
                    2 -> HousesList(chart)
                    3 -> AspectsList(chart)
                }
            }
        }
    }
}

@Composable
private fun ChartView(
    chart: NatalChart,
    highlightedPlanet: Planet?,
    showAspects: Boolean
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // The zodiac wheel
        ZodiacWheel(
            chart = chart,
            showAspects = showAspects,
            highlightedPlanet = highlightedPlanet,
            modifier = Modifier.padding(horizontal = 16.dp)
        )

        Spacer(modifier = Modifier.height(12.dp))

        // Chart summary
        GlassCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            cornerRadius = 20.dp
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Chart Overview",
                    style = MaterialTheme.typography.titleSmall,
                    color = ResonanceColors.GoldPrimary,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(12.dp))

                ChartStatRow("Ascendant", "${chart.risingSign.unicode} ${chart.risingSign.symbol}")
                ChartStatRow("Sun", chart.planets.first { it.planet == Planet.SUN }.formattedDegree)
                ChartStatRow("Moon", chart.planets.first { it.planet == Planet.MOON }.formattedDegree)
                ChartStatRow("Dominant Element", getDominantElement(chart))
                ChartStatRow("Dominant Modality", getDominantModality(chart))
            }
        }

        Spacer(modifier = Modifier.height(24.dp))
    }
}

@Composable
private fun ChartStatRow(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = label,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        Text(
            text = value,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurface,
            fontWeight = FontWeight.Medium
        )
    }
}

@Composable
private fun PlanetsList(
    chart: NatalChart,
    onPlanetSelect: (Planet) -> Unit
) {
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(chart.planets) { placement ->
            val elementColor = when (placement.sign.element) {
                Element.FIRE -> ResonanceColors.FireElement
                Element.EARTH -> ResonanceColors.EarthElement
                Element.AIR -> ResonanceColors.AirElement
                Element.WATER -> ResonanceColors.WaterElement
            }

            GlassCard(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onPlanetSelect(placement.planet) },
                cornerRadius = 16.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Planet icon
                    Box(
                        modifier = Modifier
                            .size(48.dp)
                            .clip(CircleShape)
                            .background(elementColor.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = placement.planet.unicode,
                            fontSize = 20.sp,
                            color = elementColor
                        )
                    }

                    Spacer(modifier = Modifier.width(14.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(
                                text = placement.planet.symbol,
                                style = MaterialTheme.typography.titleSmall,
                                color = MaterialTheme.colorScheme.onSurface,
                                fontWeight = FontWeight.SemiBold
                            )
                            if (placement.isRetrograde) {
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(
                                    text = "Rx",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = ResonanceColors.AspectChallenging,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                        Text(
                            text = placement.formattedDegree,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Column(horizontalAlignment = Alignment.End) {
                        Text(
                            text = placement.sign.unicode,
                            fontSize = 18.sp,
                            color = elementColor
                        )
                        Text(
                            text = "House ${placement.house.number}",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }

        item { Spacer(modifier = Modifier.height(16.dp)) }
    }
}

@Composable
private fun HousesList(chart: NatalChart) {
    LazyColumn(
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(chart.houses) { cusp ->
            GlassCard(
                modifier = Modifier.fillMaxWidth(),
                cornerRadius = 16.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .clip(CircleShape)
                            .background(ResonanceColors.GoldPrimary.copy(alpha = 0.12f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "${cusp.house.number}",
                            style = MaterialTheme.typography.titleSmall,
                            color = ResonanceColors.GoldPrimary,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Spacer(modifier = Modifier.width(14.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = cusp.house.description,
                            style = MaterialTheme.typography.titleSmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = FontWeight.Medium
                        )
                        Text(
                            text = "${cusp.sign.unicode} ${cusp.sign.symbol}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    // Planets in this house
                    val planetsInHouse = chart.planets.filter { it.house == cusp.house }
                    if (planetsInHouse.isNotEmpty()) {
                        Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                            planetsInHouse.forEach { p ->
                                Text(
                                    text = p.planet.unicode,
                                    fontSize = 14.sp,
                                    color = ResonanceColors.GoldPrimary
                                )
                            }
                        }
                    }
                }
            }
        }

        item { Spacer(modifier = Modifier.height(16.dp)) }
    }
}

@Composable
private fun AspectsList(chart: NatalChart) {
    val sortedAspects = remember(chart) {
        chart.aspects.sortedBy { it.type.ordinal }
    }

    LazyColumn(
        contentPadding = PaddingValues(horizontal = 20.dp, vertical = 8.dp),
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        items(sortedAspects) { aspect ->
            val aspectColor = when (aspect.type.nature) {
                AspectNature.HARMONIOUS -> ResonanceColors.AspectHarmonious
                AspectNature.CHALLENGING -> ResonanceColors.AspectChallenging
                AspectNature.MAJOR -> ResonanceColors.GoldPrimary
                AspectNature.MINOR -> ResonanceColors.TextSage
            }

            GlassCard(
                modifier = Modifier.fillMaxWidth(),
                cornerRadius = 12.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = aspect.planet1.unicode,
                        fontSize = 16.sp,
                        color = ResonanceColors.GoldPrimary
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = aspect.type.symbol,
                        fontSize = 14.sp,
                        color = aspectColor,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = aspect.planet2.unicode,
                        fontSize = 16.sp,
                        color = ResonanceColors.GoldPrimary
                    )
                    Spacer(modifier = Modifier.width(12.dp))

                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "${aspect.planet1.symbol} ${aspect.type.symbol} ${aspect.planet2.symbol}",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurface,
                            fontWeight = FontWeight.Medium
                        )
                        Text(
                            text = "Orb: ${"%.1f".format(aspect.orb)}\u00B0",
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }

                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(aspectColor.copy(alpha = 0.12f))
                            .padding(horizontal = 8.dp, vertical = 3.dp)
                    ) {
                        Text(
                            text = aspect.type.name.lowercase().replaceFirstChar { it.uppercase() },
                            style = MaterialTheme.typography.labelSmall,
                            color = aspectColor,
                            fontSize = 10.sp
                        )
                    }
                }
            }
        }

        item { Spacer(modifier = Modifier.height(16.dp)) }
    }
}

private fun getDominantElement(chart: NatalChart): String {
    val counts = chart.planets.groupingBy { it.sign.element }.eachCount()
    return counts.maxByOrNull { it.value }?.key?.displayName ?: "Balanced"
}

private fun getDominantModality(chart: NatalChart): String {
    val counts = chart.planets.groupingBy { it.sign.modality }.eachCount()
    return counts.maxByOrNull { it.value }?.key?.displayName ?: "Balanced"
}
