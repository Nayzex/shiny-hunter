import Foundation

@Observable
final class SettingsViewModel {
    var notificationDelayDays: Int {
        didSet {
            UserDefaults.standard.set(notificationDelayDays, forKey: "notificationDelayDays")
            notificationService.cancelAllReminders()
        }
    }

    let availableDelays = [1, 2, 3, 7]

    private let notificationService: NotificationService

    init(notificationService: NotificationService = .shared) {
        self.notificationService = notificationService
        let stored = UserDefaults.standard.integer(forKey: "notificationDelayDays")
        notificationDelayDays = stored > 0 ? stored : 3
    }
}
