import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query private var allHunts: [PokemonHunt]
    @State private var viewModel = StatsViewModel()

    private var shinies: [PokemonHunt] { viewModel.shiniesFound(from: allHunts) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    summaryGrid
                    if !shinies.isEmpty {
                        chartSection
                        luckSection
                    }
                }
                .padding()
            }
            .navigationTitle("Statistiques")
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(
                title: "Total resets",
                value: "\(viewModel.totalResets(from: allHunts))",
                icon: "arrow.counterclockwise"
            )
            statCard(
                title: "Shinies trouvés",
                value: "\(shinies.count)",
                icon: "sparkles"
            )
            if let best = viewModel.bestHunt(from: allHunts) {
                statCard(title: "Meilleure chasse", value: "\(best.attempts)", icon: "trophy.fill")
            }
            if let worst = viewModel.worstHunt(from: allHunts) {
                statCard(title: "Pire chasse", value: "\(worst.attempts)", icon: "tortoise.fill")
            }
            if !shinies.isEmpty {
                statCard(
                    title: "Moyenne / shiny",
                    value: String(format: "%.0f", viewModel.averageResets(from: allHunts)),
                    icon: "chart.bar.fill"
                )
            }
        }
    }

    private func statCard(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(ThemeManager.shared.accentColor)
                .accessibilityHidden(true)
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) : \(value)")
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tentatives par shiny")
                .font(.headline)
            Chart(shinies) { hunt in
                BarMark(
                    x: .value("Pokémon", hunt.pokemonName),
                    y: .value("Tentatives", hunt.attempts)
                )
                .foregroundStyle(ThemeManager.shared.accentColor.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.caption)
                }
            }
        }
        .cardStyle()
    }

    private var luckSection: some View {
        VStack(spacing: 8) {
            Text("Luck Rating global")
                .font(.headline)
            Text(viewModel.overallLuckRating(from: allHunts))
                .font(.title2.bold())
                .foregroundStyle(ThemeManager.shared.accentColor)
        }
        .frame(maxWidth: .infinity)
        .cardStyle()
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
