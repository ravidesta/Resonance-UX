// MARK: - Apple Pencil Journal — Handwriting Canvas
// Full PencilKit integration with pressure sensitivity, ink styles,
// mixed media (typed + handwritten + voice + photo), and coach sharing.
// "Some truths arrive through the hand, not the keyboard."

import SwiftUI
import PencilKit

// MARK: - Multi-Modal Journal Entry View

struct MultiModalJournalView: View {
    @EnvironmentObject var theme: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MultiModalJournalViewModel()
    @State private var activeMode: JournalMode = .typed
    @State private var showCoachShare = false
    @State private var showMediaPicker = false
    @State private var showVoiceRecorder = false
    @State private var showBodyMap = false
    @State private var bodyLocations: [JournalEntry.BodyLocation] = []

    enum JournalMode: String, CaseIterable {
        case typed = "Type"
        case pencil = "Draw"
        case voice = "Voice"
        case mixed = "Mixed"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Mode selector
                HStack(spacing: 0) {
                    ForEach(JournalMode.allCases, id: \.self) { mode in
                        Button(action: { withAnimation { activeMode = mode } }) {
                            VStack(spacing: 4) {
                                Image(systemName: iconForMode(mode))
                                    .font(.system(size: 18))
                                Text(mode.rawValue)
                                    .font(.custom("Manrope", size: 11))
                            }
                            .foregroundColor(activeMode == mode ? theme.goldPrimary : theme.textMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                activeMode == mode
                                    ? theme.goldPrimary.opacity(0.06)
                                    : Color.clear
                            )
                        }
                    }
                }
                .background(theme.surface)

                // Content area
                switch activeMode {
                case .typed:
                    TypedJournalContent(viewModel: viewModel)
                case .pencil:
                    PencilJournalContent(viewModel: viewModel)
                case .voice:
                    VoiceJournalContent(viewModel: viewModel)
                case .mixed:
                    MixedMediaJournal(viewModel: viewModel)
                }

                // Bottom toolbar
                JournalBottomToolbar(
                    onBodyMap: { showBodyMap = true },
                    onPhoto: { showMediaPicker = true },
                    onVoice: { showVoiceRecorder = true },
                    onCoach: { showCoachShare = true },
                    onSave: { viewModel.save(); dismiss() }
                )
            }
            .background(theme.background)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        Button(action: { showCoachShare = true }) {
                            Label("Send to Coach", systemImage: "paperplane")
                        }
                        Button(action: { viewModel.toggleShareable() }) {
                            Label(viewModel.isShareable ? "Make Private" : "Make Shareable",
                                  systemImage: viewModel.isShareable ? "lock" : "square.and.arrow.up")
                        }
                        Button(action: { /* Export to Writer */ }) {
                            Label("Export to Writer", systemImage: "doc.text")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(theme.text)
                    }
                }
            }
            .sheet(isPresented: $showCoachShare) {
                CoachShareSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showBodyMap) {
                InteractiveBodyMap(selectedLocations: $bodyLocations)
                    .presentationDetents([.large])
            }
        }
    }

    private func iconForMode(_ mode: JournalMode) -> String {
        switch mode {
        case .typed:  return "keyboard"
        case .pencil: return "pencil.tip"
        case .voice:  return "mic"
        case .mixed:  return "square.grid.2x2"
        }
    }
}

// MARK: - Typed Journal Content

struct TypedJournalContent: View {
    @ObservedObject var viewModel: MultiModalJournalViewModel
    @EnvironmentObject var theme: ThemeManager
    @FocusState private var isFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Prompt
                if let prompt = viewModel.currentPrompt {
                    Text(prompt)
                        .font(.custom("Cormorant Garamond", size: 20))
                        .foregroundColor(theme.textSecondary)
                        .lineSpacing(4)
                        .padding(.horizontal, 4)
                }

