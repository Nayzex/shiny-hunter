import SwiftUI
import PhotosUI

struct AddHuntView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = AddHuntViewModel()

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                photoSection
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
                        viewModel.createHunt(context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isFormValid)
                    .accessibilityLabel("Créer la chasse")
                }
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
        Section("Photo (optionnel)") {
            PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                HStack {
                    photoPickerContent
                    Text(viewModel.imageData == nil ? "Choisir une photo" : "Modifier la photo")
                        .foregroundStyle(.primary)
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) { _, newItem in
                viewModel.onPhotoSelected(newItem)
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
                .foregroundStyle(Color.shinyGold)
                .accessibilityHidden(true)
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
