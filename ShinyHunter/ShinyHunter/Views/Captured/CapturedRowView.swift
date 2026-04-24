import SwiftUI

struct CapturedRowView: View {
    let hunt: PokemonHunt

    var body: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .topTrailing) {
                PokemonImageView(imageData: hunt.imageData ?? hunt.normalImageData, pokemonName: hunt.pokemonName, size: 56)
                Image(systemName: "sparkles")
                    .font(.caption.bold())
                    .foregroundStyle(ThemeManager.shared.accentColor)
                    .offset(x: 4, y: -4)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(hunt.pokemonName)
                    .font(.headline)
                Text("\(hunt.attempts) tentatives")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                if !hunt.game.isEmpty, let game = PokemonGame(rawValue: hunt.game) {
                    Text(game.displayName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let capturedAt = hunt.capturedAt {
                Text(capturedAt.shortFormatted)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .cardStyle()
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Lugia", game: .hgss, huntMethod: .softReset)
    hunt.attempts = 2048
    hunt.isShiny = true
    hunt.capturedAt = Date()
    return CapturedRowView(hunt: hunt)
        .padding()
}
