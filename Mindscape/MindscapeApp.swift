import SwiftUI

@main
struct MindscapeApp: App {
    @State private var model: AppModel = {
        let model = AppModel()
        // Launch with `-skipOnboarding` to land straight in the tab shell.
        if ProcessInfo.processInfo.arguments.contains("-skipOnboarding") {
            model.hasOnboarded = true
        }
        return model
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                // The design is dark-only; this keeps it honest if the device is in light mode.
                .preferredColorScheme(.dark)
        }
    }
}
