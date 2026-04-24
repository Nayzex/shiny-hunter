import Foundation
import UserNotifications

@Observable
final class BadgeService {
    static let shared = BadgeService()

    private(set) var unlockedBadges: Set<Badge>
    private let userDefaultsKey = "unlockedBadges"

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: "unlockedBadges") ?? []
        unlockedBadges = Set(stored.compactMap { Badge(rawValue: $0) })
    }

    /// Appelé après chaque reset. `hunt.attempts` est déjà incrémenté à ce stade.
    func checkAfterReset(hunt: PokemonHunt, currentSession: HuntSession?) {
        if hunt.attempts > 4096 { tryUnlock(.perseverant) }
        if let session = currentSession, session.resetsInSession >= 100 { tryUnlock(.enFeu) }
    }

    /// Appelé après la confirmation du shiny. `hunt.isShiny` est déjà `true` à ce stade.
    func checkAfterShiny(hunt: PokemonHunt, allHunts: [PokemonHunt]) {
        let shiniesCount = allHunts.filter { $0.isShiny }.count
        if shiniesCount == 1 { tryUnlock(.premierShiny) }
        if hunt.attempts <= 1 { tryUnlock(.ultraChanceux) }
        if hunt.attempts < 100 { tryUnlock(.chanceux) }
        if shiniesCount >= 5 { tryUnlock(.collectionneur) }
        if shiniesCount >= 10 { tryUnlock(.maitrePokemon) }
    }

    /// Appelé avant l'insertion de la nouvelle chasse. `allHunts` est la liste existante.
    func checkAfterCreation(allHunts: [PokemonHunt]) {
        if allHunts.isEmpty { tryUnlock(.premierPas) }
    }

    private func tryUnlock(_ badge: Badge) {
        guard !unlockedBadges.contains(badge) else { return }
        unlockedBadges.insert(badge)
        persist()
        Task { await sendNotification(for: badge) }
    }

    private func persist() {
        UserDefaults.standard.set(unlockedBadges.map { $0.rawValue }, forKey: userDefaultsKey)
    }

    private func sendNotification(for badge: Badge) async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "Badge débloqué !"
        content.body = "\(badge.emoji) \(badge.title) — \(badge.badgeDescription)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "badge_\(badge.rawValue)",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }
}