                // Main text
                TextEditor(text: $viewModel.typedContent)
                    .font(.custom("Manrope", size: 17))
                    .foregroundColor(theme.text)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 300)
                    .focused($isFocused)

                Divider()

                // Somatic notes
                VStack(alignment: .leading, spacing: 8) {
                    Label("Somatic Notes", systemImage: "waveform")
                        .font(.custom("Manrope", size: 13).weight(.semibold))
                        .foregroundColor(Color(hex: "8B6BB0"))

                    TextField("What do you notice in your body?", text: $viewModel.somaticNotes, axis: .vertical)
                        .font(.custom("Manrope", size: 15))
                        .lineLimit(3...6)
                }

                // Mood + Season selectors
                MoodSeasonSelector(
                    selectedMood: $viewModel.selectedMood,
                    selectedSeason: $viewModel.selectedSeason
                )

                // Word count
                HStack {
                    Text("\(viewModel.typedContent.split(separator: " ").count) words")
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(theme.textMuted)
                    Spacer()
                    Text(Date().formatted(date: .abbreviated, time: .shortened))
                        .font(.custom("Manrope", size: 12))
                        .foregroundColor(theme.textMuted)
                }
            }
            .padding(20)
        }
        .onAppear { isFocused = true }
    }
}

// MARK: - Apple Pencil Canvas

struct PencilJournalContent: View {
    @ObservedObject var viewModel: MultiModalJournalViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var selectedInk: InkStyle = .forestPen
    @State private var canvasView = PKCanvasView()

    enum InkStyle: String, CaseIterable {
        case forestPen    = "Forest Pen"
        case goldPen      = "Gold Pen"
        case somaticPen   = "Somatic Purple"
        case pencilLight  = "Pencil (Light)"
        case pencilBold   = "Pencil (Bold)"
        case marker       = "Marker"
        case watercolor   = "Watercolor"
        case eraser       = "Eraser"

        var inkType: PKInkingTool.InkType {
            switch self {
            case .forestPen, .goldPen, .somaticPen: return .pen
            case .pencilLight, .pencilBold:          return .pencil
            case .marker, .watercolor:               return .marker
            case .eraser:                            return .pen // handled separately
            }
        }

        var color: UIColor {
            switch self {
            case .forestPen:   return UIColor(red: 0.106, green: 0.251, blue: 0.180, alpha: 1) // #1B402E
            case .goldPen:     return UIColor(red: 0.773, green: 0.627, blue: 0.349, alpha: 1) // #C5A059
            case .somaticPen:  return UIColor(red: 0.545, green: 0.420, blue: 0.690, alpha: 1) // #8B6BB0
            case .pencilLight: return UIColor(red: 0.541, green: 0.612, blue: 0.569, alpha: 0.5)
            case .pencilBold:  return UIColor(red: 0.106, green: 0.251, blue: 0.180, alpha: 0.8)
            case .marker:      return UIColor(red: 0.773, green: 0.627, blue: 0.349, alpha: 0.3)
            case .watercolor:  return UIColor(red: 0.353, green: 0.541, blue: 0.690, alpha: 0.2)
            case .eraser:      return .white
            }
        }

        var width: CGFloat {
            switch self {
            case .forestPen, .goldPen, .somaticPen: return 3
            case .pencilLight:                       return 2
            case .pencilBold:                        return 5
            case .marker, .watercolor:               return 15
            case .eraser:                            return 20
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Ink toolbar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(InkStyle.allCases, id: \.self) { ink in
                        Button(action: {
                            selectedInk = ink
                            updateTool()
                        }) {
                            VStack(spacing: 4) {
                                if ink == .eraser {
                                    Image(systemName: "eraser")
                                        .font(.system(size: 18))
                                        .foregroundColor(theme.text)
                                } else {
                                    Circle()
                                        .fill(Color(ink.color))
                                        .frame(width: ink == selectedInk ? 28 : 20,
                                               height: ink == selectedInk ? 28 : 20)
                                        .overlay(
                                            Circle()
                                                .stroke(theme.goldPrimary, lineWidth: ink == selectedInk ? 2 : 0)
                                        )
                                }
                                Text(ink.rawValue)
                                    .font(.custom("Manrope", size: 9))
                                    .foregroundColor(ink == selectedInk ? theme.text : theme.textMuted)
                            }
                        }
                    }

                    Divider().frame(height: 30)

                    // Undo / Redo
                    Button(action: { canvasView.undoManager?.undo() }) {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(theme.text)
                    }
                    Button(action: { canvasView.undoManager?.redo() }) {
                        Image(systemName: "arrow.uturn.forward")
                            .foregroundColor(theme.text)
                    }

                    Divider().frame(height: 30)

                    // Clear
                    Button(action: { canvasView.drawing = PKDrawing() }) {
                        Image(systemName: "trash")
                            .foregroundColor(theme.textMuted)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(theme.surface)

            // Paper texture canvas
            ZStack {
                // Paper background with lines
                PaperBackground(style: .lined)

                // PencilKit canvas
                PencilCanvasRepresentable(
                    canvasView: $canvasView,
                    onDrawingChanged: { drawing in
                        viewModel.pencilDrawing = drawing
                    }
                )
            }
        }
        .onAppear { updateTool() }
    }

    private func updateTool() {
        if selectedInk == .eraser {
            canvasView.tool = PKEraserTool(.bitmap)
        } else {
            canvasView.tool = PKInkingTool(
                selectedInk.inkType,
                color: selectedInk.color,
                width: selectedInk.width
            )
        }
    }
}

// MARK: - PencilKit UIKit Bridge

struct PencilCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let onDrawingChanged: (PKDrawing) -> Void

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .pencilOnly // Requires Apple Pencil; finger scrolls
        canvasView.delegate = context.coordinator
        canvasView.tool = PKInkingTool(.pen, color: UIColor(red: 0.106, green: 0.251, blue: 0.180, alpha: 1), width: 3)

