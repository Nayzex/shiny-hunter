import SwiftUI
import PhotosUI

struct ActiveHuntView: View {
    let hunt: PokemonHunt

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel: HuntDetailViewModel
    @State private var showHistory = false
    @State private var selectedPhoto: PhotosPickerItem?

    init(hunt: PokemonHunt) {
        self.hunt = hunt
        self._viewModel = State(initialValue: HuntDetailViewModel(hunt: hunt))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                counterSection
                probabilitySection
                actionSection
                historySection
            }
            .padding()
        }
        .onAppear {
            viewModel.startSession(context: modelContext)
        }
        .onDisappear {
            viewModel.endSession()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background { viewModel.endSession() }
        }
        .onChange(of: selectedPhoto) { _, newItem in
            if let item = newItem { viewModel.updatePhoto(item) }
        }
        .alert("✨ Shiny, vraiment !?", isPresented: $viewModel.showShinyConfirmation) {
            Button("Oui !") { viewModel.confirmShiny(context: modelContext) }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Confirme que tu as trouvé un \(hunt.pokemonName) shiny !")
        }
        .alert("Erreur", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.error?.errorDescription ?? "Erreur inconnue")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                PokemonImageView(imageData: hunt.imageData, pokemonName: hunt.pokemonName, size: 160)
            }
            .accessibilityLabel("Modifier la photo de \(hunt.pokemonName)")

            Text(hunt.pokemonName)
                .font(.largeTitle.bold())
        }
    }

    private var counterSection: some View {
        VStack(spacing: 12) {
            CounterDisplayView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
            ProgressBarView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
        }
        .cardStyle()
    }

    private var probabilitySection: some View {
        VStack(spacing: 8) {
            ProbabilityView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
            if let session = viewModel.currentSession {
                StreakBadgeView(currentSessionResets: session.resetsInSession)
            }
        }
        .cardStyle()
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            ActionButton(
                title: "NORMAL",
                icon: "arrow.counterclockwise",
                color: .normalRed
            ) {
                viewModel.registerNormalReset()
            }

            ActionButton(
                title: "SHINY ✨",
                icon: "sparkles",
                color: .shinyGreen
            ) {
                HapticService.shared.buttonTap()
                viewModel.showShinyConfirmation = true
            }
        }
    }

    private var historySection: some View {
        DisclosureGroup("Historique des sessions", isExpanded: $showHistory) {
            if hunt.sessions.isEmpty {
                Text("Aucune session enregistrée")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                SessionHistoryView(sessions: hunt.sessions)
            }
        }
        .cardStyle()
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Dialga")
    hunt.attempts = 1247
    return NavigationStack {
        ActiveHuntView(hunt: hunt)
    }
    .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
