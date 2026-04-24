import Foundation

enum HuntMethod: String, CaseIterable {
    case softReset = "softReset"
    case masuda = "masuda"
    case radarPokemon = "radarPokemon"
    case rencontreFixe = "rencontreFixe"
    case oeufs = "oeufs"
    case ultraWormhole = "ultraWormhole"
    case masudaChroma = "masudaChroma"

    var displayName: String {
        switch self {
        case .softReset:     return "Soft Reset"
        case .masuda:        return "Méthode Masuda"
        case .radarPokemon:  return "Radar Pokémon"
        case .rencontreFixe: return "Rencontre fixe"
        case .oeufs:         return "Œufs"
        case .ultraWormhole: return "Ultra-Brèche"
        case .masudaChroma:  return "Masuda + Charme Chroma"
        }
    }

    func targetAttempts(hasCharmeChroma: Bool) -> Int {
        switch self {
        case .softReset, .rencontreFixe, .oeufs, .radarPokemon, .ultraWormhole:
            return hasCharmeChroma ? 1365 : 4096
        case .masuda:
            return hasCharmeChroma ? 512 : 683
        case .masudaChroma:
            return 512
        }
    }
}
