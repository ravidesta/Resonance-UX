package com.luminous.resonance.ui.navigation

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavGraphBuilder
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navDeepLink
import com.luminous.resonance.ui.theme.ResonanceTheme
import kotlinx.serialization.Serializable

// ---------------------------------------------------------------------------
// Navigation Destinations (Type-Safe)
// ---------------------------------------------------------------------------

/**
 * Sealed hierarchy of navigation destinations using Kotlin serialization
 * for type-safe navigation with Navigation Compose 2.8+.
 */
sealed interface LuminousDestination {

    /** Top-level tab destinations displayed in the bottom nav bar. */
    @Serializable data object Read : LuminousDestination
    @Serializable data object Listen : LuminousDestination
    @Serializable data object Learn : LuminousDestination
    @Serializable data object Coach : LuminousDestination
    @Serializable data object Community : LuminousDestination

    /** Detail destinations navigated to from within tabs. */
    @Serializable data class BookReader(val bookId: String) : LuminousDestination
    @Serializable data class AudioPlayer(val bookId: String) : LuminousDestination
    @Serializable data class StudyGroup(val groupId: String) : LuminousDestination
    @Serializable data class PracticeCircle(val circleId: String) : LuminousDestination
}

// ---------------------------------------------------------------------------
// Bottom Navigation Items
// ---------------------------------------------------------------------------

/**
 * Configuration for each tab in the bottom navigation bar.
 */
enum class BottomNavItem(
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector,
    val route: LuminousDestination,
    val deepLinkPath: String,
) {
    READ(
        label = "Read",
        selectedIcon = Icons.Filled.MenuBook,
        unselectedIcon = Icons.Outlined.MenuBook,
        route = LuminousDestination.Read,
        deepLinkPath = "luminous://read",
    ),
    LISTEN(
        label = "Listen",
        selectedIcon = Icons.Filled.Headphones,
        unselectedIcon = Icons.Outlined.Headphones,
        route = LuminousDestination.Listen,
        deepLinkPath = "luminous://listen",
    ),
    LEARN(
        label = "Learn",
        selectedIcon = Icons.Filled.School,
        unselectedIcon = Icons.Outlined.School,
        route = LuminousDestination.Learn,
        deepLinkPath = "luminous://learn",
    ),
    COACH(
        label = "Coach",
        selectedIcon = Icons.Filled.Psychology,
        unselectedIcon = Icons.Outlined.Psychology,
        route = LuminousDestination.Coach,
        deepLinkPath = "luminous://coach",
    ),
    COMMUNITY(
        label = "Community",
        selectedIcon = Icons.Filled.Groups,
        unselectedIcon = Icons.Outlined.Groups,
        route = LuminousDestination.Community,
        deepLinkPath = "luminous://community",
    ),
}

// ---------------------------------------------------------------------------
// Bottom Navigation Bar
// ---------------------------------------------------------------------------

/**
 * Resonance bottom navigation bar with five tabs. Uses Material3
 * [NavigationBar] with animated icon transitions and gold accent
 * for the selected indicator.
 */
