import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        NavigationStack {
            Group {
                if sessionStore.sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions Yet",
                        systemImage: "clock.badge.xmark",
                        description: Text("Complete a breathing session to see your history.")
                    )
                } else {
                    List(sessionStore.sessions) { session in
                        SessionRowView(session: session)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
        }
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(session.activityType.accentColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: session.activityType.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(session.activityType.accentColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(session.activityType.rawValue)
                    .font(.headline)
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(session.formattedDuration)
                    .font(.subheadline.bold().monospacedDigit())
                Text(session.breathingPattern.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}
