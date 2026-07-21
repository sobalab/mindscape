import SwiftUI

/// `navy-panel-fill` card — the reflection rows, entry rows, and settings groups.
/// A horizontal navy gradient behind a 2pt teal hairline, radius 25.
struct PanelCard<Content: View>: View {
    var strokeColor: Color = .tealStroke
    var strokeWidth: CGFloat = 2
    var cornerRadius: CGFloat = Theme.cardRadius
    @ViewBuilder var content: Content

    var body: some View {
        content.background {
            let shape = RoundedRectangle(cornerRadius: cornerRadius)
            shape.fill(Theme.panel).overlay {
                shape.strokeBorder(strokeColor, lineWidth: strokeWidth)
            }
        }
    }
}

/// The violet prompt card on Home and Insights — flat `tag-bg-unactive` fill with a
/// heavier 3pt border, distinct from the navy panels.
struct PromptCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content.background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
            }
        }
    }
}

/// The AI reflection prompt card, shared by Home and the composer so a completed prompt
/// reads the same in both places. When answered it gains a teal check and, on Home,
/// swaps its "Answer Prompt" button for an "Answered" state.
struct AIPromptCard: View {
    let text: String
    var isAnswered: Bool = false
    /// Provided on Home (shows the action button); omitted in the composer, which just
    /// displays the prompt above its own Save button.
    var onAnswer: (() -> Void)? = nil

    var body: some View {
        PromptCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Badge(text: "BASED ON YOUR JOURNALS")
                    Spacer()
                    if isAnswered {
                        Image("CheckCircle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .accessibilityLabel("Answered")
                    }
                }
                .padding(.bottom, 18)

                Text(text)
                    .font(.msPrompt)
                    .foregroundStyle(.textPrimary)
                    .lineSpacing(1)
                    .fixedSize(horizontal: false, vertical: true)

                if let onAnswer {
                    Group {
                        if isAnswered {
                            answeredPill
                        } else {
                            PrimaryButton(title: "Answer Prompt", showsArrow: true, action: onAnswer)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 12)   // card button is 300pt inside a 352pt card
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
    }

    /// The done state of the action row — teal, non-interactive.
    private var answeredPill: some View {
        HStack(spacing: 8) {
            Image("CheckCircle").resizable().frame(width: 22, height: 22)
            Text("Answered").font(.msButton)
        }
        .foregroundStyle(Color.accentCyan)
        .frame(maxWidth: .infinity)
        .frame(height: 53)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.pillRadius)
            shape.fill(Color.observationBg).overlay {
                shape.strokeBorder(.tealStroke, lineWidth: 2)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Prompt answered")
    }
}

/// Two-line screen title: first line in plain text, second painted with `text-linear`.
/// Used on Home, every onboarding question, Journal, Insights, and Settings.
struct ScreenTitle: View {
    let first: String
    let second: String

    var body: some View {
        // Figma sets the two baselines 35pt apart on a 30pt face (leading 100%), which is
        // tighter than SwiftUI's default line box — hence the negative stack spacing.
        VStack(alignment: .leading, spacing: -3) {
            Text(first)
                .font(.msTitle)
                .foregroundStyle(.textPrimary)
            Text(second)
                .font(.msTitle)
                .gradientText()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(first) \(second)")
    }
}

/// Uppercase section label, optionally with a trailing action on the right.
struct SectionHeader<Trailing: View>: View {
    let title: String
    var color: Color = .white
    @ViewBuilder var trailing: Trailing

    var body: some View {
        HStack {
            Text(title)
                .msStyle(.msSection, tracking: 0.28)
                .foregroundStyle(color)
            Spacer()
            trailing
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String, color: Color = .white) {
        self.init(title: title, color: color) { EmptyView() }
    }
}

/// The gradient initials chip in the Home header and on the Profile screen.
struct AvatarBadge: View {
    let initials: String
    var size: CGFloat = 50

    var body: some View {
        Text(initials)
            .font(.custom(PJS.extraBold, size: size * 0.28, relativeTo: .subheadline))
            .foregroundStyle(.textPrimary)
            .frame(width: size, height: size)
            .background(Theme.avatar, in: .circle)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        ScreenTitle(first: "Find your", second: "inner calm")
        SectionHeader("RECENT REFLECTION")
        SectionHeader(title: "AI PROMPTS FOR YOU", color: .accentCyan) {
            Text("History")
                .msStyle(.msSection, tracking: 0.28)
                .foregroundStyle(.accentPurple)
        }
        PanelCard { Color.clear.frame(height: 100) }
        PromptCard { Color.clear.frame(height: 120) }
        AvatarBadge(initials: "SL")
    }
    .padding(Theme.screenInset)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .mindscapeBackground()
}