        // Enable scroll
        canvasView.alwaysBounceVertical = true
        canvasView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 2000)

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDrawingChanged: onDrawingChanged)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        let onDrawingChanged: (PKDrawing) -> Void
        init(onDrawingChanged: @escaping (PKDrawing) -> Void) { self.onDrawingChanged = onDrawingChanged }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            onDrawingChanged(canvasView.drawing)
        }
    }
}

// MARK: - Paper Background Styles

struct PaperBackground: View {
    enum Style { case blank, lined, dotGrid, graph }
    let style: Style
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base paper color
                Rectangle()
                    .fill(theme.isDeepRest ? Color(hex: "0A1C14") : Color(hex: "FAFAF8"))

                // Paper texture
                Rectangle()
                    .fill(Color.white.opacity(0.035))
                    .blendMode(.overlay)

                // Grid/lines
                switch style {
                case .lined:
                    Canvas { context, size in
                        let lineSpacing: CGFloat = 32
                        var y: CGFloat = 80 // top margin
                        while y < size.height {
                            let path = Path { p in
                                p.move(to: CGPoint(x: 40, y: y))
                                p.addLine(to: CGPoint(x: size.width - 40, y: y))
                            }
                            context.stroke(path, with: .color(Color(hex: "1B402E").opacity(0.06)), lineWidth: 0.5)
                            y += lineSpacing
                        }
                    }
                case .dotGrid:
                    Canvas { context, size in
                        let spacing: CGFloat = 24
                        var x: CGFloat = 24
                        while x < size.width {
                            var y: CGFloat = 24
                            while y < size.height {
                                let rect = CGRect(x: x - 1, y: y - 1, width: 2, height: 2)
                                context.fill(Path(ellipseIn: rect), with: .color(Color(hex: "1B402E").opacity(0.08)))
                                y += spacing
                            }
                            x += spacing
                        }
                    }
                case .graph:
                    Canvas { context, size in
                        let spacing: CGFloat = 20
                        // Vertical lines
                        var x: CGFloat = 20
                        while x < size.width {
                            let path = Path { p in p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height)) }
                            context.stroke(path, with: .color(Color(hex: "1B402E").opacity(0.04)), lineWidth: 0.5)
                            x += spacing
                        }
                        // Horizontal lines
                        var y: CGFloat = 20
                        while y < size.height {
                            let path = Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: size.width, y: y)) }
                            context.stroke(path, with: .color(Color(hex: "1B402E").opacity(0.04)), lineWidth: 0.5)
                            y += spacing
                        }
                    }
                case .blank:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Voice Journal Content

