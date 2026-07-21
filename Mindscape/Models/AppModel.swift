import Foundation
import Observation

/// In-memory state for the prototype. Everything lives here so the screens stay
/// declarative; swapping this for SwiftData later means changing this type only.
@Observable
final class AppModel {

    // MARK: Onboarding

    var hasOnboarded = false
    /// Q1 — multi-select.
    var reasons: Set<String> = []
    /// Q2 — single-select.
    var journalingStyle: String?
    /// Q3 — multi-select.
    var challenges: Set<String> = []
    /// Q4.
    var name = ""
    var age = ""
    var promptFrequency = "daily"

    // MARK: Profile

    var displayName: String { name.isEmpty ? "Sally Lee" : name }
    var initials: String {
        let parts = displayName.split(separator: " ").prefix(2)
        return parts.compactMap(\.first).map(String.init).joined().uppercased()
    }
    var memberSince = "MAR 2026"

    // MARK: Journal

    var entries: [JournalEntry] = SampleData.entries
    var streak = 4
    /// Set when Home's "Answer Prompt" should open the composer over in the Journal tab.
    var wantsNewEntry = false

    /// Entries newest first, which is how both Home and the entries list read them.
    var sortedEntries: [JournalEntry] {
        entries.sorted { $0.date > $1.date }
    }

    func addEntry(_ entry: JournalEntry) {
        entries.append(entry)
        streak += 1
        if let promptID = entry.promptID { answeredPromptIDs.insert(promptID) }
    }

    // MARK: AI prompts

    var prompts: [AIPrompt] = SampleData.prompts
    /// Prompts the user has already reflected on. Drives the "done" affordance.
    var answeredPromptIDs: Set<UUID> = []
    /// The prompt the composer is currently answering (set when Home hands off).
    var promptToAnswer: AIPrompt?

    /// The prompt surfaced on Home and pre-filled in the composer.
    var featuredPrompt: AIPrompt { prompts[0] }

    func isPromptAnswered(_ prompt: AIPrompt) -> Bool {
        answeredPromptIDs.contains(prompt.id)
    }

    // MARK: Insights

    var moodTrend: [MoodPoint] = SampleData.moodTrend
    var topThemes: [ThemeStat] = SampleData.topThemes
    var weekdayMood: [WeekdayMood] = SampleData.weekdayMood
    var aiObservation = "Your mood tends to improve mid-week. Mornings are harder, especially Mondays."
    /// Number of entries the observation was drawn from — shown on the detail page.
    var observationEntryCount = 17

    // MARK: Settings toggles

    var dailyJournalReminder = true
    var reminderTime = "8:00 AM"
    var weeklySummary = true
    var dailyAffirmation = true
    var prescribedTaskAlerts = true
    var reportReady = false
}

enum SampleData {
    private static func day(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
    }

    static let entries: [JournalEntry] = [
        JournalEntry(
            title: "Work stress & boundaries",
            body: "I realized that saying ‘no’ is not the same as letting people down. Protecting my evenings gave me room to think.",
            mood: .okay, tags: ["work", "boundaries"], date: day(1)
        ),
        JournalEntry(
            title: "Morning Gratitude",
            body: "So grateful for the quiet hour before everyone else wakes up. The light through the kitchen window helps.",
            mood: .good, tags: ["sleep", "anxiety"], date: day(3)
        ),
        JournalEntry(
            title: "Weekly Strengths",
            body: "My biggest strength was showing up even on the days I did not feel like it.",
            mood: .great, tags: ["sleep", "boundaries"], date: day(6)
        ),
        JournalEntry(
            title: "Relationships & boundaries",
            body: "I need to be more aware of how much I take on for other people before I check in with myself.",
            mood: .low, tags: ["friends", "boundaries"], date: day(8)
        ),
    ]

    /// 13 readings across the last month, matching the density of the design's chart.
    static let moodTrend: [MoodPoint] = {
        let scores = [3, 2, 5, 2, 3, 5, 3, 1, 5, 3, 2, 3, 5]
        return scores.enumerated().map { index, score in
            MoodPoint(date: day(30 - index * 2), score: score)
        }
    }()

    static let topThemes: [ThemeStat] = [
        .init(name: "Anxiety",    share: 0.68),
        .init(name: "Work Stress", share: 0.45),
        .init(name: "Gratitude",  share: 0.30),
        .init(name: "Sleep",      share: 0.22),
    ]

    /// Average mood per weekday — Mondays lowest, midweek highest, matching the
    /// observation the AI surfaces.
    static let weekdayMood: [WeekdayMood] = [
        .init(day: "Mon", score: 2.1),
        .init(day: "Tue", score: 3.0),
        .init(day: "Wed", score: 4.2),
        .init(day: "Thu", score: 4.4),
        .init(day: "Fri", score: 3.6),
        .init(day: "Sat", score: 3.9),
        .init(day: "Sun", score: 2.8),
    ]

    /// The onboarding answer sets, in question order.
    static let reasons = ["reduce stress", "track emotions", "manage anxiety",
                          "self-reflection", "manage depression", "mental clarity"]

    static let journalingStyles: [(title: String, subtitle: String)] = [
        ("Structured Prompts", "guided questions each session"),
        ("Freewriting", "write whatever comes to mind"),
        ("Gratitude Journaling", "focus on the positive"),
        ("Emotion Tracking", "log and monitor your moods"),
    ]

    static let challenges = ["anxiety", "depression", "burnout", "insomnia",
                             "OCD", "low motivation", "self-doubt", "stress"]

    /// The reflection prompts Home rotates through. The first is the featured one.
    static let prompts: [AIPrompt] = [
        AIPrompt(text: "You mentioned feeling overwhelmed by deadlines twice this week. What is one small task you can let go of today to create space?"),
    ]

    static let promptFrequencies = ["daily", "weekly", "occasional"]

    static let suggestedTags = ["work", "family", "sleep", "boundaries", "friends"]
}
