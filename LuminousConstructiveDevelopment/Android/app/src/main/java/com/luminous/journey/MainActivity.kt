// MARK: - Luminous Journey™ Android Main Activity
// Single-activity architecture with Jetpack Compose Navigation

package com.luminous.journey

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.*
import com.luminous.journey.ui.home.HomeScreen
import com.luminous.journey.ui.theme.LuminousJourneyTheme
import com.luminous.journey.ui.theme.LuminousColors

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            var isDeepRest by remember { mutableStateOf(false) }

            LuminousJourneyTheme(deepRest = isDeepRest) {
                LuminousJourneyApp()
            }
        }
    }
}

// ─── Navigation ──────────────────────────────────────────────────────────

sealed class Screen(val route: String, val label: String, val icon: ImageVector) {
    data object Home : Screen("home", "Home", Icons.Outlined.Home)
    data object Learn : Screen("learn", "Learn", Icons.Outlined.Book)
    data object Listen : Screen("listen", "Listen", Icons.Outlined.Headphones)
    data object Practice : Screen("practice", "Practice", Icons.Outlined.SelfImprovement)
    data object Journal : Screen("journal", "Journal", Icons.Outlined.Edit)
    data object Guide : Screen("guide", "Guide", Icons.Outlined.Forum)
    data object Community : Screen("community", "Community", Icons.Outlined.Groups)
}

val screens = listOf(
    Screen.Home, Screen.Learn, Screen.Listen, Screen.Practice,
    Screen.Journal, Screen.Guide, Screen.Community
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LuminousJourneyApp() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar(
                containerColor = MaterialTheme.colorScheme.surface,
            ) {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                screens.forEach { screen ->
                    NavigationBarItem(
                        icon = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label, style = MaterialTheme.typography.labelSmall) },
                        selected = currentDestination?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = LuminousColors.GoldPrimary,
                            selectedTextColor = LuminousColors.GoldPrimary,
                            unselectedIconColor = LuminousColors.TextMuted,
                            unselectedTextColor = LuminousColors.TextMuted,
                            indicatorColor = LuminousColors.GoldGlow,
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = Screen.Home.route,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable(Screen.Home.route) {
                HomeScreen(
                    onNavigateToLearn = { navController.navigate(Screen.Learn.route) },
                    onNavigateToListen = { navController.navigate(Screen.Listen.route) },
                    onNavigateToPractice = { navController.navigate(Screen.Practice.route) },
                    onNavigateToJournal = { navController.navigate(Screen.Journal.route) },
                    onNavigateToGuide = { navController.navigate(Screen.Guide.route) },
                    onNavigateToCommunity = { navController.navigate(Screen.Community.route) },
                )
            }
            composable(Screen.Learn.route) {
                // EBookReaderScreen()
                PlaceholderScreen("Learn — eBook Reader")
            }
            composable(Screen.Listen.route) {
                // AudiobookScreen()
                PlaceholderScreen("Listen — Audiobook Player")
            }
            composable(Screen.Practice.route) {
                // PracticeLibraryScreen()
                PlaceholderScreen("Practice — Somatic Library")
            }
            composable(Screen.Journal.route) {
                // JournalScreen()
                PlaceholderScreen("Journal — Reflections")
            }
            composable(Screen.Guide.route) {
                // GuideScreen()
                PlaceholderScreen("Guide — AI Companion")
            }
            composable(Screen.Community.route) {
                // CommunityScreen()
                PlaceholderScreen("Community")
            }
        }
    }
}

@Composable
fun PlaceholderScreen(title: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = androidx.compose.ui.Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onBackground,
        )
    }
}
