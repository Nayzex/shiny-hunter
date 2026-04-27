import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(
        filter: #Predicate<PokemonHunt> { $0.isShiny },
        sort: \PokemonHunt.capturedAt,
        order: .reverse
    )
    private var allShinies: [PokemonHunt]

    @State private var viewModel = GalleryViewModel()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    private var filteredShinies: [PokemonHunt] {
        viewModel.filteredHunts(from: allShinies)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if allShinies.isEmpty {
                    EmptyStateView(
                        "Ta galerie de shinies apparaîtra ici",
                        icon: "photo.on.rectangle"
                    )
                } else {
                    VStack(spacing: 0) {
                        headerSection
                        contentSection
                    }
                }
            }
            .navigationTitle("Galerie")
        }
    }

    // MARK: — Sections

    private var headerSection: some View {
        HStack {
            Text(countLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .accessibilityLabel(countLabel)
            Spacer()
            gamePicker
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var contentSection: some View {
        if filteredShinies.isEmpty {
            EmptyStateView("Aucun shiny dans ce jeu", icon: "sparkles")
                .frame(height: 240)
        } else {
            gridSection
        }
    }

    private var gridSection: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(filteredShinies) { hunt in
                NavigationLink(destination: CapturedHuntView(hunt: hunt)) {
                    GalleryCellView(hunt: hunt)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(16)
        .animation(.spring(duration: 0.4), value: filteredShinies.map { $0.id })
    }

    @ViewBuilder
    private var gamePicker: some View {
        let games = viewModel.availableGames(from: allShinies)
        if games.count > 1 {
            Picker("Jeu", selection: Bindable(viewModel).selectedGame) {
                ForEach(games, id: \.rawValue) { game in
                    Text(game == .unspecified ? "Tous" : game.displayName)
                        .tag(game)
                }
            }
            .pickerStyle(.menu)
            .accessibilityLabel("Filtrer par jeu Pokémon")
        }
    }

    // MARK: — Helpers

    private var countLabel: String {
        let count = filteredShinies.count
        return count == 1 ? "1 shiny capturé" : "\(count) shinies capturés"
    }
}

#Preview {
    GalleryView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
