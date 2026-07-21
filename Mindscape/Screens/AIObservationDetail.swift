import SwiftUI
import Charts

/// Explains *why* the AI surfaced its observation — the weekday pattern it saw, the
/// factors it weighed, and the entries it drew from. Pushed from the Insights tab.
struct AIObservationDetail: View {
    @Environment(AppModel.self) private var model
    /// Pops this screen. Driven from the parent's navigation path rather than the
    /// environment's dismiss, which the hidden nav bar can leave inert.
    var onBack: () -> Void = {}
    @State private var revealed = false

    /// One line of "what we looked at", each with an SF Symbol.
    private struct Factor: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let detail: String
    }

    private var factors: [Factor] {
        [
            Factor(icon: "doc.text.magnifyingglass",
                   title: "\(model.observationEntryCount) entries analyzed",
                   detail: "written over the last 30 days"),
            Factor(icon: "sunrise.fill",
                   title: "Mornings scored lower",
                   detail: "avg mood 2.4 before noon vs 3.8 after"),
            Factor(icon: "calendar",
                   title: "Mondays are hardest",
                   detail: "your lowest weekday average this month"),
            Factor(icon: "text.magnifyingglass",
                   title: "“deadlines”, “overwhelmed” recur",
                   detail: "most often in early-week entries"),
        ]
    }

    /// The entries that most shaped the pattern — the lower-mood ones.
    private var contributingEntries: [JournalEntry] {
        Array(model.sortedEntries.sorted { moodRank($0.mood) < moodRank($1.mood) }.prefix(2))
    }

    private func moodRank(_ mood: Mood?) -> Int {
        Mood.allCases.firstIndex(of: mood ?? .okay) ?? 2
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackLink { onBack() }
                    .padding(.leading, -10)
                    .padding(.bottom, 14)

                ScreenTitle(first: "Behind the", second: "insight")
                    .padding(.bottom, 26)

                ObservationCard(text: model.aiObservation)
                    .padding(.bottom, 34)

                SectionHeader("MOOD BY DAY").padding(.bottom, 16)
                weekdayCard.padding(.bottom, 34)

                SectionHeader("WHAT WE LOOKED AT").padding(.bottom, 14)
                factorsCard.padding(.bottom, 34)

                SectionHeader("ENTRIES BEHIND THIS").padding(.bottom, 14)
                ForEach(contributingEntries) { entry in
                    EntryCard(entry: entry).padding(.bottom, 14)
                }

                disclaimer.padding(.top, 6)
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            revealed = false
            withAnimation(.easeOut(duration: 0.7)) { revealed = true }
        }
    }

    // MARK: Weekday chart

    private var weekdayCard: some View {
        PromptCard {
            VStack(alignment: .leading, spacing: 0) {
                Badge(text: "AVERAGE MOOD, MON–SUN").padding(.bottom, 20)

                Chart(model.weekdayMood) { day in
                    BarMark(
                        x: .value("Day", day.day),
                        yStart: .value("Base", -0.6),
                        yEnd: .value("Mood", day.score * (revealed ? 1 : 0)),
                        width: .fixed(22)
                    )
                    // Highlight the peaks (midweek) the same way the trend card does.
                    .foregroundStyle(day.score >= 4 ? Color.progressFill : Color.progressTrack)
                    .cornerRadius(10)
                }
                .chartYScale(domain: 0...5.6)
                .chartPlotStyle { $0.clipped() }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: model.weekdayMood.map(\.day)) { value in
                        AxisValueLabel {
                            if let day = value.as(String.self) {
                                Text(day)
                                    .font(.custom(PJS.bold, size: 12, relativeTo: .caption))
                                    .foregroundStyle(.textMuted)
                            }
                        }
                    }
                }
                .frame(height: 140)
                .accessibilityLabel("Average mood by weekday")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
    }

    // MARK: Factors

    private var factorsCard: some View {
        PanelCard {
            VStack(spacing: 0) {
                ForEach(Array(factors.enumerated()), id: \.element.id) { index, factor in
                    HStack(spacing: 14) {
                        Image(systemName: factor.icon)
                            .font(.system(size: 18))
                            .foregroundStyle(Color.accentCyan)
                            .frame(width: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(factor.title)
                                .font(.custom(PJS.bold, size: 15, relativeTo: .subheadline))
                                .foregroundStyle(Color.valueText)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(factor.detail)
                                .font(.custom(PJS.semibold, size: 12, relativeTo: .caption))
                                .foregroundStyle(Color.chipInactiveText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 14)
                    .overlay(alignment: .top) { if index > 0 { RowDivider() } }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    private var disclaimer: some View {
        Text("Generated from your entries. Patterns are gentle suggestions to reflect on — not clinical advice.")
            .font(.custom(PJS.semibold, size: 12, relativeTo: .caption))
            .foregroundStyle(.textMuted)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack { AIObservationDetail {} }
        .environment(AppModel())
}
