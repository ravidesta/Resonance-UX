// CommandLineView.swift
// Resonance UX GitHub Backup — CLI Interface
// Server commands as file menu options with integrated terminal

import SwiftUI

struct CommandLineView: View {
    @EnvironmentObject var viewModel: BackupViewModel
    @State private var commandInput = ""
    @State private var commandHistory: [CommandResult] = []
    @State private var selectedCategory: ServerCommand.CommandCategory?
    @State private var showCommandPalette = false
    @FocusState private var inputFocused: Bool

    var filteredCommands: [ServerCommand] {
        if let category = selectedCategory {
            return ServerCommand.defaultCommands.filter { $0.category == category }
        }
        return ServerCommand.defaultCommands
    }

    var body: some View {
        HSplitView {
            // Left: Command Menu
            commandMenuPanel

            // Right: Terminal
            terminalPanel
        }
    }

    // MARK: - Command Menu Panel

    var commandMenuPanel: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text("SERVER COMMANDS")
                    .font(ResonanceTypography.callsignFont)
                    .foregroundColor(ResonanceColors.goldPrimary)
                    .tracking(2)
                Text("File Menu")
                    .font(ResonanceTypography.headingSystem)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ResonanceSpacing.md)

            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    categoryChip("All", category: nil)
                    ForEach(ServerCommand.CommandCategory.allCases, id: \.self) { cat in
                        categoryChip(cat.rawValue, category: cat)
                    }
                }
                .padding(.horizontal, ResonanceSpacing.md)
            }
            .padding(.bottom, ResonanceSpacing.sm)

            // Command list
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(filteredCommands) { cmd in
                        commandRow(cmd)
                    }
                }
                .padding(.horizontal, ResonanceSpacing.sm)
            }
        }
        .frame(minWidth: 280, maxWidth: 350)
        .background(.ultraThinMaterial)
    }

    func categoryChip(_ title: String, category: ServerCommand.CommandCategory?) -> some View {
        Button(action: { selectedCategory = category }) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(selectedCategory == category ? ResonanceColors.goldPrimary.opacity(0.2) : Color.clear)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(ResonanceColors.borderLight, lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    func commandRow(_ cmd: ServerCommand) -> some View {
        Button(action: { executeServerCommand(cmd) }) {
            HStack(spacing: ResonanceSpacing.sm) {
                Image(systemName: cmd.icon)
                    .frame(width: 20)
                    .foregroundColor(
                        cmd.isDestructive ? ResonanceColors.rhythmCoral : ResonanceColors.growthGreen
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(cmd.name)
                        .font(ResonanceTypography.bodySystem)
                        .foregroundColor(ResonanceColors.textMain)
                    Text(cmd.description)
                        .font(.system(size: 10))
                        .foregroundColor(ResonanceColors.textLight)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "play.fill")
                    .font(.system(size: 8))
                    .foregroundColor(ResonanceColors.textLight)
            }
            .padding(.horizontal, ResonanceSpacing.sm)
            .padding(.vertical, 6)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Terminal Panel

    var terminalPanel: some View {
        VStack(spacing: 0) {
            // Terminal header
            HStack {
                HStack(spacing: 6) {
                    ChromaticOrb(color: ResonanceColors.growthGreen, size: 6, pulse: true)
                    Text("RESONANCE TERMINAL")
                        .font(ResonanceTypography.callsignFont)
                        .foregroundColor(ResonanceColors.growthGreen)
                        .tracking(1)
                }

                Spacer()

                Button(action: { commandHistory.removeAll() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(ResonanceColors.textMuted)
                }
                .buttonStyle(.plain)
            }
            .padding(ResonanceSpacing.sm)
            .background(ResonanceColors.bgDeep)

            // Output area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: ResonanceSpacing.sm) {
                        // Welcome message
                        Group {
                            Text("╔══════════════════════════════════════════╗")
                            Text("║   RESONANCE BACKUP — Command Interface  ║")
                            Text("║   Kopia + GitHub Integration Terminal    ║")
                            Text("╚══════════════════════════════════════════╝")
                            Text("")
                            Text("Type a command or use the menu on the left.")
                            Text("Type 'help' for available commands.")
                            Text("")
                        }
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(ResonanceColors.growthGreen.opacity(0.7))

                        ForEach(commandHistory) { result in
                            commandOutputBlock(result)
                                .id(result.id)
                        }
                    }
                    .padding(ResonanceSpacing.md)
                }
                .onChange(of: commandHistory.count) { _, _ in
                    if let last = commandHistory.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .background(ResonanceColors.bgDeep)

            // Input line
            HStack(spacing: ResonanceSpacing.sm) {
                Text("resonance >")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(ResonanceColors.goldPrimary)

                TextField("", text: $commandInput)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(ResonanceColors.growthGreen)
                    .focused($inputFocused)
                    .onSubmit { executeCustomCommand() }

                Button(action: { executeCustomCommand() }) {
                    Image(systemName: "return")
                        .foregroundColor(ResonanceColors.goldPrimary)
                }
                .buttonStyle(.plain)
            }
            .padding(ResonanceSpacing.sm)
            .background(ResonanceColors.bgDeep)
        }
    }

    func commandOutputBlock(_ result: CommandResult) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("$")
                    .foregroundColor(ResonanceColors.goldPrimary)
                Text(result.command)
                    .foregroundColor(ResonanceColors.growthGreen)
                Spacer()
                Text(result.timestamp.formatted(.dateTime.hour().minute().second()))
                    .foregroundColor(ResonanceColors.textLight.opacity(0.5))
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))

            Text(result.output)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(
                    result.isSuccess
                        ? Color.white.opacity(0.8)
                        : ResonanceColors.rhythmCoral
                )
                .textSelection(.enabled)

            HStack {
                Circle()
                    .fill(result.isSuccess ? ResonanceColors.growthGreen : ResonanceColors.rhythmCoral)
                    .frame(width: 4, height: 4)
                Text(result.isSuccess ? "exit 0" : "exit \(result.exitCode)")
                    .foregroundColor(ResonanceColors.textLight.opacity(0.4))
            }
            .font(.system(size: 9, design: .monospaced))

            Divider().opacity(0.1)
        }
    }

    // MARK: - Actions

    func executeServerCommand(_ cmd: ServerCommand) {
        commandInput = cmd.command
        executeCustomCommand()
    }

    func executeCustomCommand() {
        let input = commandInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty else { return }
        commandInput = ""

        // Handle built-in commands
        if input == "help" {
            let helpText = ServerCommand.defaultCommands.map { cmd in
                "  \(cmd.name.padding(toLength: 20, withPad: " ", startingAt: 0)) \(cmd.command)"
            }.joined(separator: "\n")

            commandHistory.append(CommandResult(
                command: "help",
                output: "Available commands:\n\n\(helpText)\n\nOr type any shell command directly.",
                exitCode: 0,
                timestamp: Date()
            ))
            return
        }

        if input == "status" {
            let portfolios = viewModel.portfolios
            let synced = portfolios.filter { $0.backupStatus == .synced }.count
            let output = """
            Resonance Backup Status
            ═══════════════════════
            Portfolios: \(portfolios.count)
            Synced:     \(synced)/\(portfolios.count)
            Backend:    \(viewModel.kopiaConfig.storageBackend.displayName)
            Schedule:   Every \(viewModel.kopiaConfig.scheduling.intervalHours)h
            """
            commandHistory.append(CommandResult(
                command: input, output: output, exitCode: 0, timestamp: Date()
            ))
            return
        }

        // Execute via service
        Task {
            let components = input.components(separatedBy: " ")
            let cmd = components.first ?? ""
            let args = Array(components.dropFirst())

            let result = await viewModel.backupService.executeCommand(cmd, arguments: args)
            await MainActor.run {
                commandHistory.append(result)
            }
        }
    }
}
