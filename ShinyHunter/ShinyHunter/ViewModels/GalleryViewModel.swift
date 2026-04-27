import Foundation

@Observable
final class GalleryViewModel {
    var selectedGame: PokemonGame = .unspecified

    func filteredHunts(from hunts: [PokemonHunt]) -> [PokemonHunt] {
        guard selectedGame != .unspecified else { return hunts }
        return hunts.filter { $0.game == selectedGame.rawValue }
    }

    func availableGames(from hunts: [PokemonHunt]) -> [PokemonGame] {
        let games = Set(
            hunts
                .compactMap { PokemonGame(rawValue: $0.game) }
                .filter { $0 != .unspecified }
        )
        return [.unspecified] + games.sorted { $0.displayName < $1.displayName }
    }
}
