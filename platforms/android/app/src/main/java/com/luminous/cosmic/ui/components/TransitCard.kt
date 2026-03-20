package com.luminous.cosmic.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.theme.*

@Composable
fun TransitCard(
    transit: Transit,
    modifier: Modifier = Modifier
) {
    val aspectColor = when (transit.aspectType.nature) {
        AspectNature.HARMONIOUS -> ResonanceColors.AspectHarmonious
        AspectNature.CHALLENGING -> ResonanceColors.AspectChallenging
        AspectNature.MAJOR -> ResonanceColors.GoldPrimary
        AspectNature.MINOR -> ResonanceColors.TextSage
    }

    val natureLabel = when (transit.aspectType.nature) {
        AspectNature.HARMONIOUS -> "Harmonious"
        AspectNature.CHALLENGING -> "Growth Edge"
        AspectNature.MAJOR -> "Powerful"
        AspectNature.MINOR -> "Subtle"
    }

    GlassCard(
        modifier = modifier.fillMaxWidth(),
        cornerRadius = 16.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            // Header row: planets and aspect symbol
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Transit planet badge
                    PlanetBadge(
                        planet = transit.planet,
                        color = aspectColor
                    )

                    // Aspect symbol
                    Text(
                        text = transit.aspectType.symbol,
                        style = MaterialTheme.typography.titleMedium,
                        color = aspectColor
                    )

                    // Natal planet badge
                    PlanetBadge(
                        planet = transit.natalPlanet,
                        color = ResonanceColors.GoldPrimary
                    )
                }

                // Nature tag
                Box(
                    modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(aspectColor.copy(alpha = 0.15f))
                        .padding(horizontal = 10.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = natureLabel,
                        style = MaterialTheme.typography.labelSmall,
                        color = aspectColor,
                        fontWeight = FontWeight.Medium
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Transit title
            Text(
                text = "${transit.planet.symbol} ${transit.aspectType.symbol} ${transit.natalPlanet.symbol}",
                style = MaterialTheme.typography.titleSmall,
                color = MaterialTheme.colorScheme.onSurface,
                fontWeight = FontWeight.SemiBold
            )

            Spacer(modifier = Modifier.height(6.dp))

            // Description
            Text(
                text = transit.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                lineHeight = 18.sp
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Intensity bar
            IntensityBar(intensity = transit.intensity, color = aspectColor)

            Spacer(modifier = Modifier.height(6.dp))

            // Date range
            Text(
                text = "${transit.startDate} \u2014 ${transit.endDate}",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.7f)
            )
        }
    }
}

@Composable
private fun PlanetBadge(
    planet: Planet,
    color: Color,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(36.dp)
            .clip(CircleShape)
            .background(color.copy(alpha = 0.12f)),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = planet.unicode,
            style = MaterialTheme.typography.titleMedium,
            color = color
        )
    }
}

@Composable
private fun IntensityBar(
    intensity: Float,
    color: Color,
    modifier: Modifier = Modifier
) {
    val animatedIntensity by animateFloatAsState(
        targetValue = intensity.coerceIn(0f, 1f),
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessLow
        ),
        label = "intensity_anim"
    )

    Column(modifier = modifier) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = "Intensity",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "${(intensity * 100).toInt()}%",
                style = MaterialTheme.typography.labelSmall,
                color = color,
                fontWeight = FontWeight.Bold
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(color.copy(alpha = 0.1f))
        ) {
            Box(
                modifier = Modifier
                    .fillMaxWidth(animatedIntensity)
                    .fillMaxHeight()
                    .clip(RoundedCornerShape(2.dp))
                    .background(
                        brush = Brush.horizontalGradient(
                            colors = listOf(
                                color.copy(alpha = 0.6f),
                                color
                            )
                        )
                    )
            )
        }
    }
}
