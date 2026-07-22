import SwiftUI

/// The single-select card in onboarding Q2 — a `SelectionChip` with a subtitle line.
struct OptionCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    private static let activeFill = LinearGradient(
        colors: [Color.tagStrokeUnactive, Color.tagActiveEnd],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.custom(isSelected ? PJS.bold : PJS.semibold, size: 20, relativeTo: .title3))
                    .foregroundStyle(isSelected ? Color.textPrimary : Color.chipInactiveText)
                Text(subtitle)
                    .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                    .foregroundStyle(isSelected ? Color.optionSubtitle : Color.chipInactiveText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 28.8)
            .padding(.vertical, 20)
            .background {
                let shape = RoundedRectangle(cornerRadius: 28.8)
                ZStack {
                    shape.fill(isSelected ? AnyShapeStyle(Self.activeFill) : AnyShapeStyle(Color.tagBgUnactive))
                    shape.strokeBorder(isSelected ? Color.tagStroke : Color.tagStrokeUnactive, lineWidth: 2.88)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityLabel("\(title). \(subtitle)")
    }
}

/// The rounded text field used in onboarding Q4 and the Connect Support screen.
struct MindscapeTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        TextField("", text: $text, prompt:
            Text(placeholder).foregroundStyle(Color.fieldPlaceholder)
        )
        .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
        .foregroundStyle(.textPrimary)
        .keyboardType(keyboard)
        .textInputAutocapitalization(keyboard == .default ? .words : .never)
        .padding(.horizontal, 29)
        .frame(height: 56.6)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
            }
        }
    }
}

/// Small label above a field: "What's your name?"
struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text)
            .msStyle(.msSection, tracking: 0.28)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A labeled checkbox — a rounded square that fills with the accent when checked.
struct CheckboxRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: 12) {
                ZStack {
                    let shape = RoundedRectangle(cornerRadius: 7)
                    shape.fill(isOn ? AnyShapeStyle(Theme.primaryButton) : AnyShapeStyle(Color.tagBgUnactive))
                    shape.strokeBorder(isOn ? Color.accentPurple : Color.tagStrokeUnactive, lineWidth: 2)
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.textPrimary)
                    }
                }
                .frame(width: 26, height: 26)

                Text(title)
                    .font(.custom(PJS.bold, size: 16, relativeTo: .callout))
                    .foregroundStyle(isOn ? Color.accentPurple : Color.chipInactiveText)
                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isOn ? [.isButton, .isSelected] : .isButton)
    }
}

/// A left-aligned text link with the rotated arrow — "SKIP FOR NOW →".
struct ArrowLink: View {
    let title: String
    var color: Color = .accentPurple
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title).msStyle(.msEyebrow, tracking: 0.24)
                ArrowGlyph(size: 16)
            }
            .foregroundStyle(color)
            .padding(10)
        }
        .buttonStyle(.plain)
    }
}

/// Lays chips out left-to-right, wrapping to the next line — the layout Figma draws by
/// hand on onboarding Q3 and the journal tag row.
struct WrapLayout: Layout {
    var horizontalSpacing: CGFloat = 10
    var verticalSpacing: CGFloat = 12

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows = 1
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + horizontalSpacing + size.width > maxWidth {
                totalHeight += rowHeight + verticalSpacing
                rows += 1
                x = size.width
                rowHeight = size.height
            } else {
                x += (x > 0 ? horizontalSpacing : 0) + size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        totalHeight += rowHeight
        return CGSize(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize,
                       subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + horizontalSpacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    @Previewable @State var name = ""
    VStack(alignment: .leading, spacing: 16) {
        OptionCard(title: "Structured Prompts", subtitle: "guided questions each session", isSelected: true) {}
        OptionCard(title: "Freewriting", subtitle: "write whatever comes to mind", isSelected: false) {}
        FieldLabel(text: "What's your name?")
        MindscapeTextField(placeholder: "Full Name", text: $name)
        ArrowLink(title: "SKIP FOR NOW") {}
    }
    .padding(Theme.screenInset)
    .frame(maxHeight: .infinity, alignment: .top)
    .mindscapeBackground()
}
