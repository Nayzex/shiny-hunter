import SwiftUI
import SwiftData
import PhotosUI

struct CapturedHuntView: View {
    let hunt: PokemonHunt

    @State private var viewModel: HuntDetailViewModel
    @State private var selectedShinyPhoto: PhotosPickerItem?
    @State private var showShareSheet = false
    @State private var showNotes = false
    @State private var sparkleScale: CGFloat = 0.8
    @State private var sparkleOpacity: Double = 0.5

    init(hunt: PokemonHunt) {
        self.hunt = hunt
        self._viewModel = State(initialValue: HuntDetailViewModel(hunt: hunt))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photosSection
                infoSection
                notesSection
                shareSection
            }
            .padding()
        }
        .onAppear { startSparkleAnimation() }
        .task(id: selectedShinyPhoto) {
            guard let photo = selectedShinyPhoto,
                  let rawData = try? await photo.loadTransferable(type: Data.self) else { return }
            viewModel.processRawImageData(rawData)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: ShareService.shared.buildShareItems(for: hunt))
        }
        .alert("Erreur", isPresented: Bindable(viewModel).showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.error?.errorDescription ?? "Erreur inconnue")
        }
    }

    @ViewBuilder
    private var photosSection: some View {
        if hunt.normalImageData != nil {
            sideBySidePhotos
        } else {
            shinyOnlyPhoto
        }
    }

    private var sideBySidePhotos: some View {
        HStack(spacing: 16) {
            VStack(spacing: 6) {
                PokemonImageView(
                    imageData: hunt.normalImageData,
                    pokemonName: hunt.pokemonName,
                    size: 130
                )
                Text("Normal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                ZStack {
                    PokemonImageView(
                        imageData: hunt.imageData,
                        pokemonName: hunt.pokemonName,
                        size: 130
                    )
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(ThemeManager.shared.accentColor)
                        .scaleEffect(sparkleScale)
                        .opacity(sparkleOpacity)
                        .accessibilityHidden(true)
                }
                Text("✨ Shiny")
                    .font(.caption)
                    .foregroundStyle(ThemeManager.shared.accentColor)
            }
        }
    }

    private var shinyOnlyPhoto: some View {
        ZStack {
            PokemonImageView(
                imageData: hunt.imageData,
                pokemonName: hunt.pokemonName,
                size: 200
            )
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(ThemeManager.shared.accentColor)
                .scaleEffect(sparkleScale)
                .opacity(sparkleOpacity)
                .accessibilityHidden(true)
        }
    }

    private var infoSection: some View {
        VStack(spacing: 12) {
            Text("Attrapé en shiny après")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("\(hunt.attempts) tentatives !")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(ThemeManager.shared.accentColor)

            if let capturedAt = hunt.capturedAt {
                Text("Le \(capturedAt.shortFormatted)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !hunt.game.isEmpty, let game = PokemonGame(rawValue: hunt.game) {
                Text(game.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let method = HuntMethod(rawValue: hunt.huntMethod) {
                Text(method.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(ShinyMath.probabilityOfFindingByNow(attempts: hunt.attempts, rate: hunt.targetAttempts))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(ShinyMath.luckRating(attempts: hunt.attempts, rate: hunt.targetAttempts))
                .font(.title3.bold())
                .foregroundStyle(ThemeManager.shared.accentColor)
        }
        .cardStyle()
    }

    private var notesSection: some View {
        DisclosureGroup("Notes", isExpanded: $showNotes) {
            TextEditor(text: Bindable(hunt).notes)
                .frame(minHeight: 80)
                .accessibilityLabel("Notes sur cette capture")
        }
        .cardStyle()
    }

    private var shareSection: some View {
        VStack(spacing: 12) {
            Button {
                showShareSheet = true
                HapticService.shared.buttonTap()
            } label: {
                Label("Partager", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(ThemeManager.shared.accentColor)
                    .foregroundStyle(.black)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Partager cette capture")

            PhotosPicker(selection: $selectedShinyPhoto, matching: .images) {
                Label("Modifier la photo shiny", systemImage: "photo.badge.arrow.down")
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.cardBackground)
                    .foregroundStyle(.primary)
                    .font(.headline)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .accessibilityLabel("Modifier la photo shiny du Pokémon")
        }
    }

    private func startSparkleAnimation() {
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            sparkleScale = 1.2
            sparkleOpacity = 1.0
        }
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Mew", game: .ecarlateViolet, huntMethod: .masuda)
    hunt.attempts = 342
    hunt.isShiny = true
    hunt.capturedAt = Date()
    return NavigationStack {
        CapturedHuntView(hunt: hunt)
    }
    .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
