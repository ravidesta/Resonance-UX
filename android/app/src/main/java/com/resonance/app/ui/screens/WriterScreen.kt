package com.resonance.app.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.ime
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuOpen
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.FavoriteBorder
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.outlined.AccessTime
import androidx.compose.material.icons.outlined.Book
import androidx.compose.material.icons.outlined.Description
import androidx.compose.material.icons.outlined.Edit
import androidx.compose.material.icons.outlined.Fullscreen
import androidx.compose.material.icons.outlined.FullscreenExit
import androidx.compose.material.icons.outlined.Notes
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.resonance.app.data.models.Document
import com.resonance.app.data.models.DocumentCategory
import com.resonance.app.data.models.LuminizeStyle
import com.resonance.app.ui.theme.CormorantGaramondFamily
import com.resonance.app.ui.theme.ManropeFamily
import com.resonance.app.ui.theme.ProseTypography
import com.resonance.app.ui.theme.ResonanceColors
import com.resonance.app.ui.theme.ResonanceTheme
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun WriterScreen() {
    val drawerState = rememberDrawerState(DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    val spacing = ResonanceTheme.spacing

    val documents = remember {
        listOf(
            Document(title = "On Stillness", content = sampleProseContent(), category = DocumentCategory.ESSAY.name,
                wordCount = 342, readingTimeMinutes = 2, isFavorite = true, tags = listOf("philosophy", "calm")),
            Document(title = "Morning Pages - March", content = "The light through the window...",
                category = DocumentCategory.JOURNAL.name, wordCount = 1205, readingTimeMinutes = 5),
            Document(title = "Letter to Elena", content = "Dear Elena,\n\nI've been thinking about...",
                category = DocumentCategory.LETTER.name, wordCount = 480, readingTimeMinutes = 2),
            Document(title = "The Garden of Hours", content = "Time moves differently here...",
                category = DocumentCategory.POEM.name, wordCount = 67, readingTimeMinutes = 1),
            Document(title = "Resonance Design Notes", content = "The key insight about calm technology...",
                category = DocumentCategory.NOTE.name, wordCount = 890, readingTimeMinutes = 4),
            Document(title = "Descent Phase Reflections", content = "As the day transitions...",
                category = DocumentCategory.REFLECTION.name, wordCount = 320, readingTimeMinutes = 2),
        )
    }

    var selectedDocument by remember { mutableStateOf(documents.first()) }
    var isFocusMode by remember { mutableStateOf(false) }

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            WriterDrawer(
                documents = documents,
                selectedId = selectedDocument.id,
                onDocumentSelected = { doc ->
                    selectedDocument = doc
                    scope.launch { drawerState.close() }
                },
                onNewDocument = {
                    scope.launch { drawerState.close() }
                },
            )
        },
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Editor toolbar
            AnimatedVisibility(
                visible = !isFocusMode,
                enter = slideInVertically(tween(300)) { -it } + fadeIn(),
                exit = slideOutVertically(tween(300)) { -it } + fadeOut(),
            ) {
                EditorToolbar(
                    documentTitle = selectedDocument.title,
                    onMenuClick = { scope.launch { drawerState.open() } },
                    isFocusMode = isFocusMode,
                    onToggleFocus = { isFocusMode = !isFocusMode },
                )
            }

            // Editor area
            Box(modifier = Modifier.weight(1f)) {
                WritingEditor(
                    document = selectedDocument,
                    isFocusMode = isFocusMode,
                    onContentChange = { newContent ->
                        selectedDocument = selectedDocument.copy(
                            content = newContent,
                            wordCount = newContent.split("\\s+".toRegex()).filter { it.isNotBlank() }.size,
                        )
                    },
                    onExitFocusMode = { isFocusMode = false },
                )
            }

            // Floating stats bar
            AnimatedVisibility(
                visible = !isFocusMode,
                enter = slideInVertically(tween(300)) { it } + fadeIn(),
                exit = slideOutVertically(tween(300)) { it } + fadeOut(),
            ) {
                StatsBar(
                    wordCount = selectedDocument.wordCount,
                    readingTimeMinutes = selectedDocument.readingTimeMinutes,
                    focusSessions = selectedDocument.focusSessionCount,
                    onLuminize = { /* trigger AI refinement */ },
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Drawer Library
// ─────────────────────────────────────────────

@Composable
private fun WriterDrawer(
    documents: List<Document>,
    selectedId: String,
    onDocumentSelected: (Document) -> Unit,
    onNewDocument: () -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    var selectedCategory by remember { mutableStateOf<String?>(null) }

    val filteredDocs by remember(selectedCategory) {
        derivedStateOf {
            if (selectedCategory == null) documents
            else documents.filter { it.category == selectedCategory }
        }
    }

    val categories = remember {
        DocumentCategory.entries.map { it to categoryIcon(it) }
    }

    ModalDrawerSheet(
        drawerContainerColor = MaterialTheme.colorScheme.background,
        modifier = Modifier.width(300.dp),
    ) {
        Column(
            modifier = Modifier
                .fillMaxHeight()
                .padding(vertical = spacing.lg),
        ) {
            // Drawer header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = spacing.lg),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    text = "Library",
                    style = MaterialTheme.typography.headlineSmall,
                    color = MaterialTheme.colorScheme.onBackground,
                )
                IconButton(onClick = onNewDocument) {
                    Icon(
                        Icons.Filled.Add,
                        contentDescription = "New document",
                        tint = ResonanceColors.Gold,
                    )
                }
            }

            Spacer(modifier = Modifier.height(spacing.md))

            // Category filters
            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(horizontal = spacing.md),
            ) {
                item {
                    NavigationDrawerItem(
                        label = { Text("All Documents") },
                        selected = selectedCategory == null,
                        onClick = { selectedCategory = null },
                        icon = {
                            Icon(Icons.Outlined.Book, contentDescription = null,
                                modifier = Modifier.size(20.dp))
                        },
                        modifier = Modifier.padding(vertical = 2.dp),
                    )
                }

                items(categories) { (category, icon) ->
                    NavigationDrawerItem(
                        label = { Text(category.name.lowercase().replaceFirstChar { it.uppercase() }) },
                        selected = selectedCategory == category.name,
                        onClick = { selectedCategory = category.name },
                        icon = {
                            Icon(icon, contentDescription = null,
                                modifier = Modifier.size(20.dp))
                        },
                        modifier = Modifier.padding(vertical = 2.dp),
                    )
                }
            }

            HorizontalDivider(
                modifier = Modifier.padding(horizontal = spacing.lg, vertical = spacing.md),
                color = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
            )

            // Document list
            Text(
                text = "${filteredDocs.size} documents",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = spacing.lg),
            )

            Spacer(modifier = Modifier.height(spacing.sm))

            LazyColumn(
                modifier = Modifier.weight(1f),
                contentPadding = PaddingValues(horizontal = spacing.md),
            ) {
                items(filteredDocs, key = { it.id }) { doc ->
                    DocumentListItem(
                        document = doc,
                        isSelected = doc.id == selectedId,
                        onClick = { onDocumentSelected(doc) },
                    )
                }
            }
        }
    }
}

