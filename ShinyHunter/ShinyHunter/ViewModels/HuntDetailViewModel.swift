import Foundation
import SwiftData
import PhotosUI

@Observable
final class HuntDetailViewModel {
    private(set) var currentSession: HuntSession?
    var showShinyConfirmation = false
    var error: AppError?
    var showError = false

    private let hunt: PokemonHunt
    private let hapticService: HapticService
    private let notificationService: NotificationService

    init(
        hunt: PokemonHunt,
        hapticService: HapticService = .shared,
        notificationService: NotificationService = .shared
    ) {
        self.hunt = hunt
        self.hapticService = hapticService
        self.notificationService = notificationService
    }

    func startSession(context: ModelContext) {
        let session = HuntSession()
        context.insert(session)
        hunt.sessions.append(session)
        currentSession = session
    }

    func endSession() {
        guard let session = currentSession else { return }
        session.endedAt = Date()
        currentSession = nil
    }

    func registerNormalReset() {
        hunt.attempts += 1
        currentSession?.resetsInSession += 1
        hunt.lastActivityAt = Date()
        hapticService.normalReset()
        Task { await notificationService.scheduleReminder(for: hunt, afterDays: 3) }
    }

    func confirmShiny(context: ModelContext) {
        hunt.attempts += 1
        hunt.isShiny = true
        hunt.capturedAt = Date()
        hunt.lastActivityAt = Date()
        endSession()
        hapticService.shinyFound()
        notificationService.cancelReminder(for: hunt)
    }

    func updatePhoto(_ item: PhotosPickerItem) {
        Task {
            do {
                hunt.imageData = try await ImageService.shared.process(item)
            } catch {
                self.error = .imageProcessingFailed
                showError = true
                HapticService.shared.error()
            }
        }
    }
}
