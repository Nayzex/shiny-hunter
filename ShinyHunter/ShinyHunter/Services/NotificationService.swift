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
    /// - Parameters:
    ///   - hunt: La chasse pour laquelle planifier le rappel.
    ///   - afterDays: Nombre de jours d'inactivité avant la notification.
    func scheduleReminder(for hunt: PokemonHunt, afterDays: Int) async {
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
