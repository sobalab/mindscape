import SwiftUI
import Charts

struct InsightsScreen: View {
    @Environment(AppModel.self) private var model

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

                ForEach(model.topThemes) { theme in
                    ThemeBar(theme: theme).padding(.bottom, 20)
                }

                observationCard.padding(.top, 14)
            }
            .padding(.horizontal, Theme.screenInset)
            .padding(.top, 12)
            .padding(.bottom, Theme.tabBarClearance)
        }
        .scrollIndicators(.hidden)
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
                    // area clip the lower curve away.
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        yStart: .value("Base", -0.6),
                        yEnd: .value("Mood", Double(point.score)),
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

    private var observationCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 7) {
                Image("AIIcon")
                    .resizable()
                    .frame(width: 24.2, height: 24.2)
                Badge(text: "AI OBSERVATION",
                      foreground: Color.observationBadgeText,
                      background: Color.observationBadgeBg)
            }
            .padding(.bottom, 16)

            Text(model.aiObservation)
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

/// One "TOP THEMES" row — label, percentage, and a track/fill progress bar.
struct ThemeBar: View {
    let theme: ThemeStat

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
                        .frame(width: proxy.size.width * theme.share)
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
    InsightsScreen()
        .frame(maxHeight: .infinity)
        .mindscapeBackground()
        .environment(AppModel())
}
