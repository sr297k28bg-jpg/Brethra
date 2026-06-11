import SwiftUI

struct BreathingSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionStore: SessionStore

    let activityType: ActivityType
    let intervalSettings: IntervalSettings

    @StateObject private var viewModel: BreathingSessionViewModel
    @State private var showEndConfirm = false

    init(
        activityType: ActivityType,
        breathingPattern: BreathingPattern,
        intervalSettings: IntervalSettings,
        soundEnabled: Bool,
        vibrationEnabled: Bool
    ) {
        self.activityType = activityType
        self.intervalSettings = intervalSettings
        _viewModel = StateObject(wrappedValue: BreathingSessionViewModel(
            breathingPattern: breathingPattern,
            intervalSettings: intervalSettings,
            soundEnabled: soundEnabled,
            vibrationEnabled: vibrationEnabled
        ))
    }

    var body: some View {
        ZStack {
            background
            VStack(spacing: 0) {
                header
                Spacer()
                breathingCircle
                Spacer()
                phaseLabel
                    .padding(.top, 24)
                Spacer()
                tapSyncButton
                timerLabel
                endButton
                    .padding(.bottom, 44)
            }
        }
        .ignoresSafeArea()
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .confirmationDialog("End Session?", isPresented: $showEndConfirm, titleVisibility: .visible) {
            Button("End Session", role: .destructive) { endSession() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var background: some View {
        LinearGradient(
            colors: viewModel.phase == .inhale
                ? [Color(red: 0.1, green: 0.3, blue: 0.85), Color(red: 0.2, green: 0.1, blue: 0.7)]
                : [Color(red: 0.05, green: 0.55, blue: 0.6), Color(red: 0.1, green: 0.35, blue: 0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: viewModel.phase.label)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label(activityType.rawValue, systemImage: activityType.icon)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(viewModel.breathingPattern.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 24)
    }

    private var breathingCircle: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.08))
                .frame(width: 260, height: 260)

            Circle()
                .fill(.white.opacity(0.13))
                .frame(width: 210, height: 210)
                .scaleEffect(viewModel.animationScale)

            Circle()
                .stroke(.white.opacity(0.25), lineWidth: 2)
                .frame(width: 230, height: 230)

            Circle()
                .trim(from: 0, to: viewModel.phaseProgress)
                .stroke(
                    .white,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 230, height: 230)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.05), value: viewModel.phaseProgress)
        }
    }

    private var phaseLabel: some View {
        Text(viewModel.phase.label)
            .font(.system(size: 44, weight: .thin, design: .rounded))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.3), value: viewModel.phase.label)
    }

    private var tapSyncButton: some View {
        Button {
            viewModel.handleTap()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "hand.tap")
                Text("Tap to sync steps")
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.75))
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(.white.opacity(0.15), in: Capsule())
        }
        .padding(.bottom, 20)
    }

    private var timerLabel: some View {
        Text(viewModel.formattedDuration)
            .font(.system(size: 34, weight: .light, design: .monospaced))
            .foregroundStyle(.white)
            .padding(.bottom, 28)
    }

    private var endButton: some View {
        Button {
            showEndConfirm = true
        } label: {
            Text("End Session")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 44)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        }
    }

    private func endSession() {
        viewModel.stop()
        if viewModel.sessionDuration >= 5 {
            let session = Session(
                activityType: activityType,
                breathingPattern: viewModel.breathingPattern,
                duration: viewModel.sessionDuration,
                intervalSettings: intervalSettings.isEnabled ? intervalSettings : nil
            )
            sessionStore.save(session: session)
        }
        dismiss()
    }
}
