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
