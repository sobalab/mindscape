import SwiftUI
import Charts

/// The Insights tab. Wrapped in a stack so the AI observation can push a detail page.
struct InsightsFlow: View {
    @State private var path: [InsightsRoute] = {
        // QA: `-observationDetail` opens straight onto the detail to test its back button.
        ProcessInfo.processInfo.arguments.contains("-observationDetail") ? [.observation] : []
    }()

    var body: some View {
        NavigationStack(path: $path) {
            InsightsScreen()
                .navigationDestination(for: InsightsRoute.self) { route in
                    switch route {
                    // Pop explicitly from the path: with the nav bar hidden, the
                    // environment's `dismiss` doesn't reliably pop a value-pushed view.
                    case .observation: AIObservationDetail { path.removeLast() }
                    }
                }
        }
        .tint(.accentPurple)
    }
}

enum InsightsRoute: Hashable {
    case observation
}

struct InsightsScreen: View {
    @Environment(AppModel.self) private var model
    /// Drives the fill-up animation; flipped on first appear.
    @State private var revealed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenTitle(first: "Your", second: "insights")
                    .padding(.bottom, 12)

                Text("IN THE LAST 30 DAYS")
                    .msStyle(.msEyebrow, tracking: 0.24)
                    .foregroundStyle(.textMuted)
                    .padding(.bottom, 22)

                moodTrendCard.padding(.bottom, 34)

                SectionHeader("TOP THEMES THIS MONTH").padding(.bottom, 18)

                ForEach(Array(model.topThemes.enumerated()), id: \.element.id) { index, theme in
                    ThemeBar(theme: theme, revealed: revealed, index: index)
                        .padding(.bottom, 20)
                }

                observationLink.padding(.top, 14)
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
        .mindscapeBackground()
        .toolbar(.hidden, for: .navigationBar)
        // Grow the graphs each time the tab is opened.
        .onAppear {
            revealed = false
            withAnimation(.easeOut(duration: 0.7)) { revealed = true }
        }
    }

    // MARK: Mood trend

    private var dateRange: String {
        guard let first = model.moodTrend.first?.date,
              let last = model.moodTrend.last?.date else { return "" }
        let format = Date.FormatStyle.dateTime.month(.abbreviated).day()
        return "\(first.formatted(format)) - \(last.formatted(format))"
    }

    /// The design labels three points on the x-axis: start, middle, end.
    private var axisDates: [Date] {
        let dates = model.moodTrend.map(\.date)
        guard let first = dates.first, let last = dates.last else { return [] }
        return [first, dates[dates.count / 2], last]
    }

    private var moodTrendCard: some View {
        PromptCard {
            VStack(alignment: .leading, spacing: 0) {
                Badge(text: "MOOD TREND  ∙  \(dateRange.uppercased())")
                    .padding(.bottom, 20)

                Chart(model.moodTrend) { point in
                    // `cornerRadius` rounds every corner, but the design's bars are
                    // flat-bottomed. Starting each bar below the y-domain lets the plot
                    // area clip the lower curve away. `revealed` scales the height from
                    // zero so the bars grow up on appear.
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        yStart: .value("Base", -0.6),
                        yEnd: .value("Mood", Double(point.score) * (revealed ? 1 : 0)),
                        width: .fixed(19)
                    )
                    // The design highlights the good days; the rest recede.
                    .foregroundStyle(point.score >= 4 ? Color.progressFill : Color.progressTrack)
                    .cornerRadius(10)
                }
                .chartYScale(domain: 0...5.6)
                // Clips the sub-zero part of each bar, leaving flat bottoms.
                .chartPlotStyle { $0.clipped() }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: axisDates) { value in
                        // Anchor the end labels inward so neither is clipped by the card.
                        let anchor: UnitPoint = switch value.index {
                        case 0:                 .topLeading
                        case value.count - 1:   .topTrailing
                        default:                .top
                        }
                        AxisValueLabel(anchor: anchor) {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                    .msStyle(.msSection, tracking: 0.28)
                                    .foregroundStyle(.textMuted)
                            }
                        }
                    }
                }
                .frame(height: 130)
                .accessibilityLabel("Mood trend over the last 30 days")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.vertical, 22)
        }
    }

    // MARK: AI observation

    private var observationLink: some View {
        NavigationLink(value: InsightsRoute.observation) {
            ObservationCard(text: model.aiObservation, showsChevron: true)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens the reasoning behind this observation")
    }
}

/// The teal AI-observation card. Shared by the Insights list (tappable) and the top of
/// the detail page (static).
struct ObservationCard: View {
    let text: String
    var showsChevron: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Image("AIIcon")
                    .resizable()
                    .frame(width: 24.2, height: 24.2)
                Badge(text: "AI OBSERVATION",
                      foreground: Color.observationBadgeText,
                      background: Color.observationBadgeBg)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.observationBadgeText)
                }
            }
            .padding(.bottom, 16)

            Text(text)
                .font(.custom(PJS.extraBold, size: 20, relativeTo: .title3))
                .foregroundStyle(.textPrimary)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 26)
        .padding(.vertical, 22)
        .background {
            let shape = RoundedRectangle(cornerRadius: Theme.cardRadius)
            shape.fill(Color.observationBg).overlay {
                shape.strokeBorder(.tealStroke, lineWidth: 3)
            }
        }
    }
}

/// One "TOP THEMES" row — label, percentage, and a track/fill progress bar that fills
/// in on appear, staggered by row.
struct ThemeBar: View {
    let theme: ThemeStat
    var revealed: Bool = true
    var index: Int = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text(theme.name)
                    .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
                Spacer()
                Text(theme.share.formatted(.percent.precision(.fractionLength(0))))
                    .font(.custom(PJS.semibold, size: 16, relativeTo: .callout))
            }
            .foregroundStyle(.textPrimary)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.progressTrack)
                    Capsule()
                        .fill(Color.progressFill)
                        .frame(width: proxy.size.width * theme.share * (revealed ? 1 : 0))
                        .animation(.easeOut(duration: 0.6).delay(Double(index) * 0.08), value: revealed)
                }
            }
            .frame(height: 7)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(theme.name)
        .accessibilityValue(theme.share.formatted(.percent.precision(.fractionLength(0))))
    }
}

#Preview {
    InsightsFlow().environment(AppModel())
}
