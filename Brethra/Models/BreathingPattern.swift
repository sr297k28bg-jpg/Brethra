import Foundation

enum BreathingPattern: Equatable {
    case twoTwo
    case threeThree
    case custom(inhale: Int, exhale: Int)

    var inhale: Int {
        switch self {
        case .twoTwo: return 2
        case .threeThree: return 3
        case .custom(let i, _): return i
        }
    }

    var exhale: Int {
        switch self {
        case .twoTwo: return 2
        case .threeThree: return 3
        case .custom(_, let e): return e
        }
    }

    var displayName: String {
        "\(inhale):\(exhale)"
    }

    var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

    static var presets: [BreathingPattern] { [.twoTwo, .threeThree] }
}

extension BreathingPattern: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, inhale, exhale
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .twoTwo:
            try container.encode("twoTwo", forKey: .type)
        case .threeThree:
            try container.encode("threeThree", forKey: .type)
        case .custom(let i, let e):
            try container.encode("custom", forKey: .type)
            try container.encode(i, forKey: .inhale)
            try container.encode(e, forKey: .exhale)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "twoTwo":
            self = .twoTwo
        case "threeThree":
            self = .threeThree
        default:
            let i = try container.decode(Int.self, forKey: .inhale)
            let e = try container.decode(Int.self, forKey: .exhale)
            self = .custom(inhale: i, exhale: e)
        }
    }
}
