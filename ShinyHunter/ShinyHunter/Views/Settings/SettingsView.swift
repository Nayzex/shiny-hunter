import SwiftUI

struct SettingsView: View {
    @State private var soundService = SoundService.shared

    var body: some View {
        NavigationStack {
            Form {
                soundSection
                aboutSection
            }
            .navigationTitle("Réglages")
        }
    }

    private var soundSection: some View {
        Section("Sons") {
            Toggle("Sons activés", isOn: Bindable(soundService).isSoundEnabled)
        }
    }

    private var aboutSection: some View {
        Section("À propos") {
            LabeledContent("Version", value: appVersion)
            Text("Pokémon et les noms de Pokémon sont des marques déposées de Nintendo / Creatures Inc. / GAME FREAK inc.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}

#Preview {
    SettingsView()
}
