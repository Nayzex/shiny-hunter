import SwiftUI

struct HuntRowView: View {
    let hunt: PokemonHunt

    var body: some View {
        HStack(spacing: 12) {
            PokemonImageView(imageData: hunt.imageData, pokemonName: hunt.pokemonName, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text(hunt.pokemonName)
                    .font(.headline)
                Text("\(hunt.attempts) / \(hunt.targetAttempts)")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Spacer()

            probabilityBadge
        }
        .padding(12)
        .cardStyle()
        .padding(.horizontal)
        .padding(.vertical, 4)
    }

    private var probabilityBadge: some View {
        let probability = ShinyMath.cumulativeProbability(
            attempts: hunt.attempts,
            rate: hunt.targetAttempts
        )
        return VStack(spacing: 2) {
            Text(String(format: "%.0f%%", probability))
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(probability > 50 ? ThemeManager.shared.accentColor : .secondary)
            Text("cumulé")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Dialga")
    hunt.attempts = 1247
    return HuntRowView(hunt: hunt)
        .padding()
}
