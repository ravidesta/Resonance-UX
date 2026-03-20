package com.luminous.resonance

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import androidx.navigation.compose.rememberNavController
import com.luminous.resonance.ui.audio.AudiobookState
import com.luminous.resonance.ui.audio.CollapsibleMiniPlayer
import com.luminous.resonance.ui.navigation.LuminousBottomNavBar
import com.luminous.resonance.ui.navigation.LuminousNavHost
import com.luminous.resonance.ui.theme.ResonanceTheme

/**
 * Main entry point for the Luminous Integral Architecture Android app.
 *
 * Sets up edge-to-edge rendering, the system splash screen, and the
 * Resonance theme, then hosts the navigation scaffold with a bottom bar,
 * collapsible mini player, and the main navigation graph.
 *
 * Dependency injection: This activity is annotated for Hilt. Inject
 * ViewModels via `hiltViewModel()` inside composable destinations.
 *
 * Add `@AndroidEntryPoint` when the Hilt module is configured.
 */
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        // Splash screen -- must be called before super.onCreate
        val splashScreen = installSplashScreen()

        super.onCreate(savedInstanceState)

        // Edge-to-edge rendering
        enableEdgeToEdge()

        // Optional: Keep splash visible while initial data loads
        var isReady by mutableStateOf(false)
        splashScreen.setKeepOnScreenCondition { !isReady }

        setContent {
            // Mark ready once composition is committed
            LaunchedEffect(Unit) { isReady = true }

            LuminousApp()
        }
    }
}

// ---------------------------------------------------------------------------
// Root App Composable
// ---------------------------------------------------------------------------

/**
 * Root composable for the Luminous app. Wraps everything in the
 * [ResonanceTheme] and provides the navigation scaffold with bottom
 * navigation bar and collapsible mini player.
 */
@Composable
fun LuminousApp() {
    ResonanceTheme {
        val navController = rememberNavController()
        var showMiniPlayer by rememberSaveable { mutableStateOf(true) }

        // In production, this state would come from a shared ViewModel
        // connected to the media session service.
        val audiobookState by remember { mutableStateOf(AudiobookState()) }

        Scaffold(
            bottomBar = {
                Column {
                    // Mini player sits above the bottom nav
                    AnimatedVisibility(
                        visible = showMiniPlayer && audiobookState.title.isNotEmpty(),
                        enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
                        exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
                    ) {
                        CollapsibleMiniPlayer(
                            state = audiobookState,
                            onPlayPause = { /* delegate to ViewModel / MediaSession */ },
                            onExpand = {
                                navController.navigate(
                                    com.luminous.resonance.ui.navigation
                                        .LuminousDestination.Listen
                                )
                            },
                        )
                    }

                    LuminousBottomNavBar(navController = navController)
                }
            },
            contentWindowInsets = WindowInsets(0),
        ) { innerPadding ->
            LuminousNavHost(
                navController = navController,
                modifier = Modifier.padding(innerPadding),
                onShowMiniPlayer = { showMiniPlayer = it },
            )
        }
    }
}
