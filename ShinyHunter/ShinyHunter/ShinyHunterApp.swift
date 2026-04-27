import SwiftUI
import SwiftData

@main
struct ShinyHunterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(delegate)
                .environment(ThemeManager.shared)
        }
        .modelContainer(for: [PokemonHunt.self, HuntSession.self])
    }
}
