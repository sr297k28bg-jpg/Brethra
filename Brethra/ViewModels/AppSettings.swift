import Foundation
import UserNotifications

class AppSettings: ObservableObject {
    @Published var soundEnabled: Bool {
        didSet { UserDefaults.standard.set(soundEnabled, forKey: "sound_enabled") }
    }
    @Published var vibrationEnabled: Bool {
        didSet { UserDefaults.standard.set(vibrationEnabled, forKey: "vibration_enabled") }
    }
    @Published var darkMode: Bool {
        didSet { UserDefaults.standard.set(darkMode, forKey: "dark_mode") }
    }
    @Published var reminderEnabled: Bool {
        didSet {
            UserDefaults.standard.set(reminderEnabled, forKey: "reminder_enabled")
            reminderEnabled ? scheduleReminder() : cancelReminder()
        }
    }
    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime, forKey: "reminder_time")
            if reminderEnabled { scheduleReminder() }
        }
    }

    init() {
        soundEnabled = UserDefaults.standard.object(forKey: "sound_enabled") as? Bool ?? true
        vibrationEnabled = UserDefaults.standard.object(forKey: "vibration_enabled") as? Bool ?? true
        darkMode = UserDefaults.standard.object(forKey: "dark_mode") as? Bool ?? false
        reminderEnabled = UserDefaults.standard.object(forKey: "reminder_enabled") as? Bool ?? false
        reminderTime = UserDefaults.standard.object(forKey: "reminder_time") as? Date ?? {
            var c = DateComponents()
            c.hour = 9
            c.minute = 0
            return Calendar.current.date(from: c) ?? Date()
        }()
    }

    func requestNotificationPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    private func scheduleReminder() {
        cancelReminder()
        let content = UNMutableNotificationContent()
        content.title = "Brethra"
        content.body = "Time for your breathing training!"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "brethra_daily_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["brethra_daily_reminder"])
    }
}
