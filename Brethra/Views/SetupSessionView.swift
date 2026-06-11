import SwiftUI

struct SetupSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: AppSettings

    @State private var selectedActivity: ActivityType = .running
    @State private var selectedPattern: BreathingPattern = .twoTwo
    @State private var isCustomPattern = false

    @State private var customInhaleText: String = "3"
    @State private var customExhaleText: String = "3"
    @State private var customInhale: Int = 3
    @State private var customExhale: Int = 3
    @State private var inhaleError: String? = nil
    @State private var exhaleError: String? = nil

    @State private var intervalSettings = IntervalSettings()
    @State private var highDurationText: String = "30"
    @State private var lowDurationText: String = "30"
    @State private var highDurationError: String? = nil
    @State private var lowDurationError: String? = nil

    @State private var showSession = false

    private var isFormValid: Bool {
        inhaleError == nil && exhaleError == nil &&
        highDurationError == nil && lowDurationError == nil
    }

    private var resolvedPattern: BreathingPattern {
        isCustomPattern ? .custom(inhale: customInhale, exhale: customExhale) : selectedPattern
    }

    var body: some View {
        NavigationStack {
            Form {
                activitySection
                patternSection
                if isCustomPattern {
                    customPatternSection
                }
                intervalToggleSection
                if intervalSettings.isEnabled {
                    intervalSettingsSection
                }
            }
            .navigationTitle("Setup Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                startButton
            }
            .fullScreenCover(isPresented: $showSession) {
                BreathingSessionView(
                    activityType: selectedActivity,
                    breathingPattern: resolvedPattern,
                    intervalSettings: intervalSettings,
                    soundEnabled: settings.soundEnabled,
                    vibrationEnabled: settings.vibrationEnabled
                )
            }
        }
    }

    private var activitySection: some View {
        Section("Activity Type") {
            ForEach(ActivityType.allCases, id: \.self) { type in
                HStack {
                    Image(systemName: type.icon)
                        .foregroundStyle(type.accentColor)
                        .frame(width: 26)
                    Text(type.rawValue)
                    Spacer()
                    if selectedActivity == type {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedActivity = type
                    if !isCustomPattern {
                        selectedPattern = type.defaultPattern
                    }
                }
            }
        }
    }

    private var patternSection: some View {
        Section("Breathing Pattern") {
            ForEach(BreathingPattern.presets, id: \.displayName) { pattern in
                HStack {
                    Text(pattern.displayName)
                        .fontWeight(.medium)
                    Text("· \(pattern.inhale)s inhale / \(pattern.exhale)s exhale")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !isCustomPattern && selectedPattern == pattern {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedPattern = pattern
                    isCustomPattern = false
                    inhaleError = nil
                    exhaleError = nil
                }
            }

            HStack {
                Text("Custom")
                Spacer()
                if isCustomPattern {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                        .fontWeight(.semibold)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isCustomPattern = true
                validateInhale(customInhaleText)
                validateExhale(customExhaleText)
            }
        }
    }

    private var customPatternSection: some View {
        Section("Custom Pattern") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Inhale (sec)")
                    Spacer()
                    TextField("1–10", text: $customInhaleText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 64)
                        .onChange(of: customInhaleText) { _, val in validateInhale(val) }
                }
                if let err = inhaleError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Exhale (sec)")
                    Spacer()
                    TextField("1–10", text: $customExhaleText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 64)
                        .onChange(of: customExhaleText) { _, val in validateExhale(val) }
                }
                if let err = exhaleError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var intervalToggleSection: some View {
        Section("Interval Mode") {
            Toggle(isOn: $intervalSettings.isEnabled) {
                Label("Enable Intervals", systemImage: "repeat")
            }
        }
    }

    private var intervalSettingsSection: some View {
        Section("Interval Settings") {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("High Intensity (sec)")
                    Spacer()
                    TextField("10–300", text: $highDurationText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                        .onChange(of: highDurationText) { _, val in validateHigh(val) }
                }
                if let err = highDurationError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Low Intensity (sec)")
                    Spacer()
                    TextField("10–300", text: $lowDurationText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                        .onChange(of: lowDurationText) { _, val in validateLow(val) }
                }
                if let err = lowDurationError {
                    Text(err).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var startButton: some View {
        Button {
            applySettings()
            showSession = true
        } label: {
            Text("Start")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    isFormValid ? Color.blue : Color.gray.opacity(0.4),
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .foregroundStyle(isFormValid ? .white : .secondary)
        }
        .disabled(!isFormValid)
        .padding()
        .background(.regularMaterial)
    }

    private func applySettings() {
        if intervalSettings.isEnabled {
            intervalSettings.highIntensityDuration = Int(highDurationText) ?? 30
            intervalSettings.lowIntensityDuration = Int(lowDurationText) ?? 30
        }
    }

    private func validateInhale(_ val: String) {
        if let n = Int(val), (1...10).contains(n) {
            customInhale = n
            inhaleError = nil
        } else {
            inhaleError = "Must be between 1 and 10"
        }
    }

    private func validateExhale(_ val: String) {
        if let n = Int(val), (1...10).contains(n) {
            customExhale = n
            exhaleError = nil
        } else {
            exhaleError = "Must be between 1 and 10"
        }
    }

    private func validateHigh(_ val: String) {
        if let n = Int(val), (10...300).contains(n) {
            intervalSettings.highIntensityDuration = n
            highDurationError = nil
        } else {
            highDurationError = "Must be between 10 and 300"
        }
    }

    private func validateLow(_ val: String) {
        if let n = Int(val), (10...300).contains(n) {
            intervalSettings.lowIntensityDuration = n
            lowDurationError = nil
        } else {
            lowDurationError = "Must be between 10 and 300"
        }
    }
}
