import SwiftUI

/// Plus Jakarta Sans, cut from the Google Fonts variable file into static weights.
/// Every face is registered by PostScript name via `UIAppFonts` in Config/Info.plist.
///
/// Sizes come straight from the Figma frames. Each is bound to a system text style with
/// `relativeTo:` so the type still tracks the user's Dynamic Type setting — the one
/// affordance custom fonts usually lose.
enum PJS {
    static let regular    = "PlusJakartaSans-Regular"
    static let medium     = "PlusJakartaSans-Medium"
    static let semibold   = "PlusJakartaSans-SemiBold"
    static let bold       = "PlusJakartaSans-Bold"
    static let extraBold  = "PlusJakartaSans-ExtraBold"
    static let boldItalic = "PlusJakartaSansItalic-BoldItalic"
}

extension Font {
    /// The `mindscape` wordmark on the welcome screen.
    static let msWordmark    = Font.custom(PJS.extraBold, size: 36.3, relativeTo: .largeTitle)
    /// Two-line screen titles: "Find your / inner calm".
    static let msTitle       = Font.custom(PJS.extraBold, size: 30, relativeTo: .title)
    /// Onboarding question / AI prompt body.
    static let msPrompt      = Font.custom(PJS.extraBold, size: 22, relativeTo: .title2)
    static let msButton      = Font.custom(PJS.extraBold, size: 18, relativeTo: .headline)
    /// Card headings and list-row titles.
    static let msCardTitle   = Font.custom(PJS.extraBold, size: 16, relativeTo: .callout)
    /// Uppercase section labels: "RECENT REFLECTION", "AI PROMPTS FOR YOU".
    static let msSection     = Font.custom(PJS.extraBold, size: 14, relativeTo: .subheadline)
    static let msBody        = Font.custom(PJS.extraBold, size: 14, relativeTo: .subheadline)
    /// Eyebrow text: "MORNING, SALLY", helper copy under a chip.
    static let msEyebrow     = Font.custom(PJS.extraBold, size: 12, relativeTo: .caption)
    /// Pull-quotes in reflection rows — the one italic face in the design.
    static let msQuote       = Font.custom(PJS.boldItalic, size: 12, relativeTo: .caption)
    /// Badges and timestamps.
    static let msBadge       = Font.custom(PJS.extraBold, size: 10, relativeTo: .caption2)
}

extension Text {
    /// Applies a font plus the letter-spacing Figma pairs with it.
    /// Figma tracking is 2% of the size on every label in this file.
    func msStyle(_ font: Font, tracking: CGFloat) -> some View {
        self.font(font).tracking(tracking)
    }
}

extension View {
    /// Paints text (or any view) with a gradient, the way Figma's `bg-clip-text` does.
    func gradientText(_ gradient: LinearGradient = Theme.textLinear) -> some View {
        self.foregroundStyle(.clear).overlay { gradient.mask(self) }
    }
}
