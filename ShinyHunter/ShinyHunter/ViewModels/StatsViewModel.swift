import Foundation

@Observable
final class StatsViewModel {
    func totalResets(from hunts: [PokemonHunt]) -> Int {
        hunts.reduce(0) { $0 + $1.attempts }
    }

    func shiniesFound(from hunts: [PokemonHunt]) -> [PokemonHunt] {
        hunts.filter { $0.isShiny }
    }

    func bestHunt(from hunts: [PokemonHunt]) -> PokemonHunt? {
        hunts.filter { $0.isShiny }.min { $0.attempts < $1.attempts }
    }

    func worstHunt(from hunts: [PokemonHunt]) -> PokemonHunt? {
        hunts.filter { $0.isShiny }.max { $0.attempts < $1.attempts }
    }

    func averageResets(from hunts: [PokemonHunt]) -> Double {
        let shinies = hunts.filter { $0.isShiny }
        guard !shinies.isEmpty else { return 0 }
        return Double(shinies.reduce(0) { $0 + $1.attempts }) / Double(shinies.count)
    }

    func overallLuckRating(from hunts: [PokemonHunt]) -> String {
        let shinies = hunts.filter { $0.isShiny }
        guard !shinies.isEmpty else { return "Pas encore de données" }
        let avg = Int(averageResets(from: hunts))
        let avgRate = shinies.map { $0.targetAttempts }.reduce(0, +) / shinies.count
        return ShinyMath.luckRating(attempts: avg, rate: avgRate)
    }
}
