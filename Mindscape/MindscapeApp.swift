import SwiftUI

@main
struct MindscapeApp: App {
    @State private var model: AppModel = {
        let model = AppModel()
        let args = ProcessInfo.processInfo.arguments
        // Launch with `-skipOnboarding` to land straight in the tab shell.
        if args.contains("-skipOnboarding") {
            model.hasOnboarded = true
        }
        // `-answerPrompt` reproduces tapping Home's "Answer Prompt" for QA.
        if args.contains("-answerPrompt") {
            model.wantsNewEntry = true
        }
        // `-promptDone` shows the answered state without journaling through the flow.
        if args.contains("-promptDone") {
            model.answeredPromptIDs.insert(model.featuredPrompt.id)
            if !model.entries.isEmpty { model.entries[0].promptID = model.featuredPrompt.id }
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
