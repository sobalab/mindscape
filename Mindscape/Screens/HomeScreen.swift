import SwiftUI

struct HomeScreen: View {
    @Environment(AppModel.self) private var model
    @Binding var selection: AppTab

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        let part = switch hour {
        case ..<12: "MORNING"
        case ..<18: "AFTERNOON"
        default:    "EVENING"
        }
        return "\(part), \(model.displayName.split(separator: " ").first.map(String.init)?.uppercased() ?? "")"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header.padding(.bottom, 30)
                promptSection.padding(.bottom, 34)
                reflectionsSection
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: Sections

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text(greeting)
                    .msStyle(.msEyebrow, tracking: 0.24)
                    .foregroundStyle(.textMuted)
                ScreenTitle(first: "Find your", second: "inner calm")
            }
            Spacer()
            Button { selection = .settings } label: {
                AvatarBadge(initials: model.initials)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Your profile")
        }
    }

    private var promptSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 7) {
                Image("AIIcon")
                    .resizable()
                    .frame(width: 24.2, height: 24.2)
                Text("AI PROMPTS FOR YOU")
                    .msStyle(.msSection, tracking: 0.28)
                    .foregroundStyle(.accentCyan)
            }

            AIPromptCard(text: model.featuredPrompt.text,
                         isAnswered: model.isPromptAnswered(model.featuredPrompt)) {
                // Hand the specific prompt to the composer over in the Journal tab.
                model.promptToAnswer = model.featuredPrompt
                model.wantsNewEntry = true
                selection = .journal
            }
        }
    }

    private var reflectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "RECENT REFLECTION") {
                Button { selection = .journal } label: {
                    Text("History")
                        .msStyle(.msSection, tracking: 0.28)
                        .foregroundStyle(.accentPurple)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)

            ForEach(Array(model.sortedEntries.prefix(3).enumerated()), id: \.element.id) { index, entry in
                ReflectionRow(entry: entry, avatarIndex: index)
            }
        }
    }
}

/// One row in Recent Reflection — glyph, title, pull-quote, relative date.
struct ReflectionRow: View {
    let entry: JournalEntry
    var avatarIndex: Int = 0

    var body: some View {
        PanelCard {
            HStack(alignment: .top, spacing: 15) {
                Image(avatarIndex == 2 ? "ReflectAvatar2" : "ReflectAvatar1")
                    .resizable()
                    .frame(width: 55, height: 55)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .msStyle(.msCardTitle, tracking: 0.32)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(entry.excerpt)
                        .msStyle(.msQuote, tracking: 0.24)
                        .foregroundStyle(.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                Text(entry.relativeLabel)
                    .msStyle(.msBadge, tracking: 0.2)
                    .foregroundStyle(.textMuted)
                    .fixedSize()
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 22)
        }
    }
}

#Preview {
    RootView().environment({
        let model = AppModel()
        model.hasOnboarded = true
        return model
    }())
}
