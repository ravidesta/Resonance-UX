package com.resonance.luminous.sharing

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.net.Uri
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.resonance.luminous.ui.*
import kotlin.math.sin

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum class ShareCardType {
    QUOTE, INSIGHT, PROGRESS, JOURNAL_EXCERPT, MILESTONE, MOOD
}

data class ShareCard(
    val type: ShareCardType,
    val title: String,
    val body: String,
    val subtitle: String = "",
    val author: String = "",
    val stat: String = "",
    val emoji: String = "",
)

enum class SocialPlatform(
    val displayName: String,
    val packageName: String,
    val color: Color,
    val icon: androidx.compose.ui.graphics.vector.ImageVector,
) {
    TWITTER("X / Twitter", "com.twitter.android", Color(0xFF1DA1F2), Icons.Filled.Tag),
    INSTAGRAM("Instagram", "com.instagram.android", Color(0xFFE4405F), Icons.Filled.CameraAlt),
    INSTAGRAM_STORIES("IG Stories", "com.instagram.android", Color(0xFFC13584), Icons.Filled.AutoStories),
    TIKTOK("TikTok", "com.zhiliaoapp.musically", Color(0xFF010101), Icons.Filled.MusicNote),
    FACEBOOK("Facebook", "com.facebook.katana", Color(0xFF1877F2), Icons.Filled.Facebook),
    WHATSAPP("WhatsApp", "com.whatsapp", Color(0xFF25D366), Icons.Filled.Chat),
    TELEGRAM("Telegram", "org.telegram.messenger", Color(0xFF0088CC), Icons.Filled.Send),
    PINTEREST("Pinterest", "com.pinterest", Color(0xFFBD081C), Icons.Filled.PushPin),
    LINKEDIN("LinkedIn", "com.linkedin.android", Color(0xFF0A66C2), Icons.Filled.Work),
    THREADS("Threads", "com.instagram.barcelona", Color(0xFF000000), Icons.Filled.AlternateEmail),
    SNAPCHAT("Snapchat", "com.snapchat.android", Color(0xFFFFFC00), Icons.Filled.PhotoCamera),
    REDDIT("Reddit", "com.reddit.frontpage", Color(0xFFFF4500), Icons.Filled.Forum),
    EMAIL("Email", "", Color(0xFF666666), Icons.Filled.Email),
    SMS("iMessage/SMS", "", Color(0xFF34C759), Icons.Filled.Sms),
    COPY_LINK("Copy Link", "", Color(0xFF888888), Icons.Filled.ContentCopy),
    MORE("More...", "", Color(0xFFAAAAAA), Icons.Filled.MoreHoriz),
}

// ---------------------------------------------------------------------------
// Sample share cards
// ---------------------------------------------------------------------------

private val sampleCards = listOf(
    ShareCard(
        type = ShareCardType.QUOTE,
        title = "Daily Wisdom",
        body = "The wound is the place where the Light enters you.",
        author = "Rumi",
        subtitle = "From Luminous Attachment",
    ),
    ShareCard(
        type = ShareCardType.INSIGHT,
        title = "Today's Insight",
        body = "Your need to fix others may be a way of managing your own anxiety. True compassion begins with self-compassion.",
        subtitle = "Chapter 3: Roots & Soil",
    ),
    ShareCard(
        type = ShareCardType.PROGRESS,
        title = "My Journey",
        body = "12-day streak",
        stat = "12",
        subtitle = "4 chapters \u2022 23 journal entries \u2022 8 coaching sessions",
        emoji = "\uD83D\uDD25",
    ),
    ShareCard(
        type = ShareCardType.JOURNAL_EXCERPT,
        title = "From My Journal",
        body = "I caught myself mid-reaction and actually paused. The old me would have fired back immediately but I felt the anger, named it, and chose differently.",
        subtitle = "A moment of growth",
    ),
    ShareCard(
        type = ShareCardType.MILESTONE,
        title = "Milestone Reached",
        body = "Completed Chapter 3: Roots & Soil",
        stat = "3/12",
        subtitle = "Understanding my foundation",
        emoji = "\u2728",
    ),
    ShareCard(
        type = ShareCardType.MOOD,
        title = "Feeling Radiant",
        body = "Today I choose to notice the light in small moments.",
        emoji = "\u2728",
        subtitle = "Mood check-in",
    ),
)

