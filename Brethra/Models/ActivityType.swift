import SwiftUI

enum ActivityType: String, CaseIterable, Codable {
    case running = "Running"
    case gym = "Gym"
    case hiit = "HIIT"
    case recovery = "Recovery"

    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .gym: return "dumbbell"
        case .hiit: return "bolt.heart"
        case .recovery: return "leaf"
        }
    }

    var defaultPattern: BreathingPattern {
        switch self {
        case .running: return .twoTwo
        case .gym: return .threeThree
        case .hiit: return .twoTwo
        case .recovery: return .threeThree
        }
    }

    var accentColor: Color {
        switch self {
        case .running: return .blue
        case .gym: return .orange
        case .hiit: return .red
        case .recovery: return .green
        }
    }
}
