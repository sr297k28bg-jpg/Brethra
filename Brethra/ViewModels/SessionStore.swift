import Foundation
import Combine

class SessionStore: ObservableObject {
    @Published var sessions: [Session] = []

    private let storageKey = "brethra_sessions"

    init() {
        load()
    }

    func save(session: Session) {
        sessions.insert(session, at: 0)
        persist()
    }

    var totalTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }

    var mostUsedPattern: BreathingPattern? {
        let grouped = Dictionary(grouping: sessions, by: { $0.breathingPattern.displayName })
        guard let topKey = grouped.max(by: { $0.value.count < $1.value.count })?.key else { return nil }
        return sessions.first(where: { $0.breathingPattern.displayName == topKey })?.breathingPattern
    }

    func sessionsPerDay(lastDays: Int = 7) -> [(Date, Int)] {
        let calendar = Calendar.current
        return (0..<lastDays).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let day = calendar.startOfDay(for: date)
            let count = sessions.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            return (day, count)
        }
    }

    func durationPerDay(lastDays: Int = 7) -> [(Date, TimeInterval)] {
        let calendar = Calendar.current
        return (0..<lastDays).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let day = calendar.startOfDay(for: date)
            let total = sessions
                .filter { calendar.isDate($0.date, inSameDayAs: day) }
                .reduce(0) { $0 + $1.duration }
            return (day, total)
        }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let saved = try? JSONDecoder().decode([Session].self, from: data)
        else { return }
        sessions = saved
    }
}
