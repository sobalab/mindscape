import SwiftUI

/// The Journal tab: a list of entries that pushes into the composer, which in turn
/// pushes the saved-confirmation screen.
struct JournalFlow: View {
    @Environment(AppModel.self) private var model
    @State private var path: [Route] = []
    @State private var query = ""

    private enum Route: Hashable {
        case compose
        case saved(UUID)
    }

    var body: some View {
        NavigationStack(path: $path) {
            EntriesList(query: $query) { path.append(.compose) }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .compose:
                        JournalComposer { entry in
                            model.addEntry(entry)
                            path.append(.saved(entry.id))
                        }
                    case .saved(let id):
                        EntrySavedScreen(entry: model.entries.first { $0.id == id }) {
                            path.removeAll()
                        }
                    }
                }
        }
        .tint(.accentPurple)
        // Home's "Answer Prompt" jumps straight into the composer. The flag may already
        // be set by the time this view is created (Home flips it, then switches tabs,
        // which builds JournalFlow fresh) — so consume it both on appear and on change,
        // since onChange alone never sees that initial value.
        .onAppear { openComposerIfRequested() }
        .onChange(of: model.wantsNewEntry) { _, _ in openComposerIfRequested() }
    }

    private func openComposerIfRequested() {
        guard model.wantsNewEntry else { return }
        if path.last != .compose { path.append(.compose) }
        model.wantsNewEntry = false
    }
}

// MARK: - Entries list

struct EntriesList: View {
    @Environment(AppModel.self) private var model
    @Binding var query: String
    let onCompose: () -> Void

    /// Entries split into the two headings the design uses.
    private var grouped: [(title: String, entries: [JournalEntry])] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let matches = model.sortedEntries.filter {
            query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)
                          || $0.body.localizedCaseInsensitiveContains(query)
        }
        return [
            ("THIS WEEK", matches.filter { $0.date >= cutoff }),
            ("LAST WEEK", matches.filter { $0.date < cutoff }),
        ].filter { !$0.1.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    ScreenTitle(first: "Your", second: "entries")
                    Spacer()
                    Button(action: onCompose) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.textPrimary)
                            .frame(width: 55, height: 55)
                            .background(Color.progressFill.opacity(0.3), in: .circle)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("New entry")
                }
                .padding(.bottom, 22)

                searchField.padding(.bottom, 30)

                ForEach(grouped, id: \.title) { group in
                    SectionHeader(group.title)
                        .padding(.bottom, 12)
                    ForEach(group.entries) { entry in
                        EntryCard(entry: entry)
                            .padding(.bottom, 14)
                    }
                }

                if grouped.isEmpty {
                    ContentUnavailableView.search(text: query)
                        .padding(.top, 60)
                }
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var searchField: some View {
        HStack(spacing: 12) {
            Image("SearchIcon")
                .renderingMode(.template)
                .resizable()
                .frame(width: 27, height: 27)
                .foregroundStyle(Color.fieldPlaceholder)
            TextField("", text: $query, prompt:
                Text("search entries...").foregroundStyle(Color.fieldPlaceholder))
                .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
                .foregroundStyle(.textPrimary)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 19.5)
        .frame(height: 56.6)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
            }
        }
    }
}

/// A full entry row: glyph, title, quote, date, then the mood tag and theme tags.
struct EntryCard: View {
    let entry: JournalEntry

    var body: some View {
        PanelCard {
            HStack(alignment: .top, spacing: 15) {
                Image("ReflectAvatar1")
                    .resizable()
                    .frame(width: 55, height: 55)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Text(entry.title)
                                    .msStyle(.msCardTitle, tracking: 0.32)
                                    .foregroundStyle(.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                // Marks an entry written in answer to an AI prompt.
                                if entry.promptID != nil {
                                    Image("CheckCircle")
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                        .accessibilityLabel("Answered a prompt")
                                }
                            }
                            Text(entry.excerpt)
                                .msStyle(.msQuote, tracking: 0.24)
                                .foregroundStyle(.textMuted)
                                .lineLimit(1)
                        }
                        Spacer(minLength: 8)
                        Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                            .msStyle(.msBadge, tracking: 0.2)
                            .foregroundStyle(.textMuted)
                            .fixedSize()
                    }

                    WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
                        if let mood = entry.mood {
                            EntryTag(text: mood.label, style: .mood)
                        }
                        ForEach(entry.tags, id: \.self) { tag in
                            EntryTag(text: tag)
                        }
                    }
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 22)
        }
    }
}

// MARK: - Composer

