import SwiftUI
import SwiftData

struct CapturedListView: View {
    @Query(
        filter: #Predicate<PokemonHunt> { $0.isShiny },
        sort: \PokemonHunt.lastActivityAt,
        order: .reverse
    )
    private var capturedHunts: [PokemonHunt]

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Capturés")
        }
    }

    @ViewBuilder
    private var content: some View {
        if capturedHunts.isEmpty {
            EmptyStateView("Aucun shiny encore… Courage !", icon: "sparkles")
        } else {
            List {
                ForEach(capturedHunts) { hunt in
                    NavigationLink(destination: HuntDetailView(hunt: hunt)) {
                        CapturedRowView(hunt: hunt)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    CapturedListView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
