import Foundation

struct IntervalSettings: Codable, Equatable {
    var isEnabled: Bool = false
    var highIntensityDuration: Int = 30
    var lowIntensityDuration: Int = 30
}
