import SwiftUI

struct HomeView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State private var showSetup = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 120, height: 120)
                        Image(systemName: "wind")
                            .font(.system(size: 52))
                            .foregroundStyle(.blue)
                    }

                    Text("Brethra")
                        .font(.system(size: 36, weight: .bold))

                    Text("Breathe with purpose")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let last = sessionStore.sessions.first {
                    lastSessionCard(last)
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                }

                Button {
                    showSetup = true
                } label: {
                    Label("Start Session", systemImage: "play.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(.blue, in: RoundedRectangle(cornerRadius: 18))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showSetup) {
                SetupSessionView()
            }
        }
    }

    @ViewBuilder
    private func lastSessionCard(_ session: Session) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last session")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 14) {
                Image(systemName: session.activityType.icon)
                    .font(.title3)
                    .foregroundStyle(session.activityType.accentColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.activityType.rawValue)
                        .font(.subheadline.bold())
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(session.formattedDuration)
                        .font(.subheadline.bold().monospacedDigit())
                    Text(session.breathingPattern.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
    }
}