// ---------------------------------------------------------------------------
// Social Share Screen
// ---------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SocialShareScreen(isDark: Boolean) {
    val context = LocalContext.current
    var selectedCard by remember { mutableStateOf(sampleCards[0]) }
    var showPreview by remember { mutableStateOf(false) }
    var selectedPlatform by remember { mutableStateOf<SocialPlatform?>(null) }

    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(scrollState),
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "Share Your Light",
                    style = MaterialTheme.typography.headlineMedium,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                Text(
                    text = "Create beautiful cards to inspire others",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Resonance.goldPrimary,
                )
            }
        }

        Spacer(Modifier.height(16.dp))

        // Card carousel
        Text(
            text = "Choose a card",
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 20.dp),
        )
        Spacer(Modifier.height(8.dp))

        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            items(sampleCards) { card ->
                ShareCardPreview(
                    card = card,
                    isSelected = card == selectedCard,
                    isDark = isDark,
                    onSelect = { selectedCard = card },
                )
            }
        }

        Spacer(Modifier.height(24.dp))

        // Selected card large preview
        Text(
            text = "Preview",
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 20.dp),
        )
        Spacer(Modifier.height(8.dp))

        ShareCardFull(
            card = selectedCard,
            isDark = isDark,
            modifier = Modifier.padding(horizontal = 20.dp),
        )

        Spacer(Modifier.height(24.dp))

        // Platform grid
        Text(
            text = "Share to",
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 20.dp),
        )
        Spacer(Modifier.height(8.dp))

        PlatformGrid(
            isDark = isDark,
            onPlatformSelected = { platform ->
                selectedPlatform = platform
                shareToplatform(context, platform, selectedCard)
            },
        )

        Spacer(Modifier.height(16.dp))

        // Quick share row for most popular
        QuickShareRow(
            isDark = isDark,
            onShare = { platform ->
                shareToplatform(context, platform, selectedCard)
            },
        )

        Spacer(Modifier.height(8.dp))

        // Branding note
        Text(
            text = "All cards include subtle Resonance branding and app store links",
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = .5f),
            textAlign = TextAlign.Center,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
        )

        Spacer(Modifier.height(32.dp))
    }
}

// ---------------------------------------------------------------------------
// Share card thumbnail
// ---------------------------------------------------------------------------

@Composable
private fun ShareCardPreview(
    card: ShareCard,
    isSelected: Boolean,
    isDark: Boolean,
    onSelect: () -> Unit,
) {
    Card(
        onClick = onSelect,
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(
            containerColor = when (card.type) {
                ShareCardType.QUOTE -> Resonance.green800
                ShareCardType.INSIGHT -> Resonance.green700
                ShareCardType.PROGRESS -> Resonance.goldDark.copy(alpha = .8f)
                ShareCardType.JOURNAL_EXCERPT -> Resonance.green900
                ShareCardType.MILESTONE -> Resonance.goldPrimary.copy(alpha = .9f)
                ShareCardType.MOOD -> Resonance.green600
            },
        ),
        border = if (isSelected) BorderStroke(2.dp, Resonance.goldPrimary) else null,
        modifier = Modifier.size(140.dp, 180.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(12.dp),
            verticalArrangement = Arrangement.SpaceBetween,
        ) {
            Text(
                text = card.title,
                style = MaterialTheme.typography.labelSmall,
                color = Resonance.goldLight,
            )
            if (card.emoji.isNotEmpty()) {
                Text(card.emoji, fontSize = 28.sp)
            }
            Text(
                text = card.body,
                style = MaterialTheme.typography.bodySmall,
                color = Color.White,
                maxLines = 3,
                lineHeight = 14.sp,
            )
            Text(
                text = "Resonance",
                style = MaterialTheme.typography.labelSmall,
                color = Resonance.goldPrimary.copy(alpha = .6f),
                fontSize = 8.sp,
            )
        }
    }
}

