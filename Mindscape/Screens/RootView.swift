import SwiftUI

/// Top-level gate: welcome and onboarding run as a linear flow, then the app switches
/// to the tabbed shell. `hasOnboarded` is what decides which side of the gate we're on.
struct RootView: View {
    @Environment(AppModel.self) private var model

    /// Design-QA hook: `-screen onboarding1|compose|saved|notifications|connect` renders
    /// one screen directly, so a screen behind a few taps can be checked in isolation.
    private var debugScreen: String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-screen"), index + 1 < args.count else { return nil }
        return args[index + 1]
    }

    var body: some View {
        Group {
            if let debugScreen {
                DebugScreenHost(name: debugScreen)
            } else if model.hasOnboarded {
                MainTabShell()
            } else {
                WelcomeFlow()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: model.hasOnboarded)
    }
}

/// The tabbed shell. Each tab owns its own `NavigationStack` so pushes stay scoped
/// to a tab, and the custom bar floats above the content.
struct MainTabShell: View {
    // Launch with `-startTab journal|insights|settings` to open straight onto a tab.
    @State private var selection: AppTab = {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-startTab"), index + 1 < args.count,
              let tab = AppTab(rawValue: args[index + 1]) else { return .home }
        return tab
    }()

    var body: some View {
        ZStack(alignment: .bottom) {
            MindscapeBackground()

            Group {
                switch selection {
                case .home:     HomeScreen(selection: $selection)
                case .journal:  JournalFlow()
                case .insights: InsightsFlow()
                case .settings: ProfileFlow()
                }
            }

            TabBarScrim()

            MindscapeTabBar(selection: $selection)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    RootView().environment(AppModel())
}

/// Figma's bottom scrim: content fades out above the floating tab bar and is blocked
/// completely behind it, so nothing shows through the strip under the bar or the
/// gutters beside it. The solid section runs past the bar's top edge and continues
/// through the home-indicator area.
struct TabBarScrim: View {
    /// Clears the bar (70pt) plus its 14pt bottom offset plus the home indicator.
    private let solidHeight: CGFloat = 122
    private let fadeHeight: CGFloat = 80

    var body: some View {
        // Spans the whole screen so the solid section reaches the physical bottom edge;
        // an intrinsically-sized stack stops at the safe area and lets content peek out.
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            LinearGradient(colors: [.black.opacity(0), .black],
                           startPoint: .top, endPoint: .bottom)
                .frame(height: fadeHeight)
            Color.black.frame(height: solidHeight)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

/// Renders a single screen for design QA. Only reachable via the `-screen` launch
/// argument, so it never appears in a normal run.
struct DebugScreenHost: View {
    @Environment(AppModel.self) private var model
    let name: String

    var body: some View {
        NavigationStack {
            switch name {
            case "onboarding1":
                OnboardingQuestion(step: .reasons) {}
            case "onboarding2":
                OnboardingQuestion(step: .style) {}
            case "onboarding4":
                OnboardingQuestion(step: .about) {}
            case "compose":
                JournalComposer { _ in }
            case "saved":
                EntrySavedScreen(entry: model.sortedEntries.first) {}
            case "entries":
                EntriesList(query: .constant("")) {}
            case "notifications":
                NotificationsScreen()
            case "connect":
                ConnectSupportScreen()
            case "observation":
                AIObservationDetail()
            default:
                ContentUnavailableView("Unknown screen", systemImage: "questionmark")
            }
        }
        .tint(.accentPurple)
    }
}
