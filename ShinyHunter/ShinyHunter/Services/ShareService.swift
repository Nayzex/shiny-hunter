import UIKit
import SwiftUI

final class ShareService {
    static let shared = ShareService()
    private init() {}

    func buildShareItems(for hunt: PokemonHunt) -> [Any] {
        var items: [Any] = []
        let text = "✨ SHINY TROUVÉ ! \(hunt.pokemonName) après \(hunt.attempts) tentatives ! #ShinyHunter #Pokemon"
        items.append(text)
        if let imageData = hunt.imageData, let image = UIImage(data: imageData) {
            items.append(image)
        }
        return items
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ActivityView(activityItems: ["✨ SHINY TROUVÉ ! Dialga après 1247 tentatives ! #ShinyHunter #Pokemon"])
}
