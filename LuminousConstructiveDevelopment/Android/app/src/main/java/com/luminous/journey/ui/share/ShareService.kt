// MARK: - Social Sharing Service — Android
// "Wanton sharing of beautiful things" — gorgeous branded cards for every platform

package com.luminous.journey.ui.share

import android.content.Context
import android.content.Intent
import android.graphics.*
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileOutputStream
import com.luminous.journey.domain.model.*
import com.luminous.journey.ui.theme.LuminousColors

class LuminousSocialShareService(private val context: Context) {

    // ─── Supported Platforms ─────────────────────────────────────

    enum class Platform(val packageName: String?, val displayName: String) {
        INSTAGRAM("com.instagram.android", "Instagram"),
        INSTAGRAM_STORY("com.instagram.android", "Instagram Story"),
        TWITTER("com.twitter.android", "X / Twitter"),
        THREADS("com.instagram.barcelona", "Threads"),
        FACEBOOK("com.facebook.katana", "Facebook"),
        LINKEDIN("com.linkedin.android", "LinkedIn"),
        WHATSAPP("com.whatsapp", "WhatsApp"),
        TELEGRAM("org.telegram.messenger", "Telegram"),
        TIKTOK("com.zhiliaoapp.musically", "TikTok"),
        SYSTEM(null, "More..."),
    }

    // ─── Share Card Generation ───────────────────────────────────

    fun generateShareCard(
        excerpt: String,
        attribution: String = "Luminous Constructive Development™",
        style: BackgroundStyle = BackgroundStyle.FOREST_GOLD,
        width: Int = 1080,
        height: Int = 1080,
    ): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // Background gradient
        val bgColors = backgroundColors(style)
        val gradient = LinearGradient(
            0f, 0f, width.toFloat(), height.toFloat(),
            bgColors.first, bgColors.second,
            Shader.TileMode.CLAMP
        )
        val bgPaint = Paint().apply { shader = gradient }
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), bgPaint)

        // Quote text
        val quotePaint = Paint().apply {
            color = if (style == BackgroundStyle.CREAM_SERIF) Color.parseColor("#1B402E") else Color.WHITE
            textSize = 64f
            isAntiAlias = true
            textAlign = Paint.Align.CENTER
            // In production: use Cormorant Garamond typeface
        }

        val quoteText = "\"$excerpt\""
        val maxWidth = width * 0.75f
        val lines = wrapText(quoteText, quotePaint, maxWidth)

        val startY = (height / 2f) - (lines.size * 80f / 2f)
        lines.forEachIndexed { index, line ->
            canvas.drawText(line, width / 2f, startY + (index * 80f), quotePaint)
        }

        // Attribution
        val attrPaint = Paint().apply {
            color = if (style == BackgroundStyle.CREAM_SERIF) Color.parseColor("#8A9C91") else Color.parseColor("#FFFFFF99".removeRange(0, 1).let { Color.parseColor("#$it") })
            textSize = 32f
            isAntiAlias = true
            textAlign = Paint.Align.CENTER
        }
        canvas.drawText("— $attribution", width / 2f, height - 80f, attrPaint)

        return bitmap
    }

    // ─── Share Execution ─────────────────────────────────────────

    fun shareToAll(
        excerpt: String,
        attribution: String = "Luminous Constructive Development™",
        style: BackgroundStyle = BackgroundStyle.FOREST_GOLD,
        deepLink: String = "https://luminous.journey/share",
    ) {
        val bitmap = generateShareCard(excerpt, attribution, style)
        val imageUri = saveBitmapAndGetUri(bitmap)

        val shareText = buildShareText(excerpt, attribution, deepLink)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, imageUri)
            putExtra(Intent.EXTRA_TEXT, shareText)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        val chooser = Intent.createChooser(intent, "Share this luminous moment")
        chooser.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(chooser)
    }

    fun shareTo(
        platform: Platform,
        excerpt: String,
        attribution: String = "Luminous Constructive Development™",
        style: BackgroundStyle = BackgroundStyle.FOREST_GOLD,
        deepLink: String = "https://luminous.journey/share",
    ) {
        if (platform == Platform.SYSTEM) {
            shareToAll(excerpt, attribution, style, deepLink)
            return
        }

        val bitmap = generateShareCard(excerpt, attribution, style)
        val imageUri = saveBitmapAndGetUri(bitmap)
        val shareText = buildShareText(excerpt, attribution, deepLink)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "image/*"
            putExtra(Intent.EXTRA_STREAM, imageUri)
            putExtra(Intent.EXTRA_TEXT, shareText)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            platform.packageName?.let { setPackage(it) }
        }

        try {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (e: Exception) {
            // Fallback to system share if app not installed
            shareToAll(excerpt, attribution, style, deepLink)
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────

    private fun buildShareText(excerpt: String, attribution: String, deepLink: String): String {
        return """
            "$excerpt"

            — $attribution

            $deepLink

            #LuminousDevelopment #SubjectObject #MeaningMaking #Resonance
        """.trimIndent()
    }

    private fun backgroundColors(style: BackgroundStyle): Pair<Int, Int> = when (style) {
        BackgroundStyle.FOREST_GOLD -> Color.parseColor("#0A1C14") to Color.parseColor("#1B402E")
        BackgroundStyle.CREAM_SERIF -> Color.parseColor("#F5F0E8") to Color.parseColor("#E8DFD0")
        BackgroundStyle.DEEP_REST_GLOW -> Color.parseColor("#050E09") to Color.parseColor("#122E21")
        BackgroundStyle.SOMATIC_WAVE -> Color.parseColor("#2A1A3A") to Color.parseColor("#1A2A3A")
        BackgroundStyle.SPIRAL_PATTERN -> Color.parseColor("#1B402E") to Color.parseColor("#C5A059")
    }

    private fun saveBitmapAndGetUri(bitmap: Bitmap): Uri {
        val file = File(context.cacheDir, "luminous_share_${System.currentTimeMillis()}.png")
        FileOutputStream(file).use { bitmap.compress(Bitmap.CompressFormat.PNG, 100, it) }
        return FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
    }

    private fun wrapText(text: String, paint: Paint, maxWidth: Float): List<String> {
        val words = text.split(" ")
        val lines = mutableListOf<String>()
        var currentLine = ""

        for (word in words) {
            val testLine = if (currentLine.isEmpty()) word else "$currentLine $word"
            if (paint.measureText(testLine) <= maxWidth) {
                currentLine = testLine
            } else {
                if (currentLine.isNotEmpty()) lines.add(currentLine)
                currentLine = word
            }
        }
        if (currentLine.isNotEmpty()) lines.add(currentLine)

        return lines
    }
}
