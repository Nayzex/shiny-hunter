import SwiftUI

struct PokemonImageView: View {
    let imageData: Data?
    let pokemonName: String
    let size: CGFloat

    init(imageData: Data?, pokemonName: String, size: CGFloat = 160) {
        self.imageData = imageData
        self.pokemonName = pokemonName
        self.size = size
    }

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .accessibilityLabel("Photo de \(pokemonName)")
            } else {
                placeholderView
                    .accessibilityHidden(true)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.shinyGold.opacity(0.4), lineWidth: 2)
        )
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.cardBackground)
            .overlay(
                Image(systemName: "photo.badge.plus")
                    .font(.system(size: size * 0.3))
                    .foregroundStyle(Color.shinyGold.opacity(0.8))
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        PokemonImageView(imageData: nil, pokemonName: "Dialga", size: 160)
        PokemonImageView(imageData: nil, pokemonName: "Mew", size: 80)
    }
    .padding()
}
