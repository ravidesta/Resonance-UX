package com.luminous.resonance.ui.ecosystem

import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.luminous.resonance.ui.theme.*
import kotlin.math.cos
import kotlin.math.sin

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

data class EcosystemState(
    val profile: UserProfile = UserProfile(),
    val studyGroups: List<StudyGroup> = emptyList(),
    val practiceCircles: List<PracticeCircle> = emptyList(),
    val communityFeed: List<FeedPost> = emptyList(),
    val developmentalJourney: DevelopmentalJourney = DevelopmentalJourney(),
    val networkNodes: List<NetworkNode> = emptyList(),
)

data class UserProfile(
    val displayName: String = "",
    val avatarUrl: String = "",
    val joinDate: String = "",
    val booksRead: Int = 0,
    val practiceHours: Float = 0f,
    val currentStage: String = "",
    val badges: List<String> = emptyList(),
)

data class StudyGroup(
    val id: String,
    val title: String,
    val memberCount: Int,
    val nextSessionDate: String,
    val currentChapter: String,
    val isJoined: Boolean,
)

data class PracticeCircle(
    val id: String,
    val title: String,
    val practiceType: String,
    val memberCount: Int,
    val frequency: String,
    val isJoined: Boolean,
)

data class FeedPost(
    val id: String,
    val authorName: String,
    val authorAvatarUrl: String,
    val content: String,
    val timestamp: String,
    val likes: Int,
    val comments: Int,
    val type: PostType,
)

enum class PostType {
    REFLECTION, INSIGHT, PRACTICE_LOG, MILESTONE, QUESTION
}

data class DevelopmentalJourney(
    val stages: List<DevelopmentalStage> = emptyList(),
    val currentStageIndex: Int = 0,
)

data class DevelopmentalStage(
    val name: String,
    val description: String,
    val progress: Float,
    val isUnlocked: Boolean,
)

data class NetworkNode(
    val id: String,
    val label: String,
    val connections: List<String>,
    val strength: Float,
)

// ---------------------------------------------------------------------------
// Ecosystem Hub Screen
// ---------------------------------------------------------------------------

