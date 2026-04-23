import Foundation
import SwiftData
import UIKit

@Observable
final class HuntDetailViewModel {
    private(set) var currentSession: HuntSession?
    var showShinyConfirmation = false
    var error: AppError?
    var showError = false

    private let hunt: PokemonHunt
    private let hapticService: HapticService
    private let notificationService: NotificationService
    private let soundService: SoundService

    init(
        hunt: PokemonHunt,
        hapticService: HapticService = .shared,
        notificationService: NotificationService = .shared,
        soundService: SoundService = .shared
    ) {
        self.hunt = hunt
        self.hapticService = hapticService
        self.notificationService = notificationService
        self.soundService = soundService
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

    func enableKeepScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func disableKeepScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func registerNormalReset() {
        hunt.attempts += 1
        currentSession?.resetsInSession += 1
        hunt.lastActivityAt = Date()
        hapticService.normalReset()
        soundService.playNormalReset()
        Task { await notificationService.scheduleReminder(for: hunt, afterDays: 3) }
    }

    func registerUndoReset() {
        guard hunt.attempts > 0 else { return }
        hunt.attempts -= 1
        if let session = currentSession {
            session.resetsInSession = max(0, session.resetsInSession - 1)
        }
        hunt.lastActivityAt = Date()
        hapticService.buttonTap()
    }

    func confirmShiny() {
        hunt.attempts += 1
        hunt.isShiny = true
        hunt.capturedAt = Date()
        hunt.lastActivityAt = Date()
        endSession()
        hapticService.shinyFound()
        soundService.playShinyFound()
        notificationService.cancelReminder(for: hunt)
    }

    func processRawImageData(_ rawData: Data) {
        do {
            hunt.imageData = try ImageService.shared.process(rawData)
        } catch {
            self.error = .imageProcessingFailed
            showError = true
            HapticService.shared.error()
        }
    }
}
