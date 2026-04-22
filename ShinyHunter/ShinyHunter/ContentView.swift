import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HuntListView()
                .tabItem {
                    Label("En cours", systemImage: "target")
                }

            CapturedListView()
                .tabItem {
                    Label("Capturés", systemImage: "sparkles")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
        .tint(Color.shinyGold)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
