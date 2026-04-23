import UserNotifications
import Foundation

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func requestAuthorization() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound])
        if !granted {
            throw AppError.notificationPermissionDenied
        }
    }

    /// Planifie une notification de rappel pour une chasse inactive.
    /// Le délai est lu depuis UserDefaults (clé `notificationDelayDays`, défaut 3 jours).
    func scheduleReminder(for hunt: PokemonHunt) async {
        let stored = UserDefaults.standard.integer(forKey: "notificationDelayDays")
        let afterDays = stored > 0 ? stored : 3

        let center = UNUserNotificationCenter.current()
        let identifier = hunt.id.uuidString

        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Shiny Hunter"
        content.body = "🎯 \(hunt.pokemonName) t'attend ! Tu n'as pas chassé depuis \(afterDays) jours."
        content.sound = .default

        let secondsPerDay: Double = 86400
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: Double(afterDays) * secondsPerDay,
            repeats: false
        )

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelReminder(for hunt: PokemonHunt) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [hunt.id.uuidString])
    }

    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