// ---------------------------------------------------------------------------
// Full-size share card (what gets shared)
// ---------------------------------------------------------------------------

@Composable
fun ShareCardFull(
    card: ShareCard,
    isDark: Boolean,
    modifier: Modifier = Modifier,
) {
    val infiniteTransition = rememberInfiniteTransition(label = "cardBlob")
    val phase by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 6.28f,
        animationSpec = infiniteRepeatable(
            animation = tween(10_000, easing = LinearEasing),
            repeatMode = RepeatMode.Restart,
        ),
        label = "cardPhase",
    )

    val bgGradient = when (card.type) {
        ShareCardType.QUOTE -> Brush.verticalGradient(listOf(Resonance.green900, Resonance.green800, Resonance.green700))
        ShareCardType.INSIGHT -> Brush.verticalGradient(listOf(Resonance.green800, Resonance.green700, Resonance.green600))
        ShareCardType.PROGRESS -> Brush.verticalGradient(listOf(Resonance.goldDark, Resonance.goldPrimary.copy(alpha = .8f), Resonance.green800))
        ShareCardType.JOURNAL_EXCERPT -> Brush.verticalGradient(listOf(Resonance.bgDark, Resonance.green900, Resonance.green800))
        ShareCardType.MILESTONE -> Brush.verticalGradient(listOf(Resonance.goldPrimary, Resonance.goldDark, Resonance.green800))
        ShareCardType.MOOD -> Brush.verticalGradient(listOf(Resonance.green700, Resonance.green600, Resonance.green800))
    }

    Card(
        shape = RoundedCornerShape(24.dp),
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = Color.Transparent),
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(bgGradient)
                .drawBehind {
                    // Organic blob overlays
                    val cx = size.width * 0.3f + sin(phase) * 40f
                    val cy = size.height * 0.4f + sin(phase * 0.7f) * 30f
                    drawCircle(
                        brush = Brush.radialGradient(
                            listOf(Resonance.goldPrimary.copy(alpha = .12f), Color.Transparent),
                            center = Offset(cx, cy),
                            radius = size.minDimension * 0.5f,
                        ),
                        radius = size.minDimension * 0.5f,
                        center = Offset(cx, cy),
                    )
                    val cx2 = size.width * 0.75f + sin(phase * 1.3f) * 25f
                    val cy2 = size.height * 0.7f + sin(phase * 0.5f) * 20f
                    drawCircle(
                        brush = Brush.radialGradient(
                            listOf(Resonance.green400.copy(alpha = .1f), Color.Transparent),
                            center = Offset(cx2, cy2),
                            radius = size.minDimension * 0.4f,
                        ),
                        radius = size.minDimension * 0.4f,
                        center = Offset(cx2, cy2),
                    )
                }
                .padding(28.dp),
        ) {
            Column {
                // Top label
                Text(
                    text = card.title,
                    style = MaterialTheme.typography.labelLarge,
                    color = Resonance.goldLight,
                )

                Spacer(Modifier.height(4.dp))

                // Gold accent line
                Box(
                    modifier = Modifier
                        .width(32.dp)
                        .height(2.dp)
                        .background(
                            Brush.horizontalGradient(
                                listOf(Resonance.goldDark, Resonance.goldPrimary, Resonance.goldLight)
                            ),
                            RoundedCornerShape(1.dp),
                        ),
                )

                Spacer(Modifier.height(20.dp))

                // Emoji
                if (card.emoji.isNotEmpty()) {
                    Text(card.emoji, fontSize = 40.sp)
                    Spacer(Modifier.height(12.dp))
                }

                // Main body
                val bodyStyle = when (card.type) {
                    ShareCardType.QUOTE -> MaterialTheme.typography.headlineSmall.copy(
                        fontStyle = FontStyle.Italic,
                        lineHeight = 32.sp,
                    )
                    ShareCardType.PROGRESS -> MaterialTheme.typography.displaySmall.copy(
                        fontWeight = FontWeight.Bold,
                    )
                    else -> MaterialTheme.typography.titleLarge.copy(lineHeight = 28.sp)
                }

                Text(
                    text = if (card.type == ShareCardType.QUOTE) "\u201C${card.body}\u201D" else card.body,
                    style = bodyStyle,
                    color = Color.White,
                )

                // Author (for quotes)
                if (card.author.isNotEmpty()) {
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = "\u2014 ${card.author}",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Resonance.goldPrimary,
                    )
                }

                // Stat
                if (card.stat.isNotEmpty() && card.type != ShareCardType.PROGRESS) {
                    Spacer(Modifier.height(8.dp))
                    Text(
                        text = card.stat,
                        style = MaterialTheme.typography.displayMedium,
                        color = Resonance.goldPrimary,
                        fontWeight = FontWeight.Bold,
                    )
                }

                Spacer(Modifier.height(12.dp))

                // Subtitle
                if (card.subtitle.isNotEmpty()) {
                    Text(
                        text = card.subtitle,
                        style = MaterialTheme.typography.bodySmall,
                        color = Resonance.goldLight.copy(alpha = .7f),
                    )
                }

                Spacer(Modifier.height(24.dp))

                // Branding footer
                HorizontalDivider(color = Resonance.goldPrimary.copy(alpha = .2f))
                Spacer(Modifier.height(12.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Column {
                        Text(
                            text = "Luminous Attachment",
                            style = MaterialTheme.typography.labelMedium,
                            color = Resonance.goldPrimary,
                            fontWeight = FontWeight.SemiBold,
                        )
                        Text(
                            text = "by Resonance UX",
                            style = MaterialTheme.typography.labelSmall,
                            color = Resonance.goldLight.copy(alpha = .5f),
                        )
                    }
                    Text(
                        text = "resonance.app",
                        style = MaterialTheme.typography.labelSmall,
                        color = Resonance.goldPrimary.copy(alpha = .6f),
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Platform grid
// ---------------------------------------------------------------------------

@Composable
private fun PlatformGrid(
    isDark: Boolean,
    onPlatformSelected: (SocialPlatform) -> Unit,
) {
    val platforms = SocialPlatform.entries.toList()

    LazyVerticalGrid(
        columns = GridCells.Fixed(4),
        contentPadding = PaddingValues(horizontal = 20.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        modifier = Modifier.height(240.dp),
        userScrollEnabled = false,
    ) {
        items(platforms) { platform ->
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.clickable { onPlatformSelected(platform) },
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(platform.color.copy(alpha = .15f)),
                    contentAlignment = Alignment.Center,
                ) {
                    Icon(
                        platform.icon,
                        contentDescription = platform.displayName,
                        tint = platform.color,
                        modifier = Modifier.size(24.dp),
                    )
                }
                Spacer(Modifier.height(4.dp))
                Text(
                    text = platform.displayName,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    maxLines = 1,
                    fontSize = 10.sp,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Quick share row (favourites)
// ---------------------------------------------------------------------------

@Composable
private fun QuickShareRow(
    isDark: Boolean,
    onShare: (SocialPlatform) -> Unit,
) {
    val favourites = listOf(
        SocialPlatform.INSTAGRAM_STORIES,
        SocialPlatform.TWITTER,
        SocialPlatform.WHATSAPP,
        SocialPlatform.FACEBOOK,
    )

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        favourites.forEach { platform ->
            Button(
                onClick = { onShare(platform) },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = platform.color.copy(alpha = .15f),
                    contentColor = platform.color,
                ),
                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 10.dp),
            ) {
                Icon(platform.icon, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(4.dp))
                Text(
                    text = platform.displayName.split(" ").first(),
                    style = MaterialTheme.typography.labelSmall,
                    maxLines = 1,
                )
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Sharing logic
// ---------------------------------------------------------------------------

private fun shareToplatform(
    context: Context,
    platform: SocialPlatform,
    card: ShareCard,
) {
    val shareText = buildShareText(card)

    when (platform) {
        SocialPlatform.COPY_LINK -> {
            val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE)
                    as android.content.ClipboardManager
            clipboard.setPrimaryClip(
                android.content.ClipData.newPlainText("Resonance", shareText)
            )
        }

        SocialPlatform.EMAIL -> {
            val intent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("mailto:")
                putExtra(Intent.EXTRA_SUBJECT, "From Luminous Attachment \u2014 ${card.title}")
                putExtra(Intent.EXTRA_TEXT, shareText)
            }
            context.startActivity(Intent.createChooser(intent, "Share via Email"))
        }

        SocialPlatform.SMS -> {
            val intent = Intent(Intent.ACTION_SENDTO).apply {
                data = Uri.parse("smsto:")
                putExtra("sms_body", shareText)
            }
            context.startActivity(intent)
        }

        SocialPlatform.TWITTER -> {
            val tweetText = buildTwitterText(card)
            val twitterUri = Uri.parse("https://twitter.com/intent/tweet?text=${Uri.encode(tweetText)}")
            val intent = Intent(Intent.ACTION_VIEW, twitterUri)
            context.startActivity(intent)
        }

        SocialPlatform.WHATSAPP -> {
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                setPackage(platform.packageName)
                putExtra(Intent.EXTRA_TEXT, shareText)
            }
            try {
                context.startActivity(intent)
            } catch (e: Exception) {
                // Fallback to generic share
                genericShare(context, shareText)
            }
        }

        SocialPlatform.MORE -> {
            genericShare(context, shareText)
        }

        else -> {
            // Try platform-specific, fall back to generic
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                if (platform.packageName.isNotEmpty()) {
                    setPackage(platform.packageName)
                }
                putExtra(Intent.EXTRA_TEXT, shareText)
            }
            try {
                context.startActivity(intent)
            } catch (e: Exception) {
                genericShare(context, shareText)
            }
        }
    }
}

private fun genericShare(context: Context, text: String) {
    val intent = Intent(Intent.ACTION_SEND).apply {
        type = "text/plain"
        putExtra(Intent.EXTRA_TEXT, text)
    }
    context.startActivity(Intent.createChooser(intent, "Share via"))
}

private fun buildShareText(card: ShareCard): String {
    val body = when (card.type) {
        ShareCardType.QUOTE -> "\u201C${card.body}\u201D\n\u2014 ${card.author}"
        ShareCardType.PROGRESS -> "${card.emoji} ${card.body}\n${card.subtitle}"
        ShareCardType.MILESTONE -> "${card.emoji} ${card.body}\n${card.subtitle}"
        else -> card.body
    }
    return """
        |$body
        |
        |${card.subtitle}
        |
        |From Luminous Attachment by Resonance UX
        |Download: https://resonance.app/luminous
    """.trimMargin()
}

private fun buildTwitterText(card: ShareCard): String {
    val body = when (card.type) {
        ShareCardType.QUOTE -> "\u201C${card.body}\u201D \u2014 ${card.author}"
        ShareCardType.PROGRESS -> "${card.emoji} ${card.body}"
        ShareCardType.MILESTONE -> "${card.emoji} ${card.body}"
        else -> card.body
    }
    // Keep under 280 chars
    val base = "$body\n\n#Resonance #LuminousAttachment #InnerWork"
    return if (base.length > 270) base.take(267) + "..." else base
}
