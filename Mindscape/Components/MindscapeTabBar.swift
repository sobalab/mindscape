import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home, journal, insights, settings

    var id: Self { self }

    /// The label only appears on the active tab, per the design.
    var title: String {
        switch self {
        case .home:     "HOME"
        case .journal:  "JOURNAL"
        case .insights: "INSIGHTS"
        case .settings: "SETTINGS"
        }
    }

    /// Exported from Figma as template SVGs so they tint per state.
    var icon: String {
        switch self {
        case .home:     "NavHome"
        case .journal:  "NavJournal"
        case .insights: "NavInsights"
        case .settings: "NavSettings"
        }
    }
}

/// The floating pill tab bar. Built by hand rather than with `TabView` because the design
/// labels only the selected tab and uses the `nav-bg-linear` fill instead of system glass.
/// Accessibility that `TabView` would supply for free is wired up explicitly below.
struct MindscapeTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = tab == selection

                Button {
                    guard !isSelected else { return }
                    withAnimation(.snappy(duration: 0.28)) { selection = tab }
                } label: {
                    HStack(spacing: 9) {
                        Image(tab.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 16)
                        if isSelected {
                            Text(tab.title)
                                .msStyle(.msSection, tracking: 0.28)
                                .fixedSize()
                                .transition(.opacity.combined(with: .scale(0.8, anchor: .leading)))
                        }
                    }
                    .foregroundStyle(isSelected ? Color.accentPurple : Color.chipInactiveText)
                    // The active pill sizes to its label; the rest share what's left,
                    // which is how Figma spaces them.
                    .padding(.horizontal, isSelected ? 18 : 0)
                    .frame(maxWidth: isSelected ? nil : .infinity)
                    .frame(height: 50)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.navActivePill)
                                .matchedGeometryEffect(id: "activePill", in: pill)
                        }
                    }
                    .contentShape(.capsule)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title.capitalized)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(.horizontal, 11)
        .frame(height: 70)
        .background {
            Capsule()
                .fill(Theme.navBar)
                .overlay { Capsule().strokeBorder(.tagStrokeUnactive, lineWidth: 2) }
        }
        .padding(.horizontal, Theme.screenInset)
        .padding(.bottom, 14)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Main navigation")
    }
}

#Preview {
    @Previewable @State var tab: AppTab = .home
    VStack {
        Spacer()
        MindscapeTabBar(selection: $tab)
    }
    .mindscapeBackground()
}
