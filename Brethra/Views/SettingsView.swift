import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showNotificationDenied = false

    var body: some View {
        NavigationStack {
            Form {
                feedbackSection
                appearanceSection
                remindersSection
                appInfoSection
            }
            .navigationTitle("Settings")
            .alert("Notifications Disabled", isPresented: $showNotificationDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    settings.reminderEnabled = false
                }
            } message: {
                Text("Please enable notifications in Settings to use reminders.")
            }
        }
    }

    private var feedbackSection: some View {
        Section("Feedback") {
            Toggle(isOn: $settings.soundEnabled) {
                Label("Sound", systemImage: "speaker.wave.2")
            }
            Toggle(isOn: $settings.vibrationEnabled) {
                Label("Vibration", systemImage: "waveform.path")
            }
        }
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Toggle(isOn: $settings.darkMode) {
                Label("Dark Theme", systemImage: "moon.fill")
            }
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle(isOn: Binding(
                get: { settings.reminderEnabled },
                set: { newValue in
                    if newValue {
                        settings.requestNotificationPermission { granted in
                            if granted {
                                settings.reminderEnabled = true
                            } else {
                                showNotificationDenied = true
                            }
                        }
                    } else {
                        settings.reminderEnabled = false
                    }
                }
            )) {
                Label("Daily Reminder", systemImage: "bell")
            }

            if settings.reminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: $settings.reminderTime,
                    displayedComponents: .hourAndMinute
                )
            }
        }
    }

    private var appInfoSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
