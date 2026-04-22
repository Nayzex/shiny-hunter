import Foundation

enum ShinyMath {
    // La probabilité cumulée utilise la loi géométrique inverse :
    // P(trouver en N essais) = 1 - ((rate-1)/rate)^N
    static func cumulativeProbability(attempts: Int, rate: Int) -> Double {
        guard attempts > 0, rate > 0 else { return 0.0 }
        return (1.0 - pow(Double(rate - 1) / Double(rate), Double(attempts))) * 100.0
    }

    static func luckRating(attempts: Int, rate: Int) -> String {
        guard rate > 0, attempts > 0 else { return "Dans la moyenne" }
        let ratio = Double(attempts) / Double(rate)
        switch ratio {
        case ..<0.25:    return "Très chanceux"
        case 0.25..<0.75: return "Chanceux"
        case 0.75..<1.5:  return "Dans la moyenne"
        case 1.5..<2.5:   return "Malchanceux"
        default:          return "Extrêmement malchanceux"
        }
    }

    static func probabilityOfFindingByNow(attempts: Int, rate: Int) -> String {
        let probability = cumulativeProbability(attempts: attempts, rate: rate)
        return String(format: "Tu avais %.1f%% de chances de le trouver en autant d'essais", probability)
    }
}
