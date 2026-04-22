import Foundation
import SwiftData

@Model
final class PokemonHunt {
    var id: UUID
    var pokemonName: String
    var attempts: Int
    var isShiny: Bool
    var imageData: Data?
    var createdAt: Date
    var capturedAt: Date?
    var hasCharmeChroma: Bool
    var targetAttempts: Int
    var lastActivityAt: Date
    @Relationship(deleteRule: .cascade)
    var sessions: [HuntSession]

    init(pokemonName: String, hasCharmeChroma: Bool = false) {
        self.id = UUID()
        self.pokemonName = pokemonName
        self.attempts = 0
        self.isShiny = false
        self.imageData = nil
        self.createdAt = Date()
        self.capturedAt = nil
        self.hasCharmeChroma = hasCharmeChroma
        self.targetAttempts = hasCharmeChroma ? 1365 : 4096
        self.lastActivityAt = Date()
        self.sessions = []
    }
}
