import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(AppDelegate.self) private var delegate
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HuntListView()
                .tabItem { Label("En cours", systemImage: "target") }
                .tag(0)
            CapturedListView()
                .tabItem { Label("Capturés", systemImage: "sparkles") }
                .tag(1)
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Réglages", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .tint(ThemeManager.shared.accentColor)
        .onAppear {
            if delegate.pendingShowAddHunt { selectedTab = 0 }
        }
        .onChange(of: delegate.pendingShowAddHunt) { _, newValue in
            if newValue { selectedTab = 0 }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppDelegate())
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
