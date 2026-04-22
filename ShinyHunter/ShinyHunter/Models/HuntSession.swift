import Foundation
import SwiftData

@Model
final class HuntSession {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var resetsInSession: Int
    var hunt: PokemonHunt?

    init() {
        self.id = UUID()
        self.startedAt = Date()
        self.endedAt = nil
        self.resetsInSession = 0
    }
}
