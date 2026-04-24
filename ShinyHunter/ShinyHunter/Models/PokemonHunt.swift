import Foundation
import SwiftData

@Model
final class PokemonHunt {
    var id: UUID
    var pokemonName: String
    var attempts: Int
    var isShiny: Bool
    var imageData: Data?
    var normalImageData: Data?
    var createdAt: Date
    var capturedAt: Date?
    var hasCharmeChroma: Bool
    var targetAttempts: Int
    var lastActivityAt: Date
    // Defaults au niveau déclaration requis pour la migration SwiftData des enregistrements existants
    var game: String = ""
    var huntMethod: String = HuntMethod.softReset.rawValue
    var notes: String = ""
    @Relationship(deleteRule: .cascade)
    var sessions: [HuntSession]

    init(
        pokemonName: String,
        hasCharmeChroma: Bool = false,
        game: PokemonGame = .unspecified,
        huntMethod: HuntMethod = .softReset
    ) {
        self.id = UUID()
        self.pokemonName = pokemonName
        self.attempts = 0
        self.isShiny = false
        self.imageData = nil
        self.normalImageData = nil
        self.createdAt = Date()
        self.capturedAt = nil
        self.hasCharmeChroma = hasCharmeChroma
        self.game = game.rawValue
        self.huntMethod = huntMethod.rawValue
        self.notes = ""
        self.targetAttempts = huntMethod.targetAttempts(hasCharmeChroma: hasCharmeChroma)
        self.lastActivityAt = Date()
        self.sessions = []
    }
}
