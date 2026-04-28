import SwiftUI
import SwiftData
import PhotosUI

struct ActiveHuntView: View {
    let hunt: PokemonHunt

    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var allHunts: [PokemonHunt]

    @State private var viewModel: HuntDetailViewModel
    @State private var showHistory = false
    @State private var showHuntInfo = false
    @State private var showNotes = false
    @State private var selectedNormalPhoto: PhotosPickerItem?
    @State private var isCounterHidden = false

    init(hunt: PokemonHunt) {
        self.hunt = hunt
        self._viewModel = State(initialValue: HuntDetailViewModel(hunt: hunt))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                counterSection
                infoRow
                actionSection
                huntInfoSection
                notesSection
                historySection
            }
            .padding()
        }
        .onAppear {
            viewModel.startSession(context: modelContext)
            viewModel.enableKeepScreenOn()
        }
        .onDisappear {
            viewModel.endSession()
            viewModel.disableKeepScreenOn()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                viewModel.endSession()
                viewModel.disableKeepScreenOn()
            } else if phase == .active {
                viewModel.enableKeepScreenOn()
            }
        }
        .task(id: selectedNormalPhoto) {
            guard let photo = selectedNormalPhoto,
                  let rawData = try? await photo.loadTransferable(type: Data.self) else { return }
            viewModel.processNormalImageData(rawData)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isCounterHidden.toggle()
                    }
                } label: {
                    Image(systemName: isCounterHidden ? "eye.slash" : "eye")
                }
                .accessibilityLabel(isCounterHidden ? "Afficher le compteur" : "Masquer le compteur")
            }
        }
        .alert("✨ Shiny, vraiment !?", isPresented: Bindable(viewModel).showShinyConfirmation) {
            Button("Oui !") { viewModel.confirmShiny(allHunts: allHunts) }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Confirme que tu as trouvé un \(hunt.pokemonName) shiny !")
        }
        .alert("Erreur", isPresented: Bindable(viewModel).showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.error?.errorDescription ?? "Erreur inconnue")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedNormalPhoto, matching: .images) {
                PokemonImageView(
                    imageData: hunt.normalImageData ?? hunt.imageData,
                    pokemonName: hunt.pokemonName,
                    size: 160
                )
            }
            .accessibilityLabel("Modifier la photo de \(hunt.pokemonName)")

            Text(hunt.pokemonName)
                .font(.largeTitle.bold())

            methodBadge
        }
    }

    @ViewBuilder
    private var methodBadge: some View {
        if let method = HuntMethod(rawValue: hunt.huntMethod) {
            Text(method.displayName)
                .font(.caption.weight(.medium))
                .foregroundStyle(ThemeManager.shared.accentColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(ThemeManager.shared.accentColor.opacity(0.12), in: Capsule())
                .accessibilityLabel("Méthode : \(method.displayName)")
        }
    }

    private var counterSection: some View {
        VStack(spacing: 12) {
            CounterDisplayView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
            ProgressBarView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
        }
        .cardStyle()
        .blur(radius: isCounterHidden ? 14 : 0)
        .accessibilityHidden(isCounterHidden)
    }

    @ViewBuilder
    private var infoRow: some View {
        let blurred = isCounterHidden
        HStack(alignment: .top, spacing: 12) {
            probabilitySection
            if viewModel.paceDescription != nil {
                paceSection
            }
        }
        .blur(radius: blurred ? 14 : 0)
        .accessibilityHidden(blurred)
    }

    private var probabilitySection: some View {
        VStack(spacing: 8) {
            ProbabilityView(attempts: hunt.attempts, targetAttempts: hunt.targetAttempts)
            if let session = viewModel.currentSession {
                StreakBadgeView(currentSessionResets: session.resetsInSession)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardStyle()
    }

    @ViewBuilder
    private var paceSection: some View {
        if let pace = viewModel.paceDescription {
            VStack(spacing: 6) {
                Image(systemName: "speedometer")
                    .foregroundStyle(ThemeManager.shared.accentColor)
                    .accessibilityHidden(true)
                Text(pace)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .cardStyle()
            .accessibilityLabel(pace)
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            ActionButton(
                title: "NORMAL",
                icon: "arrow.counterclockwise",
                color: .normalRed
            ) {
                viewModel.registerNormalReset(allHunts: allHunts)
            }

            ActionButton(
                title: "SHINY ✨",
                icon: "sparkles",
                color: .shinyGreen
            ) {
                HapticService.shared.buttonTap()
                viewModel.showShinyConfirmation = true
            }

            Button {
                viewModel.registerUndoReset()
            } label: {
                Label("-1", systemImage: "arrow.uturn.backward")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground), in: Capsule())
            }
            .accessibilityLabel("Annuler le dernier reset")
            .disabled(hunt.attempts == 0)
        }
    }

    private var huntInfoSection: some View {
        DisclosureGroup("Infos de chasse", isExpanded: $showHuntInfo) {
            Picker("Méthode", selection: Binding(
                get: { HuntMethod(rawValue: hunt.huntMethod) ?? .softReset },
                set: { viewModel.updateHuntMethod($0) }
            )) {
                ForEach(HuntMethod.allCases, id: \.rawValue) { method in
                    Text(method.displayName).tag(method)
                }
            }
            .accessibilityLabel("Méthode de chasse")

            Picker("Jeu", selection: Binding(
                get: { PokemonGame(rawValue: hunt.game) ?? .unspecified },
                set: { viewModel.updateGame($0) }
            )) {
                ForEach(PokemonGame.allCases, id: \.rawValue) { game in
                    Text(game.displayName).tag(game)
                }
            }
            .accessibilityLabel("Jeu Pokémon")
        }
        .cardStyle()
    }

    private var notesSection: some View {
        DisclosureGroup("Notes", isExpanded: $showNotes) {
            TextEditor(text: Bindable(hunt).notes)
                .frame(minHeight: 80)
                .accessibilityLabel("Notes sur cette chasse")
        }
        .cardStyle()
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
    let hunt = PokemonHunt(pokemonName: "Dialga", huntMethod: .softReset)
    hunt.attempts = 1247
    return NavigationStack {
        ActiveHuntView(hunt: hunt)
    }
    .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
