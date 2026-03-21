// OnboardingFlowView.swift
// Haute Lumière — Onboarding Experience

import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coachEngine: CoachEngine
    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName: String = ""
    @State private var selectedCoach: CoachPersona = .avaAzure
    @State private var selectedGoals: Set<WellnessGoal> = []
    @State private var experienceLevel: ExperienceLevel = .beginner
    @State private var preferredTime: TimeOfDay = .morning
    @State private var animateIn = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case name
        case coachSelection
        case goals
        case experience
        case schedule
        case complete
    }

    var body: some View {
        ZStack {
            // Background
            LumièreGradient(colors: [.hlGreen900, .hlGreen800, .hlGreen700])

            VStack(spacing: 0) {
                // Progress
                if currentStep != .welcome && currentStep != .complete {
                    OnboardingProgressBar(
                        current: currentStep.rawValue,
                        total: OnboardingStep.allCases.count - 2
                    )
                    .padding(.horizontal, HLSpacing.lg)
                    .padding(.top, HLSpacing.md)
                }

                // Content
                TabView(selection: $currentStep) {
                    welcomeView.tag(OnboardingStep.welcome)
                    nameView.tag(OnboardingStep.name)
                    coachSelectionView.tag(OnboardingStep.coachSelection)
                    goalsView.tag(OnboardingStep.goals)
                    experienceView.tag(OnboardingStep.experience)
                    scheduleView.tag(OnboardingStep.schedule)
                    completeView.tag(OnboardingStep.complete)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentStep)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animateIn = true
            }
        }
    }

    // MARK: - Welcome
    private var welcomeView: some View {
        VStack(spacing: HLSpacing.xxl) {
            Spacer()

            VStack(spacing: HLSpacing.lg) {
                // Logo
                Image(systemName: "light.max")
                    .font(.system(size: 60, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(colors: [.hlGold, .hlGoldLight], startPoint: .top, endPoint: .bottom)
                    )
                    .opacity(animateIn ? 1 : 0)
                    .scaleEffect(animateIn ? 1 : 0.8)

                Text("Haute Lumière")
                    .font(HLTypography.heroTitle)
                    .foregroundColor(.hlGoldLight)
                    .opacity(animateIn ? 1 : 0)

                Text("Illuminate Your Inner Landscape")
                    .font(HLTypography.sansLight(16))
                    .foregroundColor(.hlNightText.opacity(0.7))
                    .opacity(animateIn ? 1 : 0)
            }

            Spacer()

            VStack(spacing: HLSpacing.md) {
                Button(action: { withAnimation { currentStep = .name } }) {
                    Text("Begin Your Journey")
                        .font(HLTypography.sansMedium(16))
                        .foregroundColor(.hlGreen900)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, HLSpacing.md)
                        .background(
                            LinearGradient(colors: [.hlGold, .hlGoldLight], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
                }

                Text("7-day complimentary experience included")
                    .font(HLTypography.caption)
                    .foregroundColor(.hlNightTextMuted)
            }
            .padding(.horizontal, HLSpacing.xl)
            .padding(.bottom, HLSpacing.xxl)
        }
    }

    // MARK: - Name
    private var nameView: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            VStack(spacing: HLSpacing.md) {
                Text("What shall we call you?")
                    .font(HLTypography.screenTitle)
                    .foregroundColor(.hlGoldLight)

                Text("Your coach will greet you by name")
                    .font(HLTypography.body)
                    .foregroundColor(.hlNightTextMuted)
            }

            TextField("", text: $userName, prompt: Text("Your first name").foregroundColor(.hlNightTextMuted))
                .font(HLTypography.serifMedium(28))
                .foregroundColor(.hlGoldLight)
                .multilineTextAlignment(.center)
                .padding(.vertical, HLSpacing.md)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.hlGold.opacity(0.3)),
                    alignment: .bottom
                )
                .padding(.horizontal, HLSpacing.xxl)

            Spacer()

            nextButton(enabled: !userName.isEmpty) {
                appState.userName = userName
                coachEngine.userName = userName
                currentStep = .coachSelection
            }
        }
    }

    // MARK: - Coach Selection
    private var coachSelectionView: some View {
        VStack(spacing: HLSpacing.xl) {
            VStack(spacing: HLSpacing.sm) {
                Text("Choose Your Guide")
                    .font(HLTypography.screenTitle)
                    .foregroundColor(.hlGoldLight)

                Text("You can change your coach anytime")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
            }
            .padding(.top, HLSpacing.xl)

            VStack(spacing: HLSpacing.md) {
                ForEach(CoachPersona.allCases) { coach in
                    CoachSelectionCard(
                        coach: coach,
                        isSelected: selectedCoach == coach,
                        onTap: { selectedCoach = coach }
                    )
                }
            }
            .padding(.horizontal, HLSpacing.lg)

            Spacer()

            nextButton(enabled: true) {
                appState.selectedCoach = selectedCoach
                coachEngine.currentPersona = selectedCoach
                currentStep = .goals
            }
        }
    }

    // MARK: - Goals
    private var goalsView: some View {
        VStack(spacing: HLSpacing.xl) {
            VStack(spacing: HLSpacing.sm) {
                Text("What draws you here?")
                    .font(HLTypography.screenTitle)
                    .foregroundColor(.hlGoldLight)

                Text("Select all that resonate")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
            }
            .padding(.top, HLSpacing.xl)

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HLSpacing.sm) {
                    ForEach(WellnessGoal.allCases, id: \.self) { goal in
                        GoalChip(
                            goal: goal,
                            isSelected: selectedGoals.contains(goal),
                            onTap: {
                                if selectedGoals.contains(goal) {
                                    selectedGoals.remove(goal)
                                } else {
                                    selectedGoals.insert(goal)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, HLSpacing.lg)
            }

            nextButton(enabled: !selectedGoals.isEmpty) {
                currentStep = .experience
            }
        }
    }

    // MARK: - Experience
    private var experienceView: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            VStack(spacing: HLSpacing.md) {
                Text("Your experience level")
                    .font(HLTypography.screenTitle)
                    .foregroundColor(.hlGoldLight)

                Text("We'll tailor your journey accordingly")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
            }

            VStack(spacing: HLSpacing.md) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Button(action: { experienceLevel = level }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.rawValue)
                                    .font(HLTypography.sansMedium(16))
                                Text(experienceDescription(level))
                                    .font(HLTypography.bodySmall)
                                    .opacity(0.7)
                            }
                            Spacer()
                            if experienceLevel == level {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.hlGold)
                            }
                        }
                        .foregroundColor(.hlNightText)
                        .padding(HLSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.md)
                                .fill(experienceLevel == level ? Color.hlGold.opacity(0.15) : Color.white.opacity(0.05))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: HLRadius.md)
                                .stroke(experienceLevel == level ? Color.hlGold.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, HLSpacing.lg)

            Spacer()

            nextButton(enabled: true) {
                currentStep = .schedule
            }
        }
    }

    // MARK: - Schedule
    private var scheduleView: some View {
        VStack(spacing: HLSpacing.xl) {
            Spacer()

            VStack(spacing: HLSpacing.md) {
                Text("When do you practice?")
                    .font(HLTypography.screenTitle)
                    .foregroundColor(.hlGoldLight)

                Text("We'll send gentle reminders")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
            }

            VStack(spacing: HLSpacing.sm) {
                ForEach(TimeOfDay.allCases, id: \.self) { time in
                    Button(action: { preferredTime = time }) {
                        HStack {
                            Image(systemName: timeIcon(time))
                                .foregroundColor(.hlGold)
                            Text(time.rawValue)
                                .font(HLTypography.sansMedium(15))
                            Spacer()
                            if preferredTime == time {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.hlGold)
                            }
                        }
                        .foregroundColor(.hlNightText)
                        .padding(HLSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: HLRadius.md)
                                .fill(preferredTime == time ? Color.hlGold.opacity(0.15) : Color.white.opacity(0.05))
                        )
                    }
                }
            }
            .padding(.horizontal, HLSpacing.lg)

            Spacer()

            nextButton(enabled: true) {
                currentStep = .complete
            }
        }
    }

    // MARK: - Complete
    private var completeView: some View {
        VStack(spacing: HLSpacing.xxl) {
            Spacer()

            VStack(spacing: HLSpacing.lg) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50, weight: .ultraLight))
                    .foregroundColor(.hlGold)

                Text("Welcome, \(userName)")
                    .font(HLTypography.heroTitle)
                    .foregroundColor(.hlGoldLight)

                Text("\(selectedCoach.displayName) is ready to guide you")
                    .font(HLTypography.body)
                    .foregroundColor(.hlNightTextMuted)

                Text("Your 7-day complimentary experience begins now")
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted.opacity(0.7))
            }

            Spacer()

            Button(action: {
                hasCompletedOnboarding = true
            }) {
                Text("Enter Haute Lumière")
                    .font(HLTypography.sansMedium(16))
                    .foregroundColor(.hlGreen900)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, HLSpacing.md)
                    .background(
                        LinearGradient(colors: [.hlGold, .hlGoldLight], startPoint: .leading, endPoint: .trailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
            }
            .padding(.horizontal, HLSpacing.xl)
            .padding(.bottom, HLSpacing.xxl)
        }
    }

    // MARK: - Helpers
    private func nextButton(enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.4)) { action() } }) {
            HStack {
                Text("Continue")
                    .font(HLTypography.sansMedium(15))
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(enabled ? .hlGreen900 : .hlNightTextMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(enabled ? Color.hlGold : Color.white.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: HLRadius.pill))
        }
        .disabled(!enabled)
        .padding(.horizontal, HLSpacing.xl)
        .padding(.bottom, HLSpacing.xxl)
    }

    private func experienceDescription(_ level: ExperienceLevel) -> String {
        switch level {
        case .beginner: return "New to meditation and breathwork"
        case .intermediate: return "Some experience with regular practice"
        case .advanced: return "Experienced practitioner seeking depth"
        }
    }

    private func timeIcon(_ time: TimeOfDay) -> String {
        switch time {
        case .earlyMorning: return "sunrise"
        case .morning: return "sun.and.horizon"
        case .afternoon: return "sun.max"
        case .evening: return "sunset"
        case .lateNight: return "moon.stars"
        }
    }
}