@Composable
fun LuminousBottomNavBar(
    navController: NavController,
    modifier: Modifier = Modifier,
) {
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    NavigationBar(
        modifier = modifier,
        containerColor = MaterialTheme.colorScheme.surface,
        tonalElevation = 2.dp,
    ) {
        BottomNavItem.entries.forEach { item ->
            val isSelected = currentDestination?.hierarchy?.any {
                it.hasRoute(item.route::class)
            } == true

            NavigationBarItem(
                selected = isSelected,
                onClick = {
                    navController.navigate(item.route) {
                        popUpTo(navController.graph.findStartDestination().id) {
                            saveState = true
                        }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                icon = {
                    Icon(
                        imageVector = if (isSelected) item.selectedIcon else item.unselectedIcon,
                        contentDescription = null,
                    )
                },
                label = {
                    Text(
                        text = item.label,
                        style = MaterialTheme.typography.labelSmall,
                    )
                },
                colors = NavigationBarItemDefaults.colors(
                    selectedIconColor = MaterialTheme.colorScheme.onSecondaryContainer,
                    selectedTextColor = MaterialTheme.colorScheme.onSurface,
                    indicatorColor = ResonanceTheme.extendedColors.gold.copy(alpha = 0.2f),
                    unselectedIconColor = MaterialTheme.colorScheme.onSurfaceVariant,
                    unselectedTextColor = MaterialTheme.colorScheme.onSurfaceVariant,
                ),
                modifier = Modifier.semantics {
                    contentDescription = "${item.label} tab"
                },
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Navigation Host
// ---------------------------------------------------------------------------

/**
 * Main navigation host for the Luminous app. Defines the navigation graph
 * with composable destinations, animated transitions, and deep link support.
 *
 * Each top-level tab destination and detail screen is registered here.
 * Screen composables are placeholder references -- wire in the actual
 * screen composables from their respective packages.
 *
 * @param navController The [NavHostController] managing back-stack state.
 * @param modifier Modifier applied to the NavHost container.
 * @param onShowMiniPlayer Callback to show/hide the collapsible mini player.
 */
@Composable
fun LuminousNavHost(
    navController: NavHostController,
    modifier: Modifier = Modifier,
    onShowMiniPlayer: (Boolean) -> Unit = {},
) {
    NavHost(
        navController = navController,
        startDestination = LuminousDestination.Read,
        modifier = modifier,
        enterTransition = {
            fadeIn(animationSpec = tween(300)) +
                slideInHorizontally(
                    initialOffsetX = { it / 4 },
                    animationSpec = tween(300, easing = EaseOutCubic),
                )
        },
        exitTransition = {
            fadeOut(animationSpec = tween(200))
        },
        popEnterTransition = {
            fadeIn(animationSpec = tween(300)) +
                slideInHorizontally(
                    initialOffsetX = { -it / 4 },
                    animationSpec = tween(300, easing = EaseOutCubic),
                )
        },
        popExitTransition = {
            fadeOut(animationSpec = tween(200)) +
                slideOutHorizontally(
                    targetOffsetX = { it / 4 },
                    animationSpec = tween(200),
                )
        },
    ) {
        // -- Top-level tabs --

        composable<LuminousDestination.Read>(
            deepLinks = listOf(navDeepLink { uriPattern = "luminous://read" }),
        ) {
            // TODO: Wire in ReadTabScreen (book library / shelf)
            TabPlaceholder(tabName = "Read")
        }

        composable<LuminousDestination.Listen>(
            deepLinks = listOf(navDeepLink { uriPattern = "luminous://listen" }),
        ) {
            onShowMiniPlayer(false) // hide mini player when full player tab is open
            // TODO: Wire in ListenTabScreen (audiobook library)
            TabPlaceholder(tabName = "Listen")
        }

        composable<LuminousDestination.Learn>(
            deepLinks = listOf(navDeepLink { uriPattern = "luminous://learn" }),
        ) {
            // TODO: Wire in LearnTabScreen (course/module browser)
            TabPlaceholder(tabName = "Learn")
        }

        composable<LuminousDestination.Coach>(
            deepLinks = listOf(navDeepLink { uriPattern = "luminous://coach" }),
        ) {
            // TODO: Wire in CoachTutorScreen
            TabPlaceholder(tabName = "Coach")
        }

        composable<LuminousDestination.Community>(
            deepLinks = listOf(navDeepLink { uriPattern = "luminous://community" }),
        ) {
            // TODO: Wire in EcosystemHubScreen
            TabPlaceholder(tabName = "Community")
        }

        // -- Detail destinations --

        composable<LuminousDestination.BookReader>(
            deepLinks = listOf(
                navDeepLink { uriPattern = "luminous://reader/{bookId}" },
            ),
        ) {
            // TODO: Wire in BookReaderScreen
            TabPlaceholder(tabName = "Book Reader")
        }

        composable<LuminousDestination.AudioPlayer>(
            deepLinks = listOf(
                navDeepLink { uriPattern = "luminous://player/{bookId}" },
            ),
        ) {
            onShowMiniPlayer(false)
            // TODO: Wire in AudiobookPlayerScreen
            TabPlaceholder(tabName = "Audio Player")
        }

        composable<LuminousDestination.StudyGroup>(
            deepLinks = listOf(
                navDeepLink { uriPattern = "luminous://group/{groupId}" },
            ),
        ) {
            // TODO: Wire in StudyGroupDetailScreen
            TabPlaceholder(tabName = "Study Group")
        }

        composable<LuminousDestination.PracticeCircle>(
            deepLinks = listOf(
                navDeepLink { uriPattern = "luminous://circle/{circleId}" },
            ),
        ) {
            // TODO: Wire in PracticeCircleDetailScreen
            TabPlaceholder(tabName = "Practice Circle")
        }
    }
}

// ---------------------------------------------------------------------------
// Placeholder (temporary until screens are wired)
// ---------------------------------------------------------------------------

@Composable
private fun TabPlaceholder(tabName: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = androidx.compose.ui.Alignment.Center,
    ) {
        Text(
            text = tabName,
            style = MaterialTheme.typography.headlineMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
        )
    }
}

// ---------------------------------------------------------------------------
// Navigation Helper Extensions
// ---------------------------------------------------------------------------

/**
 * Navigate to the book reader for a given [bookId].
 */
fun NavController.navigateToBookReader(bookId: String) {
    navigate(LuminousDestination.BookReader(bookId))
}

/**
 * Navigate to the audiobook player for a given [bookId].
 */
fun NavController.navigateToAudioPlayer(bookId: String) {
    navigate(LuminousDestination.AudioPlayer(bookId))
}

/**
 * Navigate to a study group detail view.
 */
fun NavController.navigateToStudyGroup(groupId: String) {
    navigate(LuminousDestination.StudyGroup(groupId))
}

/**
 * Navigate to a practice circle detail view.
 */
fun NavController.navigateToPracticeCircle(circleId: String) {
    navigate(LuminousDestination.PracticeCircle(circleId))
}
