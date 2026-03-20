package com.resonance.luminous

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.*
import com.resonance.luminous.coach.CoachScreen
import com.resonance.luminous.journal.JournalScreen
import com.resonance.luminous.sharing.SocialShareScreen
import com.resonance.luminous.ui.*

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            LuminousApp()
        }
    }
}

// ---------------------------------------------------------------------------
// Navigation destinations
// ---------------------------------------------------------------------------

sealed class Screen(
    val route: String,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
) {
    data object Home : Screen("home", "Home", Icons.Filled.Home, Icons.Outlined.Home)
    data object Learn : Screen("learn", "Learn", Icons.Filled.MenuBook, Icons.Outlined.MenuBook)
    data object Journal : Screen("journal", "Journal", Icons.Filled.EditNote, Icons.Outlined.EditNote)
    data object Coach : Screen("coach", "Coach", Icons.Filled.Forum, Icons.Outlined.Forum)
    data object Share : Screen("share", "Share", Icons.Filled.Share, Icons.Outlined.Share)
}

private val bottomNavItems = listOf(
    Screen.Home,
    Screen.Learn,
    Screen.Journal,
    Screen.Coach,
    Screen.Share,
)

// ---------------------------------------------------------------------------
// Root composable
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LuminousApp() {
    val isDark = isSystemInDarkTheme()
    var themeOverride by remember { mutableStateOf<Boolean?>(null) }
    val useDark = themeOverride ?: isDark

    LuminousTheme(darkTheme = useDark) {
        val navController = rememberNavController()
        val navBackStackEntry by navController.currentBackStackEntryAsState()
        val currentDestination = navBackStackEntry?.destination

        val backgroundBrush = if (useDark) {
            Brush.verticalGradient(
                colors = listOf(
                    Resonance.bgDark,
                    Resonance.green900,
                    Resonance.bgDark,
                )
            )
        } else {
            Brush.verticalGradient(
                colors = listOf(
                    Resonance.bgLight,
                    Resonance.green200.copy(alpha = .3f),
                    Resonance.bgLight,
                )
            )
        }

        Scaffold(
            containerColor = Color.Transparent,
            modifier = Modifier.background(backgroundBrush),
            bottomBar = {
                NavigationBar(
                    containerColor = if (useDark)
                        Resonance.green900.copy(alpha = .85f)
                    else
                        Color.White.copy(alpha = .85f),
                    tonalElevation = 0.dp,
                ) {
                    bottomNavItems.forEach { screen ->
                        val selected = currentDestination?.hierarchy?.any {
                            it.route == screen.route
                        } == true

                        NavigationBarItem(
                            selected = selected,
                            onClick = {
                                navController.navigate(screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            },
                            icon = {
                                Icon(
                                    imageVector = if (selected) screen.selectedIcon else screen.unselectedIcon,
                                    contentDescription = screen.label,
                                )
                            },
                            label = {
                                Text(
                                    text = screen.label,
                                    style = MaterialTheme.typography.labelSmall,
                                )
                            },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Resonance.goldPrimary,
                                selectedTextColor = Resonance.goldPrimary,
                                unselectedIconColor = if (useDark) Resonance.green200 else Resonance.green700,
                                unselectedTextColor = if (useDark) Resonance.green200 else Resonance.green700,
                                indicatorColor = if (useDark)
                                    Resonance.goldPrimary.copy(alpha = .15f)
                                else
                                    Resonance.goldLight.copy(alpha = .4f),
                            ),
                        )
                    }
                }
            },
        ) { innerPadding ->
            NavHost(
                navController = navController,
                startDestination = Screen.Home.route,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding),
                enterTransition = {
                    fadeIn(animationSpec = tween(300)) +
                            slideInHorizontally(initialOffsetX = { it / 4 })
                },
                exitTransition = {
                    fadeOut(animationSpec = tween(300)) +
                            slideOutHorizontally(targetOffsetX = { -it / 4 })
                },
                popEnterTransition = {
                    fadeIn(animationSpec = tween(300)) +
                            slideInHorizontally(initialOffsetX = { -it / 4 })
                },
                popExitTransition = {
                    fadeOut(animationSpec = tween(300)) +
                            slideOutHorizontally(targetOffsetX = { it / 4 })
                },
            ) {
                composable(Screen.Home.route) {
                    HomeScreen(
                        isDark = useDark,
                        onToggleTheme = { themeOverride = !(themeOverride ?: isDark) },
                        onNavigateToShare = {
                            navController.navigate(Screen.Share.route)
                        },
                    )
                }
                composable(Screen.Learn.route) {
                    LearnScreen(isDark = useDark)
                }
                composable(Screen.Journal.route) {
                    JournalScreen(
                        isDark = useDark,
                        onShareExcerpt = {
                            navController.navigate(Screen.Share.route)
                        },
                    )
                }
                composable(Screen.Coach.route) {
                    CoachScreen(isDark = useDark)
                }
                composable(Screen.Share.route) {
                    SocialShareScreen(isDark = useDark)
                }
            }
        }
    }
}
