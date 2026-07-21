import SwiftUI

/// The five-face mood picker on the journal composer. Each mood is a vertical pill
/// holding the emoji above its label; the selected one swaps the flat fill for
/// `tag-linear-active` and brightens the label.
struct MoodPicker: View {
    @Binding var selection: Mood?

    private static let activeFill = LinearGradient(
        colors: [Color.tagStrokeUnactive, Color.tagActiveEnd],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        // Pills flex to share the row so five fit across the screen at any width.
        HStack(spacing: 10) {
            ForEach(Mood.allCases) { mood in
                let isSelected = selection == mood
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        selection = isSelected ? nil : mood
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(mood.emoji).font(.system(size: 26))
                        Text(mood.label)
                            .font(.custom(PJS.bold, size: 12, relativeTo: .caption))
                            .fixedSize()
                            .foregroundStyle(isSelected ? Color.moodLabelSelected : Color.stepLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background {
                        let shape = RoundedRectangle(cornerRadius: 24)
                        shape.fill(isSelected ? AnyShapeStyle(Self.activeFill)
                                              : AnyShapeStyle(Color.tagBgUnactive))
                            .overlay {
                                shape.strokeBorder(
                                    isSelected ? Color.tagStroke : Color.tagStrokeUnactive,
                                    lineWidth: isSelected ? 2.4 : 3
                                )
                            }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mood.label)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

/// Small pill used on entry rows. Mood tags carry the purple gradient; theme tags use
/// the navy panel fill with the teal hairline.
struct EntryTag: View {
    let text: String
    var style: Style = .theme

    enum Style { case mood, theme }

    private static let moodFill = LinearGradient(
        colors: [Color.tagStrokeUnactive, Color.tagActiveEnd],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        Text(text)
            .font(.custom(PJS.semibold, size: 12.8, relativeTo: .caption))
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, 16)
            .padding(.top, 4.8)
            .padding(.bottom, 7.2)
            .background {
                let shape = RoundedRectangle(cornerRadius: 16)
                ZStack {
                    shape.fill(style == .mood ? AnyShapeStyle(Self.moodFill)
                                              : AnyShapeStyle(Theme.panel))
                    shape.strokeBorder(style == .mood ? Color.tagStroke : Color.tealTagStroke,
                                       lineWidth: 1.6)
                }
            }
    }
}

/// The date pill in the composer's top bar.
struct DatePill: View {
    let date: Date

    var body: some View {
        Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
            .msStyle(.msEyebrow, tracking: 0)
            .foregroundStyle(Color.dateBadgeText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.dateBadgeBg, in: .rect(cornerRadius: 6))
    }
}

/// "← BACK" link in the composer.
struct BackLink: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                ArrowGlyph(rotation: .degrees(-90), size: 16)
                Text("BACK").msStyle(.msEyebrow, tracking: 0.24)
            }
            .foregroundStyle(.accentPurple)
            .padding(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var mood: Mood? = .okay
    VStack(spacing: 24) {
        HStack {
            BackLink {}
            Spacer()
            DatePill(date: .now)
        }
        MoodPicker(selection: $mood)
        HStack {
            EntryTag(text: "okay", style: .mood)
            EntryTag(text: "work")
            EntryTag(text: "boundaries")
        }
    }
    .padding(Theme.screenInset)
    .frame(maxHeight: .infinity)
    .mindscapeBackground()
}
