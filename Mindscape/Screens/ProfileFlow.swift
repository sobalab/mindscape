import SwiftUI

struct ProfileFlow: View {
    @State private var path: [Route] = []

    enum Route: Hashable { case notifications, connect }

    var body: some View {
        NavigationStack(path: $path) {
            ProfileScreen { path.append($0) }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .notifications: NotificationsScreen()
                    case .connect:       ConnectSupportScreen()
                    }
                }
        }
        .tint(.accentPurple)
    }
}

// MARK: - Profile

struct ProfileScreen: View {
    @Environment(AppModel.self) private var model
    let onNavigate: (ProfileFlow.Route) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 16) {
                    AvatarBadge(initials: model.initials, size: 90)
                    Text(model.displayName)
                        .font(.msTitle)
                        .foregroundStyle(.textPrimary)
                    Text("MEMBER SINCE \(model.memberSince)")
                        .msStyle(.msEyebrow, tracking: 0.24)
                        .foregroundStyle(.textMuted)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.bottom, 34)

                SectionHeader("ACCOUNT").padding(.bottom, 14)
                accountCard.padding(.bottom, 30)

                SectionHeader("PREFERENCES").padding(.bottom, 14)
                preferencesCard.padding(.bottom, 30)

                SectionHeader("HEALTHCARE").padding(.bottom, 14)
                providerCard.padding(.bottom, 30)

                logOutButton
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var accountCard: some View {
        SettingsCard {
            SettingsRow(label: "Name", value: model.displayName, accessory: .edit, showsDivider: false)
            SettingsRow(label: "Age", value: model.age.isEmpty ? "26" : model.age, accessory: .edit)
            SettingsRow(label: "Journaling Style",
                        value: model.journalingStyle?.split(separator: " ").first.map(String.init) ?? "Structured",
                        accessory: .edit)
            SettingsRow(label: "Prompt Frequency",
                        value: model.promptFrequency.capitalized, accessory: .edit)
        }
    }

    private var preferencesCard: some View {
        SettingsCard {
            SettingsRow(label: "Notifications", value: "Reminders", accessory: .disclosure,
                        showsDivider: false) {
                onNavigate(.notifications)
            }
            SettingsRow(label: "Connect Support", value: "Provider", accessory: .disclosure) {
                onNavigate(.connect)
            }
        }
    }

    private var providerCard: some View {
        PanelCard {
            HStack(alignment: .top, spacing: 15) {
                Text("DR")
                    .font(.custom(PJS.semibold, size: 18, relativeTo: .body))
                    .foregroundStyle(.textPrimary)
                    .frame(width: 55, height: 55)
                    .background(Color.connectedEnd.opacity(0.2), in: .circle)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Dr. Rivera")
                        .msStyle(.msCardTitle, tracking: 0.32)
                        .foregroundStyle(.white)
                    Text("anxiety  ∙  CBT")
                        .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                        .foregroundStyle(Color.chipInactiveText)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("CONNECTED")
                        .msStyle(.msBadge, tracking: 0)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(colors: [Color.connectedStart, Color.connectedEnd],
                                           startPoint: .leading, endPoint: .trailing),
                            in: .rect(cornerRadius: 5)
                        )
                    Button { onNavigate(.connect) } label: {
                        HStack(spacing: 2) {
                            Text("MANAGE").msStyle(.msBadge, tracking: 0.2)
                            ArrowGlyph(size: 18)
                        }
                        .foregroundStyle(Color.chipInactiveText)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 17)
            .padding(.vertical, 22)
        }
    }

    private var logOutButton: some View {
        Button { model.hasOnboarded = false } label: {
            Text("Log Out")
                .font(.msButton)
                .foregroundStyle(Color.logOutRed)
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background {
                    RoundedRectangle(cornerRadius: Theme.pillRadius)
                        .strokeBorder(Color.logOutRed, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Shared settings pieces

/// The violet card that groups settings rows, with hairlines between them.
struct SettingsCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(.tagBgUnactive).overlay {
                shape.strokeBorder(.tagStrokeUnactive, lineWidth: 3)
            }
        }
    }
}

/// A label/value row. The hairline is a top edge, suppressed on the first row of a card
/// so the group has rules between rows but not above the first one.
struct SettingsRow: View {
    let label: String
    let value: String
    var accessory: Accessory = .none
    var showsDivider: Bool = true
    var action: (() -> Void)? = nil

    enum Accessory { case none, edit, disclosure }

    var body: some View {
        Button { action?() } label: {
            HStack {
                Text(label)
                    .msStyle(.msCardTitle, tracking: 0.32)
                    .foregroundStyle(Color.chipInactiveText)
                Spacer()
                Text(value)
                    .msStyle(.msCardTitle, tracking: 0.32)
                    .foregroundStyle(Color.valueText)
                switch accessory {
                case .none: EmptyView()
                case .edit:
                    Image("PencilIcon")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 13, height: 13)
                        .foregroundStyle(Color.chipInactiveText)
                case .disclosure:
                    ArrowGlyph(size: 22).foregroundStyle(Color.valueText)
                }
            }
            .frame(height: 54)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
        .overlay(alignment: .top) { if showsDivider { RowDivider() } }
    }
}

/// The hairline the design draws between rows. Hidden on the first row of a card via
/// the container's clipping, so it's drawn as a top edge everywhere.
struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.tagStrokeUnactive.opacity(0.7))
            .frame(height: 1)
    }
}

