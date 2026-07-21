import Foundation

enum Mood: String, CaseIterable, Identifiable, Codable {
    case rough, low, okay, good, great

    var id: Self { self }
    var label: String { rawValue }

    /// The face shown in the mood row. These are color emoji in the Figma file.
    var emoji: String {
        switch self {
        case .rough: "😖"
        case .low:   "😕"
        case .okay:  "😐"
        case .good:  "🙂"
        case .great: "😄"
        }
    }
}

struct JournalEntry: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var mood: Mood?
    var tags: [String]
    var date: Date

    init(id: UUID = UUID(), title: String, body: String, mood: Mood? = nil,
         tags: [String] = [], date: Date) {
        self.id = id
        self.title = title
        self.body = body
        self.mood = mood
        self.tags = tags
        self.date = date
    }

    /// How Home labels a date: "Yesterday", then the weekday name for the past week,
    /// and an abbreviated date beyond that.
    var relativeLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        if calendar.isDateInToday(date) { return "Today" }
        let days = calendar.dateComponents([.day], from: date, to: .now).day ?? 0
        if days < 7 { return date.formatted(.dateTime.weekday(.wide)) }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    /// The truncated pull-quote shown in list rows.
    var excerpt: String {
        let trimmed = body.prefix(30).trimmingCharacters(in: .whitespacesAndNewlines)
        return "“\(trimmed)\(body.count > 30 ? "..." : "")"
    }
}

/// A theme with its share of entries — drives the Insights bars.
struct ThemeStat: Identifiable, Hashable {
    let id = UUID()
    let name: String
    /// 0…1
    let share: Double
}

/// One bar in the Insights mood-trend chart.
struct MoodPoint: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    /// 1…5, matching `Mood`'s ordering.
    let score: Int
}
