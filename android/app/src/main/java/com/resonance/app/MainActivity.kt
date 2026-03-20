package com.resonance.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.systemBars
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.LightMode
import androidx.compose.material.icons.outlined.Brush
import androidx.compose.material.icons.outlined.EditNote
import androidx.compose.material.icons.outlined.Forum
import androidx.compose.material.icons.outlined.Schedule
import androidx.compose.material.icons.outlined.SelfImprovement
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.resonance.app.data.models.ResonanceScreen
import com.resonance.app.ui.screens.DailyFlowScreen
import com.resonance.app.ui.screens.InnerCircleScreen
import com.resonance.app.ui.screens.WellnessScreen
import com.resonance.app.ui.screens.WriterScreen
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen()
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)

        setContent {
            var deepRestMode by rememberSaveable { mutableStateOf(false) }

            ResonanceTheme(deepRestMode = deepRestMode) {
                ResonanceApp(
                    deepRestMode = deepRestMode,
                    onToggleDeepRest = { deepRestMode = !deepRestMode }
                )
            }
        }
    }
}

@Composable
fun ResonanceApp(
    deepRestMode: Boolean,
    onToggleDeepRest: () -> Unit,
) {
    var selectedTab by rememberSaveable { mutableIntStateOf(0) }
    val haptic = LocalHapticFeedback.current

    val tabs = remember {
        listOf(
            NavigationTab("Flow", Icons.Outlined.Schedule, ResonanceScreen.FLOW),
            NavigationTab("Focus", Icons.Outlined.SelfImprovement, ResonanceScreen.FOCUS),
            NavigationTab("Create", Icons.Outlined.EditNote, ResonanceScreen.CREATE),
            NavigationTab("Letters", Icons.Outlined.Forum, ResonanceScreen.LETTERS),
            NavigationTab("Canvas", Icons.Outlined.Brush, ResonanceScreen.CANVAS),
        )
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        contentWindowInsets = WindowInsets(0),
        topBar = {
            ResonanceTopBar(
                currentScreen = tabs[selectedTab].label,
                deepRestMode = deepRestMode,
                onToggleDeepRest = onToggleDeepRest,
            )
        },
        bottomBar = {
            ResonanceBottomNavigation(
                tabs = tabs,
                selectedIndex = selectedTab,
                onTabSelected = { index ->
                    if (index != selectedTab) {
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        selectedTab = index
                    }
                }
            )
        }
    ) { innerPadding ->
        AnimatedContent(
            targetState = selectedTab,
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding),
            transitionSpec = {
                (fadeIn(tween(300)) + scaleIn(
                    initialScale = 0.96f,
                    animationSpec = tween(300)
                )).togetherWith(
                    fadeOut(tween(200)) + scaleOut(
                        targetScale = 1.04f,
                        animationSpec = tween(200)
                    )
                )
            },
            label = "screenTransition"
        ) { tabIndex ->
            when (tabIndex) {
                0 -> DailyFlowScreen()
                1 -> WellnessScreen()
                2 -> WriterScreen()
                3 -> InnerCircleScreen()
                4 -> CanvasPlaceholderScreen()
            }
        }
    }
}

// ─────────────────────────────────────────────
// Top App Bar
// ─────────────────────────────────────────────