struct JournalComposer: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var mood: Mood?
    @State private var text = ""
    @State private var tags: Set<String> = []
    @State private var showingTagField = false
    @State private var newTag = ""
    /// The prompt this session is answering, captured on appear.
    @State private var prompt: AIPrompt?
    @FocusState private var editorFocused: Bool

    let onSave: (JournalEntry) -> Void

    private let characterLimit = 1000

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    BackLink { dismiss() }
                        .padding(.leading, -10)
                    Spacer()
                    DatePill(date: .now)
                }
                .padding(.bottom, 14)

                ScreenTitle(first: "Today’s", second: "reflection")
                    .padding(.bottom, 26)

                promptCard.padding(.bottom, 34)

                SectionHeader("HOW ARE YOU FEELING?").padding(.bottom, 16)
                MoodPicker(selection: $mood).padding(.bottom, 34)

                SectionHeader("WRITE YOUR ENTRY").padding(.bottom, 14)
                editor.padding(.bottom, 34)

                SectionHeader("TAGS").padding(.bottom, 14)
                tagRow.padding(.bottom, 34)

                PrimaryButton(title: "Save Entry", isEnabled: isValid) {
                    onSave(JournalEntry(
                        title: derivedTitle,
                        body: text,
                        mood: mood,
                        tags: Array(tags).sorted(),
                        date: .now,
                        promptID: prompt?.id
                    ))
                    model.promptToAnswer = nil
                }
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
        // The prompt was chosen on Home (or defaults to the featured one).
        .onAppear { if prompt == nil { prompt = model.promptToAnswer ?? model.featuredPrompt } }
    }

    private var isValid: Bool {
        mood != nil && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// The design's entries are titled by theme; fall back to the first few words.
    private var derivedTitle: String {
        if let first = tags.sorted().first {
            return tags.count > 1 ? "\(first.capitalized) & \(tags.sorted()[1])" : first.capitalized
        }
        return text.split(separator: " ").prefix(3).joined(separator: " ").capitalized
    }

    @ViewBuilder
    private var promptCard: some View {
        if let prompt {
            AIPromptCard(text: prompt.text, isAnswered: model.isPromptAnswered(prompt))
        }
    }

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused($editorFocused)
                .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
                .foregroundStyle(.textPrimary)
                .lineSpacing(5)
                .scrollContentBackground(.hidden)
                .frame(height: 180)
                .onChange(of: text) { _, new in
                    if new.count > characterLimit { text = String(new.prefix(characterLimit)) }
                }

            if text.isEmpty {
                Text("start writing here...")
                    .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
                    .foregroundStyle(Color.fieldPlaceholder)
                    .padding(.top, 8)
                    .padding(.leading, 5)
                    .allowsHitTesting(false)
            }

            Text("\(text.count) / \(characterLimit)")
                .font(.custom(PJS.semibold, size: 14, relativeTo: .subheadline))
                .foregroundStyle(Color.fieldPlaceholder)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
            }
        }
    }

    private var tagRow: some View {
        WrapLayout(horizontalSpacing: 10, verticalSpacing: 10) {
            ForEach(SampleData.suggestedTags, id: \.self) { tag in
                SelectionChip(title: tag, isSelected: tags.contains(tag), size: .small) {
                    if tags.contains(tag) { tags.remove(tag) } else { tags.insert(tag) }
                }
            }
            SelectionChip(title: "+ add tag", isSelected: false, size: .small) {
                showingTagField = true
            }
        }
        .alert("Add tag", isPresented: $showingTagField) {
            TextField("Tag name", text: $newTag)
            Button("Cancel", role: .cancel) { newTag = "" }
            Button("Add") {
                let trimmed = newTag.trimmingCharacters(in: .whitespaces).lowercased()
                if !trimmed.isEmpty { tags.insert(trimmed) }
                newTag = ""
            }
        }
    }
}

// MARK: - Saved confirmation

struct EntrySavedScreen: View {
    @Environment(AppModel.self) private var model
    let entry: JournalEntry?
    let onDone: () -> Void

    private static let doneGradient = Theme.textLinear
    private static let mutedGradient = LinearGradient(
        colors: [Color.tagBgUnactive, Color.tagStrokeUnactive],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("CheckCircle")
                    .resizable()
                    .frame(width: 90, height: 90)
                    .padding(.top, 40)
                    .padding(.bottom, 34)

                Text("Entry Saved")
                    .font(.msTitle)
                    .gradientText()
                    .padding(.bottom, 10)

                Text((entry?.date ?? .now).formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .msStyle(.msSection, tracking: 0.28)
                    .foregroundStyle(.textMuted)
                    .padding(.bottom, 34)

                streakCard.padding(.bottom, 34)

                if let entry, !entry.tags.isEmpty {
                    SectionHeader("REFLECTED THEMES")
                        .padding(.bottom, 12)
                    WrapLayout(horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(entry.tags, id: \.self) { EntryTag(text: $0, style: .mood) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 34)
                }

                Button(action: onDone) {
                    Text("Done for Today")
                        .font(.msButton)
                        .foregroundStyle(Color.moodLabelSelected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 53)
                        .background(Self.doneGradient, in: .rect(cornerRadius: Theme.pillRadius))
                        .shadow(color: .accentPurple.opacity(0.5), radius: 2.5, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)

                Button(action: onDone) {
                    Text("View Insights")
                        .font(.msButton)
                        .foregroundStyle(Color.optionSubtitle)
                        .frame(maxWidth: .infinity)
                        .frame(height: 53)
                        .background(Self.mutedGradient, in: .rect(cornerRadius: Theme.pillRadius))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var streakCard: some View {
        VStack(spacing: 0) {
            Image("FlameIcon")
                .resizable()
                .scaledToFit()
                .frame(height: 58)
                .padding(.top, 26)
                .padding(.bottom, 12)

            Text("\(model.streak)")
                .font(.custom(PJS.extraBold, size: 50, relativeTo: .largeTitle))
                .foregroundStyle(.textPrimary)

            Text("DAY STREAK")
                .font(.custom(PJS.extraBold, size: 22, relativeTo: .title2))
                .tracking(0.44)
                .foregroundStyle(.textPrimary)
                .padding(.top, 8)

            Text("You’re building a healthy habit!\nKeep it up tomorrow.")
                .msStyle(.msSection, tracking: 0.28)
                .foregroundStyle(Color.optionSubtitle)
                .multilineTextAlignment(.center)
                .padding(.top, 18)
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 2)
            }
        }
    }
}

#Preview("Entries") {
    JournalFlow().environment(AppModel())
}
