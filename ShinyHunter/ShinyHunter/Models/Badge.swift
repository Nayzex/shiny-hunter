import Foundation

enum Badge: String, CaseIterable {
    case premierPas = "premierPas"
    case premierShiny = "premierShiny"
    case chanceux = "chanceux"
    case perseverant = "perseverant"
    case enFeu = "enFeu"
    case collectionneur = "collectionneur"
    case maitrePokemon = "maitrePokemon"
    case ultraChanceux = "ultraChanceux"

    var emoji: String {
        switch self {
        case .premierPas:    return "🥚"
        case .premierShiny:  return "✨"
        case .chanceux:      return "🍀"
        case .perseverant:   return "💪"
        case .enFeu:         return "🔥"
        case .collectionneur: return "🎯"
        case .maitrePokemon: return "👑"
        case .ultraChanceux: return "⚡"
        }
    }

    var title: String {
        switch self {
        case .premierPas:    return "Premier pas"
        case .premierShiny:  return "Premier shiny"
        case .chanceux:      return "Chanceux"
        case .perseverant:   return "Persévérant"
        case .enFeu:         return "En feu"
        case .collectionneur: return "Collectionneur"
        case .maitrePokemon: return "Maître Shiny"
        case .ultraChanceux: return "Ultra Chanceux"
        }
    }

    var badgeDescription: String {
        switch self {
        case .premierPas:    return "Créer ta première chasse"
        case .premierShiny:  return "Capturer ton premier shiny"
        case .chanceux:      return "Shiny en moins de 100 resets"
        case .perseverant:   return "Dépasser 4096 resets"
        case .enFeu:         return "100 resets dans une session"
        case .collectionneur: return "5 shinies capturés"
        case .maitrePokemon: return "10 shinies capturés"
        case .ultraChanceux: return "Shiny au premier essai"
        }
    }
}
