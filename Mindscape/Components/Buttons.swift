import SwiftUI

/// The filled pill that ends most screens — `primary-button-lin` at 53pt tall, radius 30,
/// with the purple glow Figma draws as a drop shadow.
struct PrimaryButton: View {
    let title: String
    var showsArrow: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Text(title).font(.msButton)
                if showsArrow { ArrowGlyph() }
            }
            .foregroundStyle(.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 53)
            .background(Theme.primaryButton, in: .rect(cornerRadius: Theme.pillRadius))
            .shadow(color: .accentPurple.opacity(0.5), radius: 2.5, y: 1)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.4)
    }
}

/// The outlined counterpart used for "LOG IN" and "View Insights" — purple hairline
/// border with the label itself painted in the button gradient.
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.msButton)
                .gradientText(Theme.primaryButton)
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background {
                    RoundedRectangle(cornerRadius: Theme.pillRadius)
                        .strokeBorder(Color.buttonStart, lineWidth: 1)
                }
                .shadow(color: .accentPurple.opacity(0.5), radius: 5, y: 1)
        }
        .buttonStyle(.plain)
    }
}

/// Figma draws the trailing arrow as the `Arrow upward` asset rotated 90°.
/// Keeping the rotation here means one exported asset serves both orientations.
struct ArrowGlyph: View {
    var rotation: Angle = .degrees(90)
    var size: CGFloat = 22

    var body: some View {
        Image("ArrowUpward")
            .renderingMode(.template)
            .resizable()
            .frame(width: size, height: size)
            .rotationEffect(rotation)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Continue") {}
        PrimaryButton(title: "Answer Prompt", showsArrow: true) {}
        SecondaryButton(title: "LOG IN") {}
        PrimaryButton(title: "Save Entry", isEnabled: false) {}
    }
    .padding(Theme.screenInset)
    .frame(maxHeight: .infinity)
    .mindscapeBackground()
}
