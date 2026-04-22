import Foundation
import SwiftData

@Observable
final class HuntListViewModel {
    var showDeleteConfirmation = false
    var huntToDelete: PokemonHunt?
    var showAddHunt = false

    func requestDelete(_ hunt: PokemonHunt) {
        huntToDelete = hunt
        showDeleteConfirmation = true
    }

    func confirmDelete(context: ModelContext) {
        guard let hunt = huntToDelete else { return }
        NotificationService.shared.cancelReminder(for: hunt)
        context.delete(hunt)
        huntToDelete = nil
        showDeleteConfirmation = false
    }

    func cancelDelete() {
        huntToDelete = nil
        showDeleteConfirmation = false
    }
}