@Composable
private fun DocumentListItem(
    document: Document,
    isSelected: Boolean,
    onClick: () -> Unit,
) {
    val bgColor by animateColorAsState(
        targetValue = if (isSelected)
            MaterialTheme.colorScheme.primary.copy(alpha = 0.08f)
        else
            Color.Transparent,
        label = "docListBg"
    )

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 2.dp)
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(8.dp),
        colors = CardDefaults.cardColors(containerColor = bgColor),
        elevation = CardDefaults.cardElevation(0.dp),
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = document.title,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                )
                Spacer(modifier = Modifier.height(2.dp))
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                ) {
                    Text(
                        text = "${document.wordCount} words",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                    Text(
                        text = document.category.lowercase(),
                        style = MaterialTheme.typography.labelSmall,
                        color = ResonanceColors.Gold.copy(alpha = 0.7f),
                    )
                }
            }

            if (document.isFavorite) {
                Icon(
                    Icons.Filled.FavoriteBorder,
                    contentDescription = "Favorite",
                    modifier = Modifier.size(14.dp),
                    tint = ResonanceColors.Gold.copy(alpha = 0.5f),
                )
            }
        }
    }
}

private fun categoryIcon(category: DocumentCategory): ImageVector = when (category) {
    DocumentCategory.JOURNAL -> Icons.Outlined.Book
    DocumentCategory.ESSAY -> Icons.Outlined.Description
    DocumentCategory.LETTER -> Icons.Outlined.Edit
    DocumentCategory.NOTE -> Icons.Outlined.Notes
    DocumentCategory.STORY -> Icons.Outlined.Book
    DocumentCategory.POEM -> Icons.Outlined.Edit
    DocumentCategory.REFLECTION -> Icons.Outlined.AccessTime
}

