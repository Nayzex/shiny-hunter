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
                    dailyResetsSection
                    if !shinies.isEmpty {
                        chartSection
                        luckSection
                    }
                    if !allHunts.isEmpty {
                        recordsSection
                    }
                    badgesSection
                }
                .padding()
            }
            .navigationTitle("Statistiques")
        }
    }

    // MARK: — Summary

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) : \(value)")
    }

    // MARK: — Graphiques

    private var dailyResetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resets sur 7 jours")
                .font(.headline)
            Chart(viewModel.dailyResets(from: allHunts)) { point in
                BarMark(
                    x: .value("Jour", point.date, unit: .day),
                    y: .value("Resets", point.resets)
                )
                .foregroundStyle(ThemeManager.shared.accentColor.gradient)
            }
            .frame(height: 140)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .font(.caption)
                }
            }
        }
        .cardStyle()
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

    // MARK: — Records

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Records")
                .font(.headline)
                .padding(.horizontal, 4)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let best = viewModel.bestHunt(from: allHunts) {
                    recordCard(
                        title: "Meilleure chasse",
                        name: best.pokemonName,
                        detail: "\(best.attempts) resets 🍀",
                        icon: "trophy.fill"
                    )
                }
                if let worst = viewModel.worstHunt(from: allHunts) {
                    recordCard(
                        title: "Pire chasse",
                        name: worst.pokemonName,
                        detail: "\(worst.attempts) resets",
                        icon: "tortoise.fill"
                    )
                }
                if let session = viewModel.longestCompletedSession(from: allHunts),
                   let end = session.endedAt {
                    recordCard(
                        title: "Session la plus longue",
                        name: "\(session.resetsInSession) resets",
                        detail: end.timeIntervalSince(session.startedAt).durationFormatted,
                        icon: "clock.fill"
                    )
                }
                if let oldest = viewModel.oldestActiveHunt(from: allHunts) {
                    recordCard(
                        title: "En chasse depuis",
                        name: oldest.pokemonName,
                        detail: oldest.createdAt.relativeFormatted,
                        icon: "calendar"
                    )
                }
            }
        }
    }

    private func recordCard(title: String, name: String, detail: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text(name)
                .font(.headline)
                .lineLimit(1)
            Text(detail)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(ThemeManager.shared.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .cardStyle()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) : \(name), \(detail)")
    }

    // MARK: — Badges

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Succès")
                .font(.headline)
                .padding(.horizontal, 4)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(Badge.allCases, id: \.rawValue) { badge in
                    badgeCell(badge)
                }
            }
        }
        .cardStyle()
    }

    private func badgeCell(_ badge: Badge) -> some View {
        let unlocked = BadgeService.shared.unlockedBadges.contains(badge)
        return VStack(spacing: 4) {
            Text(badge.emoji)
                .font(.title2)
                .grayscale(unlocked ? 0 : 1)
                .accessibilityHidden(true)
            Text(badge.title)
                .font(.caption2)
                .foregroundStyle(unlocked ? .primary : .tertiary)
                .multilineTextAlignment(.center)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(badge.title) : \(unlocked ? "Obtenu" : "Non obtenu")")
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [PokemonHunt.self, HuntSession.self], inMemory: true)
}
