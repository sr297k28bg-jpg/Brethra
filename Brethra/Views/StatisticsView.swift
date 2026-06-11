import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    sessionsChart
                    durationChart
                }
                .padding()
            }
            .navigationTitle("Statistics")
        }
    }

    private var summaryCards: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Sessions",
                value: "\(sessionStore.sessions.count)",
                icon: "calendar.badge.checkmark",
                color: .blue
            )
            StatCard(
                title: "Total Time",
                value: formattedTotal,
                icon: "clock",
                color: .green
            )
            StatCard(
                title: "Top Pattern",
                value: sessionStore.mostUsedPattern?.displayName ?? "—",
                icon: "wind",
                color: .orange
            )
        }
    }

    private var sessionsChart: some View {
        let data = sessionStore.sessionsPerDay()
        return ChartCard(title: "Sessions per Day") {
            Chart(data, id: \.0) { item in
                BarMark(
                    x: .value("Day", item.0, unit: .day),
                    y: .value("Sessions", item.1)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(5)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 160)
        }
    }

    private var durationChart: some View {
        let data = sessionStore.durationPerDay()
        return ChartCard(title: "Duration per Day (min)") {
            Chart(data, id: \.0) { item in
                BarMark(
                    x: .value("Day", item.0, unit: .day),
                    y: .value("Minutes", item.1 / 60)
                )
                .foregroundStyle(Color.green.gradient)
                .cornerRadius(5)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.narrow))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 160)
        }
    }

    private var formattedTotal: String {
        let total = Int(sessionStore.totalTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}
