import SwiftUI

enum AccentColorOption: String, CaseIterable {
    case gold = "or"
    case red = "rouge"
    case blue = "bleu"
    case green = "vert"
    case purple = "violet"
    case pink = "rose"

    var color: Color {
        switch self {
        case .gold:   return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .red:    return .red
        case .blue:   return .blue
        case .green:  return .green
        case .purple: return .purple
        case .pink:   return .pink
        }
    }

    var displayName: String {
        switch self {
        case .gold:   return "Or"
        case .red:    return "Rouge"
        case .blue:   return "Bleu"
        case .green:  return "Vert"
        case .purple: return "Violet"
        case .pink:   return "Rose"
        }
    }
}

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    var selectedOption: AccentColorOption {
        didSet { UserDefaults.standard.set(selectedOption.rawValue, forKey: "accentColorName") }
    }

    var accentColor: Color { selectedOption.color }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "accentColorName")
        selectedOption = AccentColorOption(rawValue: stored ?? "") ?? .gold
    }
}
