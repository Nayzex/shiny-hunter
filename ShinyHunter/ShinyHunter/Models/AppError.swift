import Foundation

enum AppError: LocalizedError {
    case imageProcessingFailed
    case notificationPermissionDenied
    case huntNameEmpty
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Impossible de traiter l'image sélectionnée."
        case .notificationPermissionDenied:
            return "Les notifications sont désactivées. Active-les dans les Réglages."
        case .huntNameEmpty:
            return "Le nom du Pokémon ne peut pas être vide."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
