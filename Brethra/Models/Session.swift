import Foundation

struct Session: Codable, Identifiable {
    let id: UUID
    let date: Date
    let activityType: ActivityType
    let breathingPattern: BreathingPattern
    let duration: TimeInterval
    let intervalSettings: IntervalSettings?

    init(
        activityType: ActivityType,
        breathingPattern: BreathingPattern,
        duration: TimeInterval,
        intervalSettings: IntervalSettings? = nil
    ) {
        self.id = UUID()
        self.date = Date()
        self.activityType = activityType
        self.breathingPattern = breathingPattern
        self.duration = duration
        self.intervalSettings = intervalSettings
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
