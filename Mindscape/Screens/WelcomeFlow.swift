import SwiftUI

/// Welcome → four onboarding questions. A `NavigationStack` drives the pushes so the
/// back chevron and back-swipe come for free; the last question flips `hasOnboarded`,
/// which hands control to the tab shell.
struct WelcomeFlow: View {
    @Environment(AppModel.self) private var model
    @State private var path: [OnboardingStep] = []

    enum OnboardingStep: Int, Hashable, CaseIterable {
        case reasons = 1, style, challenges, about

        var next: OnboardingStep? { OnboardingStep(rawValue: rawValue + 1) }
    }

    var body: some View {
        NavigationStack(path: $path) {
            // Sign up runs onboarding; logging in is a returning user, so it lands
            // straight on Home.
            WelcomeScreen(onSignUp: { path = [.reasons] },
                          onLogIn: { model.hasOnboarded = true })
                .navigationDestination(for: OnboardingStep.self) { step in
                    OnboardingQuestion(step: step) {
                        if let next = step.next { path.append(next) }
                    }
                }
        }
        .tint(.accentPurple)
    }
}

struct WelcomeScreen: View {
    let onSignUp: () -> Void
    let onLogIn: () -> Void

    var body: some View {
        GeometryReader { proxy in
            // Positions are proportional to the 874pt Figma frame so the composition
            // holds its balance across iPhone sizes.
            let h = proxy.size.height

            VStack(spacing: 0) {
                Spacer(minLength: 0).frame(height: h * 0.33)

                VStack(spacing: 14) {
                    HStack(spacing: 0) {
                        Text("mind").foregroundStyle(.textPrimary)
                        Text("scape").gradientText()
                    }
                    .font(.msWordmark)

                    Text("YOUR MENTAL WELLNESS COMPANION")
                        .msStyle(.msSection, tracking: 0.28)
                        .foregroundStyle(.textMuted)
                }

                Spacer(minLength: 20)

                VStack(spacing: 24) {
                    PrimaryButton(title: "SIGN UP", action: onSignUp)
                    SecondaryButton(title: "LOG IN", action: onLogIn)
                    Text("By continuing, you agree to our Terms.")
                        .msStyle(.msSection, tracking: 0.28)
                        .foregroundStyle(.textMuted)
                }
                .padding(.horizontal, Theme.screenInset)
                .padding(.bottom, h * 0.14)
            }
            .frame(maxWidth: .infinity)
        }
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }
}

/// One onboarding question. All four share the same chrome — progress bar, two-line
/// title, eyebrow, answers, and a Continue button — so they're one view, not four.
struct OnboardingQuestion: View {
    @Environment(AppModel.self) private var model
    let step: WelcomeFlow.OnboardingStep
    let onContinue: () -> Void

    var body: some View {
        @Bindable var model = model

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                StepProgressBar(step: step.rawValue, total: 4)
                    .padding(.bottom, 40)

                ScreenTitle(first: titleFirst, second: titleSecond)
                    .padding(.bottom, 12)

                Text(eyebrow)
                    .msStyle(.msEyebrow, tracking: 0.24)
                    .foregroundStyle(.textMuted)
                    .padding(.bottom, 28)

                answers
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollDismissesKeyboard(.interactively)
        // The CTA is bottom-anchored in every onboarding frame. Pinning it here (rather
        // than inline) keeps it above the keyboard on the "about" step, so it stays
        // tappable while the Age numeric keypad — which has no return key — is up.
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PrimaryButton(title: step == .about ? "Let’s Go" : "Continue",
                          isEnabled: canContinue) {
                dismissKeyboard()
                if step == .about { model.hasOnboarded = true } else { onContinue() }
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, 8)
            // No scrim — the shared background gradient shows through behind the button
            // and continues seamlessly to the device's bottom edge.
        }
        .mindscapeBackground()
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        // Lets the numeric Age keypad be dismissed, since it has no return key.
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done", action: dismissKeyboard)
                    .foregroundStyle(.accentPurple)
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: Per-step content

    private var titleFirst: String {
        switch step {
        case .reasons:    "What brings you"
        case .style:      "What type of journaling"
        case .challenges: "Any current"
        case .about:      "Almost"
        }
    }

    private var titleSecond: String {
        switch step {
        case .reasons:    "here?"
        case .style:      "resonates?"
        case .challenges: "challenges?"
        case .about:      "there..."
        }
    }

    private var eyebrow: String {
        switch step {
        case .reasons:    "SELECT ALL THAT APPLY"
        case .style:      "PICK ONE"
        case .challenges: "THIS HELPS US PERSONALIZE YOUR EXPERIENCE"
        case .about:      "TELL US A BIT ABOUT YOURSELF"
        }
    }

    private var canContinue: Bool {
        switch step {
        case .reasons:    !model.reasons.isEmpty
        case .style:      model.journalingStyle != nil
        case .challenges: !model.challenges.isEmpty
        case .about:      true
        }
    }

    @ViewBuilder
    private var answers: some View {
        @Bindable var model = model

        switch step {
        case .reasons:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(SampleData.reasons, id: \.self) { reason in
                    SelectionChip(title: reason, isSelected: model.reasons.contains(reason)) {
                        toggle(reason, in: &model.reasons)
                    }
                }
            }

        case .style:
            VStack(spacing: 12) {
                ForEach(SampleData.journalingStyles, id: \.title) { option in
                    OptionCard(title: option.title,
                               subtitle: option.subtitle,
                               isSelected: model.journalingStyle == option.title) {
                        model.journalingStyle = option.title
                    }
                }
            }

        case .challenges:
            WrapLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                ForEach(SampleData.challenges, id: \.self) { challenge in
                    SelectionChip(title: challenge, isSelected: model.challenges.contains(challenge)) {
                        toggle(challenge, in: &model.challenges)
                    }
                }
            }

        case .about:
            VStack(alignment: .leading, spacing: 12) {
                FieldLabel(text: "What’s your name?")
                MindscapeTextField(placeholder: "Full Name", text: $model.name)

                FieldLabel(text: "How old are you?")
                    .padding(.top, 12)
                MindscapeTextField(placeholder: "Age", text: $model.age, keyboard: .numberPad)

                FieldLabel(text: "How often would you like prompts?")
                    .padding(.top, 12)
                WrapLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(SampleData.promptFrequencies, id: \.self) { frequency in
                        SelectionChip(title: frequency,
                                      isSelected: model.promptFrequency == frequency) {
                            model.promptFrequency = frequency
                        }
                    }
                }

                healthcareCard.padding(.top, 20)
            }
        }
    }

    private var healthcareCard: some View {
        @Bindable var model = model

        return VStack(alignment: .leading, spacing: 0) {
            Text("Connect with a healthcare provider?")
                .font(.custom(PJS.bold, size: 20, relativeTo: .title3))
                .foregroundStyle(.textPrimary)
                .lineSpacing(6)
                .padding(.bottom, 14)

            Text("Optional. Link your therapist’s account for a more guided experience.")
                .font(.custom(PJS.extraBold, size: 18, relativeTo: .body))
                .foregroundStyle(.textMuted)
                .lineSpacing(4)
                .padding(.bottom, 18)

            CheckboxRow(title: "Skip for now — connect later",
                        isOn: $model.connectProviderLater)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .background {
            let shape = RoundedRectangle(cornerRadius: 28.8)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 2.88)
            }
        }
    }

    private func toggle(_ value: String, in set: inout Set<String>) {
        if set.contains(value) { set.remove(value) } else { set.insert(value) }
    }
}

#Preview("Welcome") {
    WelcomeFlow().environment(AppModel())
}
