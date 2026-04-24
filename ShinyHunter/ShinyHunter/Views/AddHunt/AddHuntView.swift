import SwiftUI
import SwiftData
import PhotosUI

struct AddHuntView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allHunts: [PokemonHunt]

    @State private var viewModel = AddHuntViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                photoSection
                gameSection
                methodSection
                charmeSection
            }
            .navigationTitle("Nouvelle chasse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") {
                        viewModel.createHunt(context: modelContext, allHunts: allHunts)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                    .accessibilityLabel("Créer la chasse")
                }
            }
            .task(id: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                viewModel.isLoadingImage = true
                guard let rawData = try? await item.loadTransferable(type: Data.self) else {
                    viewModel.isLoadingImage = false
                    return
                }
                viewModel.processRawImageData(rawData)
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK") {}
            } message: {
                Text(viewModel.error?.errorDescription ?? "Erreur inconnue")
            }
        }
    }

    private var nameSection: some View {
        Section("Pokémon") {
            TextField("Nom du Pokémon", text: $viewModel.pokemonName)
                .autocorrectionDisabled()
        }
    }

    private var photoSection: some View {
        Section("Photo normale (optionnel)") {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    photoPickerContent
                    Text(viewModel.imageData == nil ? "Choisir une photo" : "Modifier la photo")
                        .foregroundStyle(.primary)
                }
            }
        }
    }

    @ViewBuilder
    private var photoPickerContent: some View {
        if viewModel.isLoadingImage {
            ProgressView()
                .accessibilityLabel("Chargement de l'image")
        } else if let imageData = viewModel.imageData,
                  let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Photo sélectionnée")
        } else {
            Image(systemName: "photo.badge.plus")
                .foregroundStyle(ThemeManager.shared.accentColor)
                .accessibilityHidden(true)
        }
    }

    private var gameSection: some View {
        Section("Jeu") {
            Picker("Jeu Pokémon", selection: $viewModel.selectedGame) {
                ForEach(PokemonGame.allCases, id: \.rawValue) { game in
                    Text(game.displayName).tag(game)
                }
            }
        }
    }

    private var methodSection: some View {
        Section("Méthode de chasse") {
            Picker("Méthode", selection: $viewModel.selectedMethod) {
                ForEach(HuntMethod.allCases, id: \.rawValue) { method in
                    Text(method.displayName).tag(method)
                }
            }
        }
    }

    private var charmeSection: some View {
        Section("Charme Chroma") {
            Toggle("Charme Chroma actif", isOn: $viewModel.hasCharmeChroma)
            Text(viewModel.displayRate)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AddHuntView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