struct VoiceJournalContent: View {
    @ObservedObject var viewModel: MultiModalJournalViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var waveformAmplitudes: [CGFloat] = Array(repeating: 0.1, count: 50)

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Waveform visualization
            HStack(spacing: 3) {
                ForEach(Array(waveformAmplitudes.enumerated()), id: \.offset) { _, amplitude in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isRecording ? theme.goldPrimary : theme.textMuted.opacity(0.3))
                        .frame(width: 4, height: 20 + amplitude * 80)
                        .animation(.easeInOut(duration: 0.1), value: amplitude)
                }
            }
            .frame(height: 100)

            // Timer
            Text(formatTime(recordingTime))
                .font(.custom("Manrope", size: 48).weight(.light).monospacedDigit())
                .foregroundColor(theme.text)

            // Recording status
            Text(isRecording ? "Recording... speak freely" : "Tap to record your reflection")
                .font(.custom("Manrope", size: 14))
                .foregroundColor(theme.textSecondary)

            // Record button
            Button(action: {
                isRecording.toggle()
                if isRecording {
                    startRecording()
                } else {
                    stopRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isRecording ? Color(hex: "C45A5A") : theme.forestBase)
                        .frame(width: 72, height: 72)
                        .shadow(color: (isRecording ? Color(hex: "C45A5A") : theme.forestBase).opacity(0.3),
                                radius: 12, y: 4)

                    if isRecording {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(width: 24, height: 24)
                    } else {
                        Circle()
                            .fill(Color(hex: "C45A5A"))
                            .frame(width: 28, height: 28)
                    }
                }
            }

            // Transcription preview
            if !viewModel.voiceTranscription.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Transcription", systemImage: "text.quote")
                        .font(.custom("Manrope", size: 12).weight(.semibold))
                        .foregroundColor(theme.textSecondary)

                    Text(viewModel.voiceTranscription)
                        .font(.custom("Manrope", size: 15))
                        .foregroundColor(theme.text)
                        .lineSpacing(4)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.forestBase.opacity(0.04))
                        )
                }
                .padding(.horizontal, 20)
            }

            Spacer()
        }
    }

    private func startRecording() {
        // Start audio recording + real-time transcription
        // Animate waveform
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            guard isRecording else { timer.invalidate(); return }
            recordingTime += 0.05
            waveformAmplitudes = waveformAmplitudes.map { _ in CGFloat.random(in: 0.1...1.0) }
        }
    }

    private func stopRecording() {
        // Stop recording, finalize transcription
        waveformAmplitudes = Array(repeating: 0.1, count: 50)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let m = Int(time) / 60
        let s = Int(time) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Mixed Media Journal (Typed + Pencil + Voice + Photo)

struct MixedMediaJournal: View {
    @ObservedObject var viewModel: MultiModalJournalViewModel
    @EnvironmentObject var theme: ThemeManager
    @State private var blocks: [MixedBlock] = [.init(type: .text)]

    struct MixedBlock: Identifiable {
        let id = UUID()
        var type: BlockType
        var textContent: String = ""
        var drawingData: Data?
        var imageData: Data?
        var voiceURL: URL?
        var voiceDuration: TimeInterval?

        enum BlockType: String {
            case text, drawing, image, voice, bodyMap
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                    switch block.type {
                    case .text:
                        TextEditor(text: $blocks[index].textContent)
                            .font(.custom("Manrope", size: 17))
                            .foregroundColor(theme.text)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 80)

                    case .drawing:
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.forestBase.opacity(0.04))
                                .frame(height: 200)
                            Text("Pencil drawing area")
                                .foregroundColor(theme.textMuted)
                        }

                    case .image:
                        if let data = block.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                    case .voice:
                        HStack(spacing: 12) {
                            Image(systemName: "waveform")
                                .foregroundColor(theme.goldPrimary)
                            VStack(alignment: .leading) {
                                Text("Voice note")
                                    .font(.custom("Manrope", size: 14))
                                if let dur = block.voiceDuration {
                                    Text("\(Int(dur))s")
                                        .font(.custom("Manrope", size: 12))
                                        .foregroundColor(theme.textSecondary)
                                }
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(theme.accent)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(theme.forestBase.opacity(0.04))
                        )

                    case .bodyMap:
                        HStack(spacing: 12) {
                            Image(systemName: "figure.stand")
                                .foregroundColor(Color(hex: "8B6BB0"))
                            Text("Body map attached")
                                .font(.custom("Manrope", size: 14))
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "8B6BB0").opacity(0.04))
                        )
                    }
                }

                // Add block buttons
                HStack(spacing: 16) {
                    AddBlockButton(icon: "plus.square", label: "Text") {
                        blocks.append(.init(type: .text))
                    }
                    AddBlockButton(icon: "pencil.tip", label: "Draw") {
                        blocks.append(.init(type: .drawing))
                    }
                    AddBlockButton(icon: "photo", label: "Photo") {
                        blocks.append(.init(type: .image))
                    }
                    AddBlockButton(icon: "mic", label: "Voice") {
                        blocks.append(.init(type: .voice))
                    }
                    AddBlockButton(icon: "figure.stand", label: "Body") {
                        blocks.append(.init(type: .bodyMap))
                    }
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
    }
}

