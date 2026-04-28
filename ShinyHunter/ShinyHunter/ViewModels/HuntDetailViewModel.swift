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
    private var modelContext: ModelContext?
    private let hapticService: HapticService
    private let notificationService: NotificationService
    private let soundService: SoundService
    private let badgeService: BadgeService

    init(
        hunt: PokemonHunt,
        hapticService: HapticService = .shared,
        notificationService: NotificationService = .shared,
        soundService: SoundService = .shared,
        badgeService: BadgeService = .shared
    ) {
        self.hunt = hunt
        self.hapticService = hapticService
        self.notificationService = notificationService
        self.soundService = soundService
        self.badgeService = badgeService
    }

    // Calculé depuis hunt.sessions (observé via @Model)
    var paceDescription: String? {
        let completedSessions = hunt.sessions.filter { $0.endedAt != nil && $0.resetsInSession > 0 }
        guard completedSessions.count >= 2 else { return nil }

        let totalResets = completedSessions.reduce(0) { $0 + $1.resetsInSession }
        let totalSeconds = completedSessions.reduce(0.0) { acc, session in
            guard let end = session.endedAt else { return acc }
            return acc + end.timeIntervalSince(session.startedAt)
        }

        guard totalSeconds > 0, totalResets > 0 else { return nil }

        let resetsPerHour = Double(totalResets) / totalSeconds * 3600
        let remaining = max(0, hunt.targetAttempts - hunt.attempts)
        let hoursRemaining = Double(remaining) / resetsPerHour
        return ShinyMath.paceDescription(resetsPerHour: resetsPerHour, hoursRemaining: hoursRemaining)
    }

    func startSession(context: ModelContext) {
        modelContext = context
        let session = HuntSession()
        context.insert(session)
        hunt.sessions.append(session)
        currentSession = session
    }

    func endSession() {
        guard let session = currentSession else { return }
        if session.resetsInSession == 0, let context = modelContext {
            hunt.sessions.removeAll { $0.id == session.id }
            context.delete(session)
        } else {
            session.endedAt = Date()
        }
        currentSession = nil
    }

    func enableKeepScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    func disableKeepScreenOn() {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func registerNormalReset(allHunts: [PokemonHunt]) {
        hunt.attempts += 1
        currentSession?.resetsInSession += 1
        hunt.lastActivityAt = Date()
        hapticService.normalReset()
        soundService.playNormalReset()
        badgeService.checkAfterReset(hunt: hunt, currentSession: currentSession)
        WidgetBridge.write(hunt: hunt)
        Task { await notificationService.scheduleReminder(for: hunt) }
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

    func confirmShiny(allHunts: [PokemonHunt]) {
        hunt.attempts += 1
        hunt.isShiny = true
        hunt.capturedAt = Date()
        hunt.lastActivityAt = Date()
        endSession()
        hapticService.shinyFound()
        soundService.playShinyFound()
        notificationService.cancelReminder(for: hunt)
        badgeService.checkAfterShiny(hunt: hunt, allHunts: allHunts)
        WidgetBridge.write(hunt: hunt)
    }

    func updateHuntMethod(_ method: HuntMethod) {
        hunt.huntMethod = method.rawValue
        hunt.targetAttempts = method.targetAttempts(hasCharmeChroma: hunt.hasCharmeChroma)
    }

    func updateGame(_ game: PokemonGame) {
        hunt.game = game.rawValue
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

    func processNormalImageData(_ rawData: Data) {
        do {
            hunt.normalImageData = try ImageService.shared.process(rawData)
        } catch {
            self.error = .imageProcessingFailed
            showError = true
            HapticService.shared.error()
        }
    }
}