/**
 * Dashboard for the Luminous ecosystem integration, including study groups,
 * practice circles, community feed, profile with developmental tracking,
 * and a network effect visualization.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EcosystemHubScreen(
    state: EcosystemState,
    onStudyGroupClick: (String) -> Unit,
    onPracticeCircleClick: (String) -> Unit,
    onFeedPostClick: (String) -> Unit,
    onLikePost: (String) -> Unit,
    onProfileClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    var selectedTab by rememberSaveable { mutableIntStateOf(0) }
    val tabs = listOf("Dashboard", "Community", "Profile")

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = "Ecosystem",
                        style = MaterialTheme.typography.titleLarge,
                    )
                },
                actions = {
                    IconButton(
                        onClick = onProfileClick,
                        modifier = Modifier.semantics { contentDescription = "Open profile" },
                    ) {
                        Icon(Icons.Default.AccountCircle, contentDescription = null)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.surface,
                ),
            )
        },
        modifier = modifier,
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            // Tab row
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = MaterialTheme.colorScheme.surface,
                contentColor = MaterialTheme.colorScheme.primary,
                indicator = { tabPositions ->
                    if (selectedTab < tabPositions.size) {
                        TabRowDefaults.SecondaryIndicator(
                            Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                            color = ResonanceTheme.extendedColors.gold,
                        )
                    }
                },
            ) {
                tabs.forEachIndexed { index, title ->
                    Tab(
                        selected = selectedTab == index,
                        onClick = { selectedTab = index },
                        text = {
                            Text(
                                text = title,
                                style = MaterialTheme.typography.labelLarge,
                            )
                        },
                    )
                }
            }

            when (selectedTab) {
                0 -> DashboardTab(
                    state = state,
                    onStudyGroupClick = onStudyGroupClick,
                    onPracticeCircleClick = onPracticeCircleClick,
                )
                1 -> CommunityTab(
                    posts = state.communityFeed,
                    onPostClick = onFeedPostClick,
                    onLikePost = onLikePost,
                )
                2 -> ProfileTab(
                    profile = state.profile,
                    journey = state.developmentalJourney,
                    networkNodes = state.networkNodes,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Dashboard Tab
// ---------------------------------------------------------------------------

@Composable
private fun DashboardTab(
    state: EcosystemState,
    onStudyGroupClick: (String) -> Unit,
    onPracticeCircleClick: (String) -> Unit,
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        // Quick stats
        item(key = "stats") {
            QuickStatsRow(profile = state.profile)
        }

        // Study Groups
        item(key = "study_groups_header") {
            SectionHeader(title = "Study Groups", icon = Icons.Default.Groups)
        }
        item(key = "study_groups") {
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(state.studyGroups, key = { it.id }) { group ->
                    StudyGroupCard(
                        group = group,
                        onClick = { onStudyGroupClick(group.id) },
                    )
                }
            }
        }

        // Practice Circles
        item(key = "practice_circles_header") {
            SectionHeader(title = "Practice Circles", icon = Icons.Default.SelfImprovement)
        }
        item(key = "practice_circles") {
            LazyRow(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
            ) {
                items(state.practiceCircles, key = { it.id }) { circle ->
                    PracticeCircleCard(
                        circle = circle,
                        onClick = { onPracticeCircleClick(circle.id) },
                    )
                }
            }
        }

        // Network visualization
        item(key = "network_header") {
            SectionHeader(title = "Your Network", icon = Icons.Default.Hub)
        }
        item(key = "network") {
            NetworkGraphVisualization(
                nodes = state.networkNodes,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(250.dp),
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Quick Stats Row
// ---------------------------------------------------------------------------

@Composable
private fun QuickStatsRow(profile: UserProfile) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        StatCard(
            label = "Books Read",
            value = "${profile.booksRead}",
            icon = Icons.Default.MenuBook,
            modifier = Modifier.weight(1f),
        )
        StatCard(
            label = "Practice Hours",
            value = "%.0f".format(profile.practiceHours),
            icon = Icons.Default.Timer,
            modifier = Modifier.weight(1f),
        )
        StatCard(
            label = "Stage",
            value = profile.currentStage.ifEmpty { "--" },
            icon = Icons.AutoMirrored.Filled.TrendingUp,
            modifier = Modifier.weight(1f),
        )
    }
}

@Composable
private fun StatCard(
    label: String,
    value: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    modifier: Modifier = Modifier,
) {
    GlassSurface(
        modifier = modifier,
        shape = ResonanceShapes.medium,
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Icon(
                icon,
                contentDescription = null,
                tint = ResonanceTheme.extendedColors.gold,
                modifier = Modifier.size(20.dp),
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = value,
                style = MaterialTheme.typography.titleLarge,
            )
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------

@Composable
private fun SectionHeader(
    title: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.padding(vertical = 4.dp),
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = ResonanceTheme.extendedColors.gold,
            modifier = Modifier.size(20.dp),
        )
        Spacer(Modifier.width(8.dp))
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
        )
    }
}

// ---------------------------------------------------------------------------
// Study Group Card
// ---------------------------------------------------------------------------

@Composable
private fun StudyGroupCard(
    group: StudyGroup,
    onClick: () -> Unit,
) {
    Card(
        onClick = onClick,
        modifier = Modifier
            .width(240.dp)
            .semantics { contentDescription = "Study group: ${group.title}" },
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.7f),
        ),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = group.title,
                    style = MaterialTheme.typography.titleSmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.weight(1f),
                )
                if (group.isJoined) {
                    Icon(
                        Icons.Default.CheckCircle,
                        contentDescription = "Joined",
                        tint = ResonanceColors.Green500,
                        modifier = Modifier.size(16.dp),
                    )
                }
            }
            Spacer(Modifier.height(8.dp))
            Text(
                text = "Reading: ${group.currentChapter}",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Spacer(Modifier.height(4.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        Icons.Default.People,
                        contentDescription = null,
                        modifier = Modifier.size(14.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = "${group.memberCount}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Text(
                    text = "Next: ${group.nextSessionDate}",
                    style = MaterialTheme.typography.labelSmall,
                    color = ResonanceTheme.extendedColors.gold,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Practice Circle Card
// ---------------------------------------------------------------------------

@Composable
private fun PracticeCircleCard(
    circle: PracticeCircle,
    onClick: () -> Unit,
) {
    Card(
        onClick = onClick,
        modifier = Modifier
            .width(200.dp)
            .semantics { contentDescription = "Practice circle: ${circle.title}" },
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.7f),
        ),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Icon(
                Icons.Default.SelfImprovement,
                contentDescription = null,
                tint = ResonanceColors.Green500,
                modifier = Modifier.size(24.dp),
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text = circle.title,
                style = MaterialTheme.typography.titleSmall,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                text = circle.practiceType,
                style = MaterialTheme.typography.labelSmall,
                color = ResonanceTheme.extendedColors.gold,
            )
            Spacer(Modifier.height(8.dp))
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
            ) {
                Text(
                    text = "${circle.memberCount} members",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Text(
                    text = circle.frequency,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Community Tab
// ---------------------------------------------------------------------------

@Composable
private fun CommunityTab(
    posts: List<FeedPost>,
    onPostClick: (String) -> Unit,
    onLikePost: (String) -> Unit,
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        items(posts, key = { it.id }) { post ->
            CommunityFeedCard(
                post = post,
                onClick = { onPostClick(post.id) },
                onLike = { onLikePost(post.id) },
            )
        }

        if (posts.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(48.dp),
                    contentAlignment = Alignment.Center,
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Default.Forum,
                            contentDescription = null,
                            modifier = Modifier.size(48.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                        )
                        Spacer(Modifier.height(16.dp))
                        Text(
                            text = "No posts yet",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CommunityFeedCard(
    post: FeedPost,
    onClick: () -> Unit,
    onLike: () -> Unit,
) {
    val postTypeLabel = when (post.type) {
        PostType.REFLECTION -> "Reflection"
        PostType.INSIGHT -> "Insight"
        PostType.PRACTICE_LOG -> "Practice Log"
        PostType.MILESTONE -> "Milestone"
        PostType.QUESTION -> "Question"
    }

    val postTypeColor = when (post.type) {
        PostType.REFLECTION -> ResonanceColors.Green500
        PostType.INSIGHT -> ResonanceTheme.extendedColors.gold
        PostType.PRACTICE_LOG -> ResonanceColors.Green400
        PostType.MILESTONE -> ResonanceTheme.extendedColors.goldDark
        PostType.QUESTION -> MaterialTheme.colorScheme.tertiary
    }

    Card(
        onClick = onClick,
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        shape = ResonanceShapes.medium,
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp),
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Author row
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(ResonanceColors.Green200, CircleShape),
                    contentAlignment = Alignment.Center,
                ) {
                    Text(
                        text = post.authorName.take(1).uppercase(),
                        style = MaterialTheme.typography.labelMedium,
                        color = ResonanceColors.Green800,
                    )
                }
                Spacer(Modifier.width(10.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = post.authorName,
                        style = MaterialTheme.typography.titleSmall,
                    )
                    Text(
                        text = post.timestamp,
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Surface(
                    color = postTypeColor.copy(alpha = 0.12f),
                    shape = RoundedCornerShape(12.dp),
                ) {
                    Text(
                        text = postTypeLabel,
                        style = MaterialTheme.typography.labelSmall,
                        color = postTypeColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                    )
                }
            }

            Spacer(Modifier.height(12.dp))

            // Post content
            Text(
                text = post.content,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 4,
                overflow = TextOverflow.Ellipsis,
            )

            Spacer(Modifier.height(12.dp))

            // Actions row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp),
            ) {
                Row(
                    modifier = Modifier
                        .clickable(
                            onClickLabel = "Like this post",
                            onClick = onLike,
                        )
                        .padding(4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        Icons.Default.FavoriteBorder,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = "${post.likes}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
                Row(
                    modifier = Modifier.padding(4.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(
                        Icons.Default.ChatBubbleOutline,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Spacer(Modifier.width(4.dp))
                    Text(
                        text = "${post.comments}",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Profile Tab
// ---------------------------------------------------------------------------

@Composable
private fun ProfileTab(
    profile: UserProfile,
    journey: DevelopmentalJourney,
    networkNodes: List<NetworkNode>,
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp),
    ) {
        // Profile header
        item(key = "profile_header") {
            ProfileHeader(profile = profile)
        }

        // Developmental journey
        item(key = "journey_header") {
            SectionHeader(
                title = "Developmental Journey",
                icon = Icons.AutoMirrored.Filled.TrendingUp,
            )
        }
        item(key = "journey") {
            DevelopmentalJourneyCard(journey = journey)
        }

        // Badges
        if (profile.badges.isNotEmpty()) {
            item(key = "badges_header") {
                SectionHeader(title = "Badges", icon = Icons.Default.EmojiEvents)
            }
            item(key = "badges") {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    items(profile.badges) { badge ->
                        Surface(
                            color = ResonanceTheme.extendedColors.gold.copy(alpha = 0.12f),
                            shape = RoundedCornerShape(20.dp),
                        ) {
                            Text(
                                text = badge,
                                style = MaterialTheme.typography.labelMedium,
                                color = ResonanceTheme.extendedColors.goldDark,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ProfileHeader(profile: UserProfile) {
    GlassSurface(
        modifier = Modifier.fillMaxWidth(),
        shape = ResonanceShapes.large,
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .background(
                        Brush.linearGradient(
                            colors = listOf(
                                ResonanceColors.Green600,
                                ResonanceColors.Green400,
                            ),
                        ),
                        CircleShape,
                    ),
                contentAlignment = Alignment.Center,
            ) {
                Text(
                    text = profile.displayName.take(2).uppercase(),
                    style = MaterialTheme.typography.headlineMedium,
                    color = ResonanceColors.Green50,
                )
            }
            Spacer(Modifier.height(12.dp))
            Text(
                text = profile.displayName,
                style = MaterialTheme.typography.headlineSmall,
            )
            if (profile.currentStage.isNotEmpty()) {
                Spacer(Modifier.height(4.dp))
                Text(
                    text = profile.currentStage,
                    style = MaterialTheme.typography.labelMedium,
                    color = ResonanceTheme.extendedColors.gold,
                )
            }
            if (profile.joinDate.isNotEmpty()) {
                Spacer(Modifier.height(4.dp))
                Text(
                    text = "Joined ${profile.joinDate}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Developmental Journey Card
// ---------------------------------------------------------------------------

@Composable
private fun DevelopmentalJourneyCard(journey: DevelopmentalJourney) {
    Card(
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface,
        ),
        shape = ResonanceShapes.medium,
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            journey.stages.forEachIndexed { index, stage ->
                DevelopmentalStageItem(
                    stage = stage,
                    isCurrent = index == journey.currentStageIndex,
                    isLast = index == journey.stages.lastIndex,
                )
            }
        }
    }
}

@Composable
private fun DevelopmentalStageItem(
    stage: DevelopmentalStage,
    isCurrent: Boolean,
    isLast: Boolean,
) {
    Row(modifier = Modifier.fillMaxWidth()) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.width(32.dp),
        ) {
            Box(
                modifier = Modifier
                    .size(24.dp)
                    .clip(CircleShape)
                    .background(
                        color = when {
                            stage.progress >= 1f -> ResonanceColors.Green500
                            isCurrent -> ResonanceTheme.extendedColors.gold
                            stage.isUnlocked -> MaterialTheme.colorScheme.surfaceVariant
                            else -> MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                        },
                        shape = CircleShape,
                    ),
                contentAlignment = Alignment.Center,
            ) {
                if (stage.progress >= 1f) {
                    Icon(
                        Icons.Default.Check,
                        contentDescription = "Completed",
                        modifier = Modifier.size(14.dp),
                        tint = Color.White,
                    )
                }
            }
            if (!isLast) {
                Box(
                    modifier = Modifier
                        .width(2.dp)
                        .height(40.dp)
                        .background(MaterialTheme.colorScheme.outlineVariant),
                )
            }
        }

        Spacer(Modifier.width(12.dp))

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = stage.name,
                style = MaterialTheme.typography.titleSmall,
                color = if (stage.isUnlocked) {
                    MaterialTheme.colorScheme.onSurface
                } else {
                    MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                },
            )
            Text(
                text = stage.description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
            if (isCurrent && stage.progress < 1f) {
                Spacer(Modifier.height(4.dp))
                LinearProgressIndicator(
                    progress = { stage.progress },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(4.dp)
                        .clip(RoundedCornerShape(2.dp)),
                    color = ResonanceTheme.extendedColors.gold,
                    trackColor = MaterialTheme.colorScheme.surfaceVariant,
                )
            }
            if (!isLast) {
                Spacer(Modifier.height(16.dp))
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Network Graph Visualization
// ---------------------------------------------------------------------------

/**
 * A simple force-directed-style network graph visualization showing
 * connections between concepts, practices, and community members.
 * Nodes pulse gently with a breathing animation.
 */
