import Foundation
import WidgetKit

// Pont entre l'app principale et le widget : écriture en App Group + rafraîchissement des timelines
enum WidgetBridge {
    private static let appGroupID = "group.com.nayzex.shinyhunter"
    private static let huntDataKey = "widgetHuntData"

    static func write(hunt: PokemonHunt) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        let payload: [String: Any] = [
            "pokemonName": hunt.pokemonName,
            "attempts": hunt.attempts,
            "targetAttempts": hunt.targetAttempts,
            "huntID": hunt.id.uuidString
        ]
        if let encoded = try? JSONSerialization.data(withJSONObject: payload) {
            defaults.set(encoded, forKey: huntDataKey)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
