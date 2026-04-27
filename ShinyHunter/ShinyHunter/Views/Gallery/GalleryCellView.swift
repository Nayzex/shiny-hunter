import SwiftUI
import SwiftData

struct GalleryCellView: View {
    let hunt: PokemonHunt

    @State private var glowing = false

    var body: some View {
        VStack(spacing: 4) {
            imageArea
            Text(hunt.pokemonName)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 4)
        }
        .padding(.bottom, 8)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(goldBorder)
        .shadow(
            color: ThemeManager.shared.accentColor.opacity(glowing ? 0.25 : 0.08),
            radius: 4
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(hunt.pokemonName), shiny")
    }

    private var imageArea: some View {
        ZStack(alignment: .topTrailing) {
            huntImage
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .accessibilityLabel("Photo de \(hunt.pokemonName)")

            Text("✨")
                .font(.system(size: 14))
                .padding(3)
                .background(.ultraThinMaterial, in: Circle())
                .padding(4)
                .accessibilityHidden(true)
        }
        .padding([.top, .horizontal], 8)
    }

    @ViewBuilder
    private var huntImage: some View {
        if let data = hunt.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(ThemeManager.shared.accentColor.opacity(0.12))
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(ThemeManager.shared.accentColor)
                        .accessibilityHidden(true)
                )
        }
    }

    private var goldBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(ThemeManager.shared.accentColor, lineWidth: glowing ? 2.0 : 0.8)
            .opacity(glowing ? 1.0 : 0.35)
    }
}

#Preview {
    let hunt = PokemonHunt(pokemonName: "Dialga")
    hunt.isShiny = true
    hunt.capturedAt = Date()
    return ScrollView {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
            spacing: 12
        ) {
            ForEach(0..<6) { _ in
                GalleryCellView(hunt: hunt)
            }
        }
        .padding(16)
    }
    .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