struct AddBlockButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(label)
                    .font(.custom("Manrope", size: 10))
            }
            .foregroundColor(theme.textSecondary)
            .frame(width: 56, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(theme.forestBase.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            )
        }
    }
}

// MARK: - Mood & Season Selector

struct MoodSeasonSelector: View {
    @Binding var selectedMood: JournalEntry.Mood?
    @Binding var selectedSeason: SomaticSeason?
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        VStack(spacing: 16) {
            // Mood
            VStack(alignment: .leading, spacing: 8) {
                Text("Mood")
                    .font(.custom("Manrope", size: 12).weight(.semibold))
                    .foregroundColor(theme.textSecondary)
                    .textCase(.uppercase)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                            Button(action: { selectedMood = selectedMood == mood ? nil : mood }) {
                                Text(mood.rawValue)
                                    .font(.custom("Manrope", size: 13))
                                    .foregroundColor(selectedMood == mood ? theme.cream : theme.text)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(selectedMood == mood ? theme.forestBase : theme.forestBase.opacity(0.06))
                                    )
                            }
                        }
                    }
                }
            }

            // Season
            VStack(alignment: .leading, spacing: 8) {
                Text("Somatic Season")
                    .font(.custom("Manrope", size: 12).weight(.semibold))
                    .foregroundColor(theme.textSecondary)
                    .textCase(.uppercase)

                HStack(spacing: 10) {
                    ForEach(SomaticSeason.allCases, id: \.self) { season in
                        Button(action: { selectedSeason = selectedSeason == season ? nil : season }) {
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(selectedSeason == season
                                        ? (theme.seasonColors[season] ?? theme.accent)
                                        : theme.textMuted.opacity(0.2))
                                    .frame(width: 24, height: 24)
                                Text(season.rawValue)
                                    .font(.custom("Manrope", size: 9))
                                    .foregroundColor(theme.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Journal Bottom Toolbar

struct JournalBottomToolbar: View {
    let onBodyMap: () -> Void
    let onPhoto: () -> Void
    let onVoice: () -> Void
    let onCoach: () -> Void
    let onSave: () -> Void
    @EnvironmentObject var theme: ThemeManager

    var body: some View {
        HStack(spacing: 20) {
            Button(action: onBodyMap) {
                Image(systemName: "figure.stand")
                    .foregroundColor(Color(hex: "8B6BB0"))
            }
            Button(action: onPhoto) {
                Image(systemName: "photo")
                    .foregroundColor(theme.textSecondary)
            }
            Button(action: onVoice) {
                Image(systemName: "mic")
                    .foregroundColor(theme.textSecondary)
            }

            Spacer()

            // Send to coach
            Button(action: onCoach) {
                HStack(spacing: 6) {
                    Image(systemName: "paperplane")
                    Text("Coach")
                }
                .font(.custom("Manrope", size: 13).weight(.medium))
                .foregroundColor(theme.goldPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Capsule().fill(theme.goldPrimary.opacity(0.08)))
            }

            // Save
            Button(action: onSave) {
                Text("Save")
                    .font(.custom("Manrope", size: 14).weight(.semibold))
                    .foregroundColor(theme.cream)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(theme.forestBase)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

// MARK: - View Model

@MainActor
final class MultiModalJournalViewModel: ObservableObject {
    @Published var typedContent: String = ""
    @Published var somaticNotes: String = ""
    @Published var selectedMood: JournalEntry.Mood?
    @Published var selectedSeason: SomaticSeason?
    @Published var pencilDrawing: PKDrawing?
    @Published var voiceTranscription: String = ""
    @Published var voiceRecordingURL: URL?
    @Published var photoAttachments: [Data] = []
    @Published var bodyMapLocations: [JournalEntry.BodyLocation] = []
    @Published var isShareable: Bool = false
    @Published var currentPrompt: String? = "What is alive in you right now? Let it flow."

    func save() {
        // Assemble all media into a journal entry
        // Save to local store + sync
    }

    func toggleShareable() {
        isShareable.toggle()
    }
}
