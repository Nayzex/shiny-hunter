import SwiftUI

struct HuntDetailView: View {
    let hunt: PokemonHunt

    var body: some View {
        Group {
            if hunt.isShiny {
                CapturedHuntView(hunt: hunt)
            } else {
                ActiveHuntView(hunt: hunt)
            }
        }
        .navigationTitle(hunt.pokemonName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Dialga")
    hunt.attempts = 1247
    return NavigationStack {
        HuntDetailView(hunt: hunt)
    }
    .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