/// Title + subtitle with a trailing switch, used throughout the notifications screen.
struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .msStyle(.msCardTitle, tracking: 0.32)
                    .foregroundStyle(Color.valueText)
                Text(subtitle)
                    .font(.custom(PJS.semibold, size: 12, relativeTo: .caption))
                    .tracking(0.24)
                    .foregroundStyle(Color.chipInactiveText)
            }
        }
        .tint(.accentPurple)
        .padding(.vertical, 14)
    }
}

// MARK: - Notifications

struct NotificationsScreen: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss

    private let times = ["8:00 AM", "12:00 PM", "6:00 PM", "9:00 PM"]

    var body: some View {
        @Bindable var model = model

        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BackLink { dismiss() }
                    .padding(.leading, -10)
                    .padding(.bottom, 14)

                ScreenTitle(first: "notifications", second: "& reminders")
                    .padding(.bottom, 30)

                SectionHeader("JOURNAL REMINDERS").padding(.bottom, 14)
                SettingsCard {
                    ToggleRow(title: "Daily Journal Reminder",
                              subtitle: "Nudge to write your entry",
                              isOn: $model.dailyJournalReminder)
                    reminderTimes
                    ToggleRow(title: "Weekly Summary",
                              subtitle: "Every Sunday Morning",
                              isOn: $model.weeklySummary)
                        .overlay(alignment: .top) { RowDivider() }
                }
                .padding(.bottom, 30)

                SectionHeader("WRITE YOUR ENTRY").padding(.bottom, 14)
                SettingsCard {
                    ToggleRow(title: "Daily Affirmation",
                              subtitle: "Personalized Push Notification",
                              isOn: $model.dailyAffirmation)
                }
                .padding(.bottom, 30)

                SectionHeader("PROVIDER ALERTS").padding(.bottom, 14)
                SettingsCard {
                    ToggleRow(title: "Prescribed Task Alerts",
                              subtitle: "When Provider assigns tasks",
                              isOn: $model.prescribedTaskAlerts)
                    ToggleRow(title: "Report Ready",
                              subtitle: "When monthly report is generated",
                              isOn: $model.reportReady)
                        .overlay(alignment: .top) { RowDivider() }
                }
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var reminderTimes: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reminder Time")
                .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                .tracking(0.32)
                .foregroundStyle(Color.chipInactiveText)

            HStack(spacing: 10) {
                ForEach(times, id: \.self) { time in
                    TimeChip(time: time, isSelected: model.reminderTime == time) {
                        model.reminderTime = time
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 18)
        .overlay(alignment: .top) { RowDivider() }
    }
}

/// One of the four reminder-time presets — a two-line chip.
struct TimeChip: View {
    let time: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        let parts = time.split(separator: " ")

        Button(action: action) {
            VStack(spacing: 2) {
                Text(parts.first ?? "")
                Text(parts.last ?? "")
            }
            .font(.custom(PJS.bold, size: 14, relativeTo: .subheadline))
            .foregroundStyle(isSelected ? Color.progressFill : Color.chipInactiveText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                let shape = RoundedRectangle(cornerRadius: 10)
                shape.fill(Color.progressTrack).overlay {
                    shape.strokeBorder(isSelected ? Color.progressFill : .clear, lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(time)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    ProfileFlow()
        .mindscapeBackground()
        .environment(AppModel())
}
