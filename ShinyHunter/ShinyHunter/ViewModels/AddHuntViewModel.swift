import Foundation
import SwiftData

@Observable
final class AddHuntViewModel {
    var pokemonName = ""
    var hasCharmeChroma = false
    var imageData: Data?
    var error: AppError?
    var showError = false
    var isLoadingImage = false

    var isFormValid: Bool {
        !pokemonName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var displayRate: String {
        hasCharmeChroma ? "Taux : 1 / 1365" : "Taux : 1 / 4096"
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

    func createHunt(context: ModelContext) {
        let trimmed = pokemonName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            error = .huntNameEmpty
            showError = true
            HapticService.shared.error()
            return
        }
        let hunt = PokemonHunt(pokemonName: trimmed, hasCharmeChroma: hasCharmeChroma)
        hunt.imageData = imageData
        context.insert(hunt)
        Task {
            try? await NotificationService.shared.requestAuthorization()
        }
    }
}
