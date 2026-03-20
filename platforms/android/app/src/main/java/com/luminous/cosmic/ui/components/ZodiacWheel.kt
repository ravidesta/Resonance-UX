package com.luminous.cosmic.ui.components

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.*
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.*
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlin.math.*

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.theme.ResonanceColors

// ─────────────────────────────────────────────
// Interactive Zodiac Wheel Canvas
// ─────────────────────────────────────────────

@OptIn(ExperimentalTextApi::class)
@Composable
fun ZodiacWheel(
    chart: NatalChart,
    modifier: Modifier = Modifier,
    showAspects: Boolean = true,
    showHouses: Boolean = true,
    highlightedPlanet: Planet? = null
) {
    var rotationAngle by remember { mutableFloatStateOf(0f) }
    var scale by remember { mutableFloatStateOf(1f) }

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

    val textMeasurer = rememberTextMeasurer()

    Canvas(
        modifier = modifier
            .fillMaxWidth()
            .aspectRatio(1f)
            .padding(8.dp)
            .pointerInput(Unit) {
                detectTransformGestures { _, pan, zoom, rotation ->
                    rotationAngle += rotation
                    scale = (scale * zoom).coerceIn(0.5f, 2.5f)
                }
            }
    ) {
        val cx = size.width / 2f
        val cy = size.height / 2f
        val maxRadius = minOf(cx, cy) * 0.92f * scale
        val animProgress = entryAnimation.value

        // Radii for concentric rings
        val outerRingRadius = maxRadius
        val signRingOuter = maxRadius * 0.92f
        val signRingInner = maxRadius * 0.78f
        val houseRingOuter = signRingInner
        val houseRingInner = maxRadius * 0.58f
        val planetRingRadius = maxRadius * 0.68f
        val aspectCircleRadius = maxRadius * 0.45f
        val innerCircleRadius = maxRadius * 0.35f

        val ascOffset = -chart.ascendantDegree - 180f + rotationAngle

        // ── Background glow ──
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    ResonanceColors.GoldPrimary.copy(alpha = 0.06f * animProgress),
                    ResonanceColors.ForestDark.copy(alpha = 0.03f * animProgress),
                    Color.Transparent
                ),
                center = Offset(cx, cy),
                radius = outerRingRadius * 1.2f
            ),
            radius = outerRingRadius * 1.2f,
            center = Offset(cx, cy)
        )

        // ── Outer ring ──
        drawCircle(
            color = ResonanceColors.GoldPrimary.copy(alpha = 0.7f * animProgress),
            radius = outerRingRadius,
            center = Offset(cx, cy),
            style = Stroke(width = 2f)
        )

        // ── Zodiac sign segments ──
        ZodiacSign.entries.forEachIndexed { index, sign ->
            val startAngle = sign.degreesStart + ascOffset
            val sweepAngle = 30f

            val elementColor = when (sign.element) {
                Element.FIRE -> ResonanceColors.FireElement
                Element.EARTH -> ResonanceColors.EarthElement
                Element.AIR -> ResonanceColors.AirElement
                Element.WATER -> ResonanceColors.WaterElement
            }

            // Segment fill
            drawArc(
                color = elementColor.copy(alpha = 0.12f * animProgress),
                startAngle = startAngle,
                sweepAngle = sweepAngle,
                useCenter = true,
                topLeft = Offset(cx - signRingOuter, cy - signRingOuter),
                size = Size(signRingOuter * 2, signRingOuter * 2)
            )

            // Segment divider lines
            val lineAngleRad = Math.toRadians((startAngle).toDouble())
            drawLine(
                color = ResonanceColors.GoldPrimary.copy(alpha = 0.4f * animProgress),
                start = Offset(
                    cx + signRingInner * cos(lineAngleRad).toFloat(),
                    cy + signRingInner * sin(lineAngleRad).toFloat()
                ),
                end = Offset(
                    cx + signRingOuter * cos(lineAngleRad).toFloat(),
                    cy + signRingOuter * sin(lineAngleRad).toFloat()
                ),
                strokeWidth = 1f
            )

            // Sign symbol text
            val midAngle = startAngle + 15f
            val midAngleRad = Math.toRadians(midAngle.toDouble())
            val textRadius = (signRingOuter + signRingInner) / 2f
            val textX = cx + textRadius * cos(midAngleRad).toFloat()
            val textY = cy + textRadius * sin(midAngleRad).toFloat()

            val textResult = textMeasurer.measure(
                text = sign.unicode,
                style = TextStyle(
                    fontSize = (12f * scale).sp,
                    fontWeight = FontWeight.Bold,
                    color = elementColor.copy(alpha = animProgress)
                )
            )
            drawText(
                textLayoutResult = textResult,
                topLeft = Offset(
                    textX - textResult.size.width / 2f,
                    textY - textResult.size.height / 2f
                )
            )
        }

        // ── Sign ring borders ──
        drawCircle(
            color = ResonanceColors.GoldPrimary.copy(alpha = 0.5f * animProgress),
            radius = signRingOuter,
            center = Offset(cx, cy),
            style = Stroke(width = 1.5f)
        )
        drawCircle(
            color = ResonanceColors.GoldPrimary.copy(alpha = 0.5f * animProgress),
            radius = signRingInner,
            center = Offset(cx, cy),
            style = Stroke(width = 1.5f)
        )

        // ── House cusps ──
        if (showHouses) {
            chart.houses.forEachIndexed { index, cusp ->
                val angle = cusp.degree + ascOffset
                val angleRad = Math.toRadians(angle.toDouble())

                // House cusp line
                drawLine(
                    color = ResonanceColors.GoldMuted.copy(alpha = 0.3f * animProgress),
                    start = Offset(
                        cx + innerCircleRadius * cos(angleRad).toFloat(),
                        cy + innerCircleRadius * sin(angleRad).toFloat()
                    ),
                    end = Offset(
                        cx + houseRingOuter * cos(angleRad).toFloat(),
                        cy + houseRingOuter * sin(angleRad).toFloat()
                    ),
                    strokeWidth = if (index % 3 == 0) 1.5f else 0.8f
                )

                // House number
                val nextCusp = chart.houses[(index + 1) % 12]
                var midDeg = (cusp.degree + nextCusp.degree) / 2f
                if (nextCusp.degree < cusp.degree) midDeg = (cusp.degree + nextCusp.degree + 360f) / 2f
                val midAngle = midDeg + ascOffset
                val midRad = Math.toRadians(midAngle.toDouble())
                val numRadius = (houseRingOuter + houseRingInner) / 2f

                val houseText = textMeasurer.measure(
                    text = "${cusp.house.number}",
                    style = TextStyle(
                        fontSize = (9f * scale).sp,
                        color = ResonanceColors.TextSage.copy(alpha = 0.7f * animProgress)
                    )
                )
                drawText(
                    textLayoutResult = houseText,
                    topLeft = Offset(
                        cx + numRadius * cos(midRad).toFloat() - houseText.size.width / 2f,
                        cy + numRadius * sin(midRad).toFloat() - houseText.size.height / 2f
                    )
                )
            }
        }

        // ── Inner circle ──
        drawCircle(
            color = ResonanceColors.GoldPrimary.copy(alpha = 0.3f * animProgress),
            radius = innerCircleRadius,
            center = Offset(cx, cy),
            style = Stroke(width = 1f)
        )
        drawCircle(
            brush = Brush.radialGradient(
                colors = listOf(
                    ResonanceColors.ForestDarkest.copy(alpha = 0.8f * animProgress),
                    ResonanceColors.ForestDark.copy(alpha = 0.4f * animProgress),
                    Color.Transparent
                ),
                center = Offset(cx, cy),
                radius = innerCircleRadius
            ),
            radius = innerCircleRadius,
            center = Offset(cx, cy)
        )

        // ── Aspect lines ──
        if (showAspects) {
            chart.aspects.forEach { aspect ->
                val p1 = chart.planets.firstOrNull { it.planet == aspect.planet1 } ?: return@forEach
                val p2 = chart.planets.firstOrNull { it.planet == aspect.planet2 } ?: return@forEach

                val a1 = Math.toRadians((p1.degree + ascOffset).toDouble())
                val a2 = Math.toRadians((p2.degree + ascOffset).toDouble())

                val lineColor = when (aspect.type.nature) {
                    AspectNature.HARMONIOUS -> ResonanceColors.AspectHarmonious
                    AspectNature.CHALLENGING -> ResonanceColors.AspectChallenging
                    AspectNature.MAJOR -> ResonanceColors.GoldPrimary
                    AspectNature.MINOR -> ResonanceColors.TextSage
                }

                val intensity = (1f - aspect.orb / aspect.type.orb).coerceIn(0.1f, 1f)

                drawLine(
                    color = lineColor.copy(alpha = intensity * 0.5f * animProgress),
                    start = Offset(
                        cx + aspectCircleRadius * cos(a1).toFloat(),
                        cy + aspectCircleRadius * sin(a1).toFloat()
                    ),
                    end = Offset(
                        cx + aspectCircleRadius * cos(a2).toFloat(),
                        cy + aspectCircleRadius * sin(a2).toFloat()
                    ),
                    strokeWidth = 1f + intensity,
                    pathEffect = if (aspect.type.nature == AspectNature.MINOR)
                        PathEffect.dashPathEffect(floatArrayOf(4f, 4f)) else null
                )
            }
        }

        // ── Planet glyphs ──
        chart.planets.forEach { placement ->
            val angle = placement.degree + ascOffset
            val angleRad = Math.toRadians(angle.toDouble())

            val isHighlighted = highlightedPlanet == placement.planet
            val planetColor = if (isHighlighted)
                ResonanceColors.GoldLight
            else
                ResonanceColors.GoldPrimary

            // Planet dot
            val px = cx + planetRingRadius * cos(angleRad).toFloat()
            val py = cy + planetRingRadius * sin(angleRad).toFloat()

            // Glow for highlighted
            if (isHighlighted) {
                drawCircle(
                    color = ResonanceColors.GoldPrimary.copy(alpha = 0.3f),
                    radius = 14f * scale,
                    center = Offset(px, py)
                )
            }

            drawCircle(
                color = planetColor.copy(alpha = animProgress),
                radius = 4f * scale,
                center = Offset(px, py)
            )

            // Planet symbol
            val planetText = textMeasurer.measure(
                text = placement.planet.unicode,
                style = TextStyle(
                    fontSize = (10f * scale).sp,
                    fontWeight = FontWeight.Bold,
                    color = planetColor.copy(alpha = animProgress)
                )
            )

            val labelRadius = planetRingRadius + 14f * scale
            val lx = cx + labelRadius * cos(angleRad).toFloat()
            val ly = cy + labelRadius * sin(angleRad).toFloat()
            drawText(
                textLayoutResult = planetText,
                topLeft = Offset(
                    lx - planetText.size.width / 2f,
                    ly - planetText.size.height / 2f
                )
            )

            // Retrograde marker
            if (placement.isRetrograde) {
                val rxText = textMeasurer.measure(
                    text = "R",
                    style = TextStyle(
                        fontSize = (7f * scale).sp,
                        color = ResonanceColors.AspectChallenging.copy(alpha = 0.8f * animProgress)
                    )
                )
                drawText(
                    textLayoutResult = rxText,
                    topLeft = Offset(
                        lx + planetText.size.width / 2f,
                        ly - rxText.size.height / 2f
                    )
                )
            }

            // Line from planet to zodiac ring
            drawLine(
                color = planetColor.copy(alpha = 0.25f * animProgress),
                start = Offset(px, py),
                end = Offset(
                    cx + signRingInner * cos(angleRad).toFloat(),
                    cy + signRingInner * sin(angleRad).toFloat()
                ),
                strokeWidth = 0.5f
            )
        }

        // ── ASC / MC markers ──
        listOf(
            "ASC" to chart.ascendantDegree,
            "MC" to chart.midheavenDegree
        ).forEach { (label, deg) ->
            val a = Math.toRadians((deg + ascOffset).toDouble())
            val markerText = textMeasurer.measure(
                text = label,
                style = TextStyle(
                    fontSize = (9f * scale).sp,
                    fontWeight = FontWeight.Bold,
                    color = ResonanceColors.GoldLight.copy(alpha = animProgress)
                )
            )
            val mr = outerRingRadius + 10f * scale
            drawText(
                textLayoutResult = markerText,
                topLeft = Offset(
                    cx + mr * cos(a).toFloat() - markerText.size.width / 2f,
                    cy + mr * sin(a).toFloat() - markerText.size.height / 2f
                )
            )
        }
    }
}