// ─────────────────────────────────────────────
// Editor Toolbar
// ─────────────────────────────────────────────

@Composable
private fun EditorToolbar(
    documentTitle: String,
    onMenuClick: () -> Unit,
    isFocusMode: Boolean,
    onToggleFocus: () -> Unit,
) {
    Surface(
        color = MaterialTheme.colorScheme.background,
        tonalElevation = 0.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 8.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically,
        ) {
            IconButton(onClick = onMenuClick) {
                Icon(
                    Icons.Filled.Menu,
                    contentDescription = "Open library",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }

            Text(
                text = documentTitle,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onBackground,
                modifier = Modifier.weight(1f),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
            )

            IconButton(onClick = onToggleFocus) {
                Icon(
                    imageVector = if (isFocusMode)
                        Icons.Outlined.FullscreenExit
                    else
                        Icons.Outlined.Fullscreen,
                    contentDescription = "Toggle focus mode",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}

// ─────────────────────────────────────────────
// Writing Editor
// ─────────────────────────────────────────────

@Composable
private fun WritingEditor(
    document: Document,
    isFocusMode: Boolean,
    onContentChange: (String) -> Unit,
    onExitFocusMode: () -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    var editableContent by rememberSaveable(document.id) { mutableStateOf(document.content) }
    val focusRequester = remember { FocusRequester() }
    val scrollState = rememberScrollState()

    val horizontalPadding by animateFloatAsState(
        targetValue = if (isFocusMode) 40f else 20f,
        animationSpec = tween(400),
        label = "editorPadding"
    )

    // Keyboard awareness
    val imeInsets = WindowInsets.ime
    val density = LocalDensity.current
    val imeHeight = remember(imeInsets) {
        with(density) { imeInsets.getBottom(density).toDp() }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(scrollState)
                .padding(horizontal = horizontalPadding.dp)
                .padding(top = spacing.lg, bottom = imeHeight + spacing.huge)
                .imePadding(),
        ) {
            // Document title (editable in place)
            var editableTitle by rememberSaveable(document.id) { mutableStateOf(document.title) }

            BasicTextField(
                value = editableTitle,
                onValueChange = { editableTitle = it },
                textStyle = TextStyle(
                    fontFamily = CormorantGaramondFamily,
                    fontWeight = FontWeight.SemiBold,
                    fontSize = 28.sp,
                    lineHeight = 36.sp,
                    color = MaterialTheme.colorScheme.onBackground,
                ),
                cursorBrush = SolidColor(ResonanceColors.Gold),
                modifier = Modifier.fillMaxWidth(),
                decorationBox = { innerTextField ->
                    if (editableTitle.isEmpty()) {
                        Text(
                            text = "Title",
                            style = TextStyle(
                                fontFamily = CormorantGaramondFamily,
                                fontWeight = FontWeight.SemiBold,
                                fontSize = 28.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                            ),
                        )
                    }
                    innerTextField()
                }
            )

            Spacer(modifier = Modifier.height(spacing.lg))

            // Main content editor
            BasicTextField(
                value = editableContent,
                onValueChange = {
                    editableContent = it
                    onContentChange(it)
                },
                textStyle = ProseTypography.copy(
                    color = MaterialTheme.colorScheme.onBackground,
                ),
                cursorBrush = SolidColor(ResonanceColors.Gold),
                modifier = Modifier
                    .fillMaxWidth()
                    .focusRequester(focusRequester),
                decorationBox = { innerTextField ->
                    if (editableContent.isEmpty()) {
                        Text(
                            text = "Begin writing...",
                            style = ProseTypography.copy(
                                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.3f),
                                fontStyle = FontStyle.Italic,
                            ),
                        )
                    }
                    innerTextField()
                },
            )
        }

        // Focus mode exit button
        if (isFocusMode) {
            IconButton(
                onClick = onExitFocusMode,
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .padding(spacing.md),
            ) {
                Surface(
                    shape = CircleShape,
                    color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.7f),
                ) {
                    Icon(
                        Icons.Filled.Close,
                        contentDescription = "Exit focus mode",
                        modifier = Modifier.padding(8.dp).size(16.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────
// Stats Bar with Luminize
// ─────────────────────────────────────────────

@Composable
private fun StatsBar(
    wordCount: Int,
    readingTimeMinutes: Int,
    focusSessions: Int,
    onLuminize: () -> Unit,
) {
    val spacing = ResonanceTheme.spacing
    var isLuminizing by remember { mutableStateOf(false) }

    val infiniteTransition = rememberInfiniteTransition(label = "luminize")
    val shimmer by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = FastOutSlowInEasing),
            repeatMode = RepeatMode.Reverse,
        ),
        label = "shimmer"
    )

    LaunchedEffect(isLuminizing) {
        if (isLuminizing) {
            delay(3000)
            isLuminizing = false
        }
    }

    Surface(
        color = MaterialTheme.colorScheme.surface.copy(alpha = 0.95f),
        tonalElevation = 1.dp,
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = spacing.screenPadding, vertical = spacing.md),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
        ) {
            // Word count
            StatChip(
                label = "Words",
                value = "$wordCount",
            )

            // Reading time
            StatChip(
                label = "Read",
                value = "${readingTimeMinutes}m",
            )

            // Focus sessions
            StatChip(
                label = "Focus",
                value = if (focusSessions > 0) "$focusSessions" else "--",
            )

            // Luminize button
            Surface(
                modifier = Modifier
                    .clip(RoundedCornerShape(20.dp))
                    .clickable {
                        isLuminizing = true
                        onLuminize()
                    },
                shape = RoundedCornerShape(20.dp),
                color = if (isLuminizing)
                    ResonanceColors.Gold.copy(alpha = 0.15f + shimmer * 0.1f)
                else
                    ResonanceColors.Gold.copy(alpha = 0.1f),
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 14.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                ) {
                    Icon(
                        Icons.Filled.AutoAwesome,
                        contentDescription = "Luminize Prose",
                        modifier = Modifier
                            .size(16.dp)
                            .graphicsLayer {
                                if (isLuminizing) {
                                    rotationZ = shimmer * 15f
                                    alpha = 0.7f + shimmer * 0.3f
                                }
                            },
                        tint = ResonanceColors.Gold,
                    )
                    Text(
                        text = if (isLuminizing) "Luminizing..." else "Luminize",
                        style = MaterialTheme.typography.labelMedium,
                        color = ResonanceColors.Gold,
                        fontWeight = FontWeight.SemiBold,
                    )
                }
            }
        }
    }
}

@Composable
private fun StatChip(
    label: String,
    value: String,
) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(
            text = value,
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onBackground,
            fontWeight = FontWeight.SemiBold,
        )
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
        )
    }
}

// ─────────────────────────────────────────────
// Sample Content
// ─────────────────────────────────────────────

private fun sampleProseContent(): String = """There is a quality of attention that changes everything. Not the sharp, grasping focus we've been trained to value, but something softer — a spacious awareness that holds without clutching.

In the digital spaces we inhabit, this quality is almost entirely absent. Every notification, every feed refresh, every micro-interaction is designed to narrow our attention, to compress our awareness into a single bright point of reactivity.

But what if technology could do the opposite? What if the tools we use could expand our awareness, could create room for the mind to breathe?

This is the question at the heart of Resonance. Not how do we make people more productive, but how do we help them become more present. Not how do we capture attention, but how do we return it.

The answer begins with spaciousness — the quality of having room. Room between thoughts. Room between actions. Room between one moment and the next. When spaciousness is present, clarity follows naturally. Decisions become easier. Creativity flows without force.

We've encoded this understanding into every layer of the system. The generous whitespace isn't decorative — it's functional. The unhurried transitions aren't slow — they're respectful. The muted palette isn't boring — it's calm."""
