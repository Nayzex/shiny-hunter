import SwiftUI
import SwiftData

struct HuntListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<PokemonHunt> { !$0.isShiny },
        sort: \PokemonHunt.lastActivityAt,
        order: .reverse
    )
    private var activeHunts: [PokemonHunt]

    @State private var viewModel = HuntListViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("En cours")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.showAddHunt = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Nouvelle chasse")
                    }
                }
                .sheet(isPresented: $viewModel.showAddHunt) {
                    AddHuntView()
                }
                .confirmationDialog(
                    "Supprimer cette chasse ?",
                    isPresented: $viewModel.showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Supprimer", role: .destructive) {
                        viewModel.confirmDelete(context: modelContext)
                    }
                    Button("Annuler", role: .cancel) {
                        viewModel.cancelDelete()
                    }
                } message: {
                    Text("Cette action est irréversible.")
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        if activeHunts.isEmpty {
            EmptyStateView("Aucune chasse en cours. Lance-toi !", icon: "target")
        } else {
            List {
                ForEach(activeHunts) { hunt in
                    NavigationLink(destination: HuntDetailView(hunt: hunt)) {
                        HuntRowView(hunt: hunt)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .onDelete { offsets in
                    if let index = offsets.first {
                        viewModel.requestDelete(activeHunts[index])
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    HuntListView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
