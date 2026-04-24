import Foundation
import SwiftData

@Observable
final class AddHuntViewModel {
    var pokemonName = ""
    var hasCharmeChroma = false
    var imageData: Data?
    var selectedGame: PokemonGame = .unspecified
    var selectedMethod: HuntMethod = .softReset
    var error: AppError?
    var showError = false
    var isLoadingImage = false

    var isFormValid: Bool {
        !pokemonName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var displayRate: String {
        let target = selectedMethod.targetAttempts(hasCharmeChroma: hasCharmeChroma)
        return "Taux : 1 / \(target)"
    }

    func processRawImageData(_ rawData: Data) {
        do {
            imageData = try ImageService.shared.process(rawData)
        } catch {
            self.error = .imageProcessingFailed
            showError = true
            HapticService.shared.error()
        }
        isLoadingImage = false
    }

    func createHunt(context: ModelContext, allHunts: [PokemonHunt]) {
        let trimmed = pokemonName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            error = .huntNameEmpty
            showError = true
            HapticService.shared.error()
            return
        }
        BadgeService.shared.checkAfterCreation(allHunts: allHunts)
        let hunt = PokemonHunt(
            pokemonName: trimmed,
            hasCharmeChroma: hasCharmeChroma,
            game: selectedGame,
            huntMethod: selectedMethod
        )
        hunt.normalImageData = imageData
        context.insert(hunt)
        Task {
            try? await NotificationService.shared.requestAuthorization()
        }
    }
}