@Composable
private fun NetworkGraphVisualization(
    nodes: List<NetworkNode>,
    modifier: Modifier = Modifier,
) {
    val breathScale by rememberBreathingAnimation(
        min = 0.95f,
        max = 1.05f,
        durationMs = 5_000,
    )

    val goldColor = ResonanceTheme.extendedColors.gold
    val greenColor = ResonanceColors.Green500
    val lineColor = MaterialTheme.colorScheme.outlineVariant

    Canvas(
        modifier = modifier
            .clip(ResonanceShapes.medium)
            .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f))
            .semantics { contentDescription = "Network graph with ${nodes.size} nodes" },
    ) {
        if (nodes.isEmpty()) return@Canvas

        val w = size.width
        val h = size.height
        val centerX = w / 2f
        val centerY = h / 2f
        val radius = minOf(w, h) * 0.35f

        // Position nodes in a circle
        val nodePositions = nodes.mapIndexed { index, _ ->
            val angle = (2.0 * Math.PI * index / nodes.size).toFloat()
            Offset(
                centerX + radius * cos(angle) * breathScale,
                centerY + radius * sin(angle) * breathScale,
            )
        }

        // Draw connections
        nodes.forEachIndexed { i, node ->
            node.connections.forEach { targetId ->
                val targetIndex = nodes.indexOfFirst { it.id == targetId }
                if (targetIndex >= 0 && targetIndex > i) {
                    drawLine(
                        color = lineColor.copy(alpha = 0.4f),
                        start = nodePositions[i],
                        end = nodePositions[targetIndex],
                        strokeWidth = 1.5f,
                    )
                }
            }
        }

        // Draw nodes
        nodes.forEachIndexed { i, node ->
            val pos = nodePositions[i]
            val nodeRadius = 8.dp.toPx() + node.strength * 12.dp.toPx()
            val nodeColor = if (i % 2 == 0) goldColor else greenColor

            // Glow
            drawCircle(
                color = nodeColor.copy(alpha = 0.15f),
                radius = nodeRadius * 1.8f,
                center = pos,
            )
            // Node
            drawCircle(
                color = nodeColor.copy(alpha = 0.8f),
                radius = nodeRadius,
                center = pos,
            )
            // Border
            drawCircle(
                color = nodeColor,
                radius = nodeRadius,
                center = pos,
                style = Stroke(width = 1.5f),
            )
        }
    }
}
