import Foundation

enum PokemonGame: String, CaseIterable {
    case unspecified = ""
    case rougeBleuJaune = "Rouge / Bleu / Jaune"
    case orArgentCristal = "Or / Argent / Cristal"
    case rubisSaphirEmeraude = "Rubis / Saphir / Émeraude"
    case diamantPerlePlatine = "Diamant / Perle / Platine"
    case hgss = "HeartGold / SoulSilver"
    case noirBlanc = "Noir / Blanc"
    case noirBlanc2 = "Noir 2 / Blanc 2"
    case xy = "X / Y"
    case rosa = "Rubis Oméga / Saphir Alpha"
    case slUsla = "Soleil / Lune / Ultra-Soleil / Ultra-Lune"
    case epeeBouclier = "Épée / Bouclier"
    case bdsp = "Diamant Étincelant / Perle Scintillante"
    case legendesArceus = "Légendes Pokémon : Arceus"
    case ecarlateViolet = "Écarlate / Violet"

    var displayName: String {
        self == .unspecified ? "Non spécifié" : rawValue
    }
}
