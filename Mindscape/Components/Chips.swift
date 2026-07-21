import SwiftUI

/// The selectable pill used across onboarding ("reduce stress", "anxiety") and
/// the journal tag row. Selected state is `tag-linear-active` with the brighter
/// `tag-stroke`; unselected is the flat `tag-bg-unactive` with a dimmer label.
struct SelectionChip: View {
    let title: String
    let isSelected: Bool
    /// Onboarding chips are 20pt; journal tags are smaller.
    var size: Size = .large
    let action: () -> Void

    enum Size {
        case large, small

        var font: Font {
            switch self {
            case .large: .custom(PJS.bold, size: 20, relativeTo: .title3)
            case .small: .custom(PJS.bold, size: 13, relativeTo: .footnote)
            }
        }
        var horizontalPadding: CGFloat { self == .large ? 28.8 : 14 }
        var topPadding: CGFloat { self == .large ? 8.64 : 6 }
        var bottomPadding: CGFloat { self == .large ? 12.96 : 8 }
        var radius: CGFloat { self == .large ? 28.8 : 16 }
        var stroke: CGFloat { self == .large ? 2.88 : 1.5 }
    }

    private static let activeFill = LinearGradient(
        colors: [Color.tagStrokeUnactive, Color.tagActiveEnd],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(size.font)
                .lineSpacing(size == .large ? 4 : 2)
                .foregroundStyle(isSelected ? Color.textPrimary : Color.chipInactiveText)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.top, size.topPadding)
                .padding(.bottom, size.bottomPadding)
                .background {
                    let shape = RoundedRectangle(cornerRadius: size.radius)
                    ZStack {
                        if isSelected {
                            shape.fill(Self.activeFill)
                            shape.strokeBorder(.tagStroke, lineWidth: size.stroke)
                        } else {
                            shape.fill(.tagBgUnactive)
                            shape.strokeBorder(.tagStrokeUnactive, lineWidth: size.stroke)
                        }
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Small uppercase badge — "BASED ON YOUR JOURNALS", "AI OBSERVATION".
struct Badge: View {
    let text: String
    var foreground: Color = .accentPurple
    var background: Color = Color.tagStrokeUnactive

    var body: some View {
        Text(text)
            .msStyle(.msBadge, tracking: 0.2)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(background, in: .rect(cornerRadius: 5))
    }
}

/// The stepped progress bar at the top of each onboarding question.
struct StepProgressBar: View {
    let step: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Question \(step) of \(total)")
                .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                .foregroundStyle(Color.stepLabel)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.progressTrack)
                    Capsule()
                        .fill(Color.progressFill)
                        .frame(width: proxy.size.width * (CGFloat(step) / CGFloat(total)))
                }
            }
            .frame(height: 7)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Question \(step) of \(total)")
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        StepProgressBar(step: 1, total: 4)
        SelectionChip(title: "reduce stress", isSelected: true) {}
        SelectionChip(title: "track emotions", isSelected: false) {}
        HStack {
            SelectionChip(title: "work", isSelected: true, size: .small) {}
            SelectionChip(title: "+ family", isSelected: false, size: .small) {}
        }
        Badge(text: "BASED ON YOUR JOURNALS")
    }
    .padding(Theme.screenInset)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .mindscapeBackground()
}
