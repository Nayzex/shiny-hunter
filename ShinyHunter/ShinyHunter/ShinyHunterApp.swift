import SwiftUI
import SwiftData

@main
struct ShinyHunterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [PokemonHunt.self, HuntSession.self])
    }
}