// MARK: - Supporting Views
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1..<total + 1, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= current ? Color.hlGold : Color.white.opacity(0.15))
                    .frame(height: 3)
            }
        }
    }
}

struct CoachSelectionCard: View {
    let coach: CoachPersona
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: HLSpacing.md) {
                HStack(spacing: HLSpacing.md) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: coach.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 56, height: 56)
                        Image(systemName: coach.avatarSymbol)
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(coach.displayName)
                            .font(HLTypography.sansSemibold(18))
                            .foregroundColor(.hlNightText)
                        Text(coach.title)
                            .font(HLTypography.bodySmall)
                            .foregroundColor(.hlNightTextMuted)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.hlGold)
                            .font(.system(size: 24))
                    }
                }

                Text(coach.shortBio)
                    .font(HLTypography.bodySmall)
                    .foregroundColor(.hlNightTextMuted)
                    .lineLimit(3)

                HStack(spacing: HLSpacing.sm) {
                    Label(coach.voiceDescription, systemImage: "waveform")
                        .font(HLTypography.caption)
                        .foregroundColor(coach.accentColor)
                }
            }
            .padding(HLSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .fill(isSelected ? Color.hlGold.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: HLRadius.lg)
                    .stroke(isSelected ? Color.hlGold.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct GoalChip: View {
    let goal: WellnessGoal
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(goal.rawValue)
                .font(HLTypography.label)
                .foregroundColor(isSelected ? .hlGreen900 : .hlNightText)
                .padding(.horizontal, HLSpacing.md)
                .padding(.vertical, HLSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: HLRadius.pill)
                        .fill(isSelected ? Color.hlGold : Color.white.opacity(0.08))
                )
        }
    }
}
