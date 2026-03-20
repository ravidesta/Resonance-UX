package com.luminous.cosmic

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController

import com.luminous.cosmic.data.models.*
import com.luminous.cosmic.ui.screens.*
import com.luminous.cosmic.ui.theme.ResonanceTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            var isDarkTheme by rememberSaveable { mutableStateOf(true) }
            var birthData by remember { mutableStateOf<BirthData?>(null) }
            var natalChart by remember { mutableStateOf<NatalChart?>(null) }

            ResonanceTheme(darkTheme = isDarkTheme) {
                val navController = rememberNavController()

                val startDestination = if (birthData != null) {
                    Screen.Dashboard.route
                } else {
                    Screen.Onboarding.route
                }

                NavHost(
                    navController = navController,
                    startDestination = startDestination,
                    modifier = Modifier.fillMaxSize(),
                    enterTransition = {
                        fadeIn(animationSpec = tween(400)) +
                            slideInHorizontally(
                                initialOffsetX = { it / 4 },
                                animationSpec = spring(
                                    dampingRatio = Spring.DampingRatioMediumBouncy,
                                    stiffness = Spring.StiffnessLow
                                )
                            )
                    },
                    exitTransition = {
                        fadeOut(animationSpec = tween(300)) +
                            slideOutHorizontally(
                                targetOffsetX = { -it / 4 },
                                animationSpec = tween(300)
                            )
                    },
                    popEnterTransition = {
                        fadeIn(animationSpec = tween(400)) +
                            slideInHorizontally(
                                initialOffsetX = { -it / 4 },
                                animationSpec = spring(
                                    dampingRatio = Spring.DampingRatioMediumBouncy,
                                    stiffness = Spring.StiffnessLow
                                )
                            )
                    },
                    popExitTransition = {
                        fadeOut(animationSpec = tween(300)) +
                            slideOutHorizontally(
                                targetOffsetX = { it / 4 },
                                animationSpec = tween(300)
                            )
                    }
                ) {
                    // ── Onboarding ──
                    composable(Screen.Onboarding.route) {
                        OnboardingScreen(
                            isDarkTheme = isDarkTheme,
                            onComplete = { data ->
                                birthData = data
                                natalChart = ChartCalculator.calculateNatalChart(data)
                                navController.navigate(Screen.Dashboard.route) {
                                    popUpTo(Screen.Onboarding.route) { inclusive = true }
                                }
                            }
                        )
                    }

                    // ── Dashboard ──
                    composable(Screen.Dashboard.route) {
                        val chart = natalChart
                        if (chart != null) {
                            val dailyInsight = remember(chart) {
                                ChartCalculator.generateDailyInsight(chart)
                            }
                            DashboardScreen(
                                chart = chart,
                                dailyInsight = dailyInsight,
                                isDarkTheme = isDarkTheme,
                                onToggleTheme = { isDarkTheme = !isDarkTheme },
                                onNavigateToChart = {
                                    navController.navigate(Screen.NatalChart.route)
                                },
                                onNavigateToReflection = {
                                    navController.navigate(Screen.DailyReflection.route)
                                },
                                onNavigateToMeditation = {
                                    navController.navigate(Screen.Meditation.route)
                                },
                                onNavigateToLibrary = {
                                    navController.navigate(Screen.ChapterLibrary.route)
                                }
                            )
                        }
                    }

                    // ── Natal Chart ──
                    composable(Screen.NatalChart.route) {
                        val chart = natalChart
                        if (chart != null) {
                            NatalChartScreen(
                                chart = chart,
                                isDarkTheme = isDarkTheme,
                                onBack = { navController.popBackStack() }
                            )
                        }
                    }

                    // ── Daily Reflection ──
                    composable(Screen.DailyReflection.route) {
                        val chart = natalChart
                        if (chart != null) {
                            val dailyInsight = remember(chart) {
                                ChartCalculator.generateDailyInsight(chart)
                            }
                            DailyReflectionScreen(
                                dailyInsight = dailyInsight,
                                isDarkTheme = isDarkTheme,
                                onBack = { navController.popBackStack() }
                            )
                        }
                    }

                    // ── Meditation ──
                    composable(Screen.Meditation.route) {
                        MeditationScreen(
                            isDarkTheme = isDarkTheme,
                            onBack = { navController.popBackStack() }
                        )
                    }

                    // ── Chapter Library ──
                    composable(Screen.ChapterLibrary.route) {
                        ChapterLibraryScreen(
                            isDarkTheme = isDarkTheme,
                            onBack = { navController.popBackStack() }
                        )
                    }
                }
            }
        }
    }
}