@Composable
private fun ResonanceTopBar(
    currentScreen: String,
    deepRestMode: Boolean,
    onToggleDeepRest: () -> Unit,
) {
    val backgroundColor = MaterialTheme.colorScheme.background
    val phaseLabel = remember {
        val hour = java.time.LocalTime.now().hour
        when (hour) {
            in 5..10 -> "Ascend"
            in 11..14 -> "Zenith"
            in 15..19 -> "Descent"
            else -> "Rest"
        }
    }

    Surface(
        color = backgroundColor.copy(alpha = 0.95f),
        tonalElevation = 0.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.systemBars)
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = currentScreen,
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Text(
                    text = "$phaseLabel phase",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Deep Rest toggle
                val toggleScale by animateFloatAsState(
                    targetValue = if (deepRestMode) 1.1f else 1f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessLow
                    ),
                    label = "deepRestScale"
                )

                Surface(
                    modifier = Modifier
                        .graphicsLayer { scaleX = toggleScale; scaleY = toggleScale },
                    shape = CircleShape,
                    color = if (deepRestMode)
                        ResonanceColors.Gold.copy(alpha = 0.15f)
                    else
                        MaterialTheme.colorScheme.surfaceVariant,
                    tonalElevation = 0.dp,
                ) {
                    IconButton(onClick = onToggleDeepRest) {
                        AnimatedContent(
                            targetState = deepRestMode,
                            label = "deepRestIcon"
                        ) { isDeepRest ->
                            Icon(
                                imageVector = if (isDeepRest) Icons.Filled.DarkMode
                                else Icons.Filled.LightMode,
                                contentDescription = if (isDeepRest) "Exit Deep Rest"
                                else "Enter Deep Rest",
                                tint = if (isDeepRest) ResonanceColors.Gold
                                else MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.size(20.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Bottom Navigation
// ─────────────────────────────────────────────

data class NavigationTab(
    val label: String,
    val icon: ImageVector,
    val screen: ResonanceScreen,
)

@Composable
private fun ResonanceBottomNavigation(
    tabs: List<NavigationTab>,
    selectedIndex: Int,
    onTabSelected: (Int) -> Unit,
) {
    val backgroundColor = MaterialTheme.colorScheme.surface

    Surface(
        color = backgroundColor.copy(alpha = 0.97f),
        tonalElevation = 2.dp,
        shadowElevation = 8.dp,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .windowInsetsPadding(WindowInsets.navigationBars)
                .padding(horizontal = 8.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically,
        ) {
            tabs.forEachIndexed { index, tab ->
                ResonanceNavItem(
                    tab = tab,
                    isSelected = index == selectedIndex,
                    onClick = { onTabSelected(index) },
                    modifier = Modifier.weight(1f),
                )
            }
        }
    }
}

@Composable
private fun ResonanceNavItem(
    tab: NavigationTab,
    isSelected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val iconAlpha by animateFloatAsState(
        targetValue = if (isSelected) 1f else 0.5f,
        animationSpec = tween(200),
        label = "iconAlpha"
    )
    val iconScale by animateFloatAsState(
        targetValue = if (isSelected) 1.15f else 1f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness = Spring.StiffnessMedium,
        ),
        label = "iconScale"
    )
    val labelOffset by animateDpAsState(
        targetValue = if (isSelected) 0.dp else 4.dp,
        animationSpec = tween(200),
        label = "labelOffset"
    )

    Column(
        modifier = modifier
            .clip(RoundedCornerShape(12.dp))
            .clickable(
                interactionSource = remember { MutableInteractionSource() },
                indication = null,
                onClick = onClick,
            )
            .padding(vertical = 6.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            contentAlignment = Alignment.Center,
        ) {
            // Active indicator
            AnimatedVisibility(
                visible = isSelected,
                enter = fadeIn(tween(200)) + scaleIn(
                    initialScale = 0.6f,
                    animationSpec = spring(
                        dampingRatio = Spring.DampingRatioMediumBouncy,
                        stiffness = Spring.StiffnessMedium
                    )
                ),
                exit = fadeOut(tween(150)) + scaleOut(targetScale = 0.6f),
            ) {
                Box(
                    modifier = Modifier
                        .size(40.dp)
                        .clip(CircleShape)
                        .background(
                            MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
                        )
                )
            }

            Icon(
                imageVector = tab.icon,
                contentDescription = tab.label,
                modifier = Modifier
                    .size(24.dp)
                    .graphicsLayer {
                        alpha = iconAlpha
                        scaleX = iconScale
                        scaleY = iconScale
                    },
                tint = if (isSelected)
                    MaterialTheme.colorScheme.primary
                else
                    MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }

        Spacer(modifier = Modifier.height(2.dp))

        Text(
            text = tab.label,
            style = MaterialTheme.typography.labelSmall.copy(
                fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal,
                fontSize = 10.sp,
            ),
            color = if (isSelected)
                MaterialTheme.colorScheme.primary
            else
                MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
            modifier = Modifier.offset(y = labelOffset),
        )
    }
}

// ─────────────────────────────────────────────
// Placeholder Canvas Screen
// ─────────────────────────────────────────────

@Composable
fun CanvasPlaceholderScreen() {
    val spacing = ResonanceTheme.spacing

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(spacing.md),
        ) {
            var breathScale by remember { mutableStateOf(1f) }
            val animatedScale by animateFloatAsState(
                targetValue = breathScale,
                animationSpec = tween(4000),
                label = "breathe",
                finishedListener = {
                    breathScale = if (breathScale > 1f) 1f else 1.3f
                }
            )

            LaunchedEffect(Unit) {
                breathScale = 1.3f
            }

            Box(
                modifier = Modifier
                    .size(120.dp)
                    .graphicsLayer {
                        scaleX = animatedScale
                        scaleY = animatedScale
                        alpha = 0.3f + (animatedScale - 1f) * 2f
                    }
                    .drawBehind {
                        drawCircle(
                            brush = Brush.radialGradient(
                                colors = listOf(
                                    ResonanceColors.Gold.copy(alpha = 0.4f),
                                    ResonanceColors.Green600.copy(alpha = 0.1f),
                                    Color.Transparent,
                                )
                            )
                        )
                    }
            )

            Text(
                text = "Canvas",
                style = MaterialTheme.typography.headlineLarge,
                color = MaterialTheme.colorScheme.onBackground,
            )
            Text(
                text = "Your creative space is being prepared",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
