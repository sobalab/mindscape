import SwiftUI

/// Colors and gradients lifted from the Figma file's variables.
/// Names match the Figma variable names where one exists, so the two stay round-trippable.
enum Theme {

    // MARK: Gradients

    /// `bg-linear-grad` — the screen background on every frame.
    static let background = LinearGradient(
        colors: [Color.backgroundTop, Color.backgroundBottom],
        startPoint: .top, endPoint: .bottom
    )

    /// `text-linear` — the accent half of every two-line title, and the wordmark.
    static let textLinear = LinearGradient(
        colors: [Color.accentPurple, Color.accentCyan],
        startPoint: .leading, endPoint: .trailing
    )

    /// `primary-button-lin` — filled pill buttons.
    static let primaryButton = LinearGradient(
        colors: [Color.buttonStart, Color.buttonEnd],
        startPoint: .leading, endPoint: .trailing
    )

    /// `navy-panel-fill` — reflection / entry cards.
    static let panel = LinearGradient(
        colors: [Color.panelStart, Color.panelEnd],
        startPoint: .leading, endPoint: .trailing
    )

    /// `nav-bg-linear` — the floating tab bar.
    static let navBar = LinearGradient(
        colors: [Color.navStart, Color.navEnd],
        startPoint: .leading, endPoint: .trailing
    )

    /// The avatar chip — a 56° diagonal in Figma.
    static let avatar = LinearGradient(
        colors: [Color.avatarStart, Color.avatarEnd],
        startPoint: UnitPoint(x: 0.15, y: 0.95), endPoint: UnitPoint(x: 0.9, y: 0.1)
    )

    /// Scrim that fades content out behind the floating tab bar.
    static let bottomScrim = LinearGradient(
        colors: [.black.opacity(0), .black],
        startPoint: .top, endPoint: .bottom
    )

    // MARK: Metrics

    /// Horizontal inset used by every screen (Figma: 25pt on a 402pt frame).
    static let screenInset: CGFloat = 25
    static let cardRadius: CGFloat = 25
    static let pillRadius: CGFloat = 30
    /// Height of the tab bar plus its bottom offset, so scroll views can clear it.
    static let tabBarClearance: CGFloat = 100
}

// Color symbols (.textPrimary, .accentPurple, .tagBgUnactive, …) are generated from
// Assets.xcassets by ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS,
// so there's no hand-written color extension here — the catalog is the single source.
