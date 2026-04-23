import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @State private var soundService = SoundService.shared
    @State private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationStack {
            Form {
                accentColorSection
                notificationSection
                soundSection
                aboutSection
            }
            .navigationTitle("Réglages")
        }
    }

    private var accentColorSection: some View {
        Section("Couleur d'accentuation") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                ForEach(AccentColorOption.allCases, id: \.rawValue) { option in
                    colorSwatch(option)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func colorSwatch(_ option: AccentColorOption) -> some View {
        Button {
            themeManager.selectedOption = option
        } label: {
            Circle()
                .fill(option.color)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .strokeBorder(
                            themeManager.selectedOption == option ? Color.primary : Color.clear,
                            lineWidth: 3
                        )
                )
                .padding(2)
        }
        .accessibilityLabel(option.displayName)
        .accessibilityAddTraits(themeManager.selectedOption == option ? .isSelected : [])
    }

    private var notificationSection: some View {
        Section("Rappels") {
            Picker("Me rappeler après", selection: Bindable(viewModel).notificationDelayDays) {
                ForEach(viewModel.availableDelays, id: \.self) { days in
                    Text(days == 1 ? "1 jour" : "\(days) jours").tag(days)
                }
            }
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
