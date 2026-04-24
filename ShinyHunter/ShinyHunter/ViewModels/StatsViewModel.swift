import Foundation

struct DailyResetPoint: Identifiable {
    let date: Date
    let resets: Int
    var id: Date { date }
}

@Observable
final class StatsViewModel {
    func totalResets(from hunts: [PokemonHunt]) -> Int {
        hunts.reduce(0) { $0 + $1.attempts }
    }

    func shiniesFound(from hunts: [PokemonHunt]) -> [PokemonHunt] {
        hunts.filter { $0.isShiny }
    }

    func bestHunt(from hunts: [PokemonHunt]) -> PokemonHunt? {
        hunts.filter { $0.isShiny }.min { $0.attempts < $1.attempts }
    }

    func worstHunt(from hunts: [PokemonHunt]) -> PokemonHunt? {
        hunts.filter { $0.isShiny }.max { $0.attempts < $1.attempts }
    }

    func averageResets(from hunts: [PokemonHunt]) -> Double {
        let shinies = hunts.filter { $0.isShiny }
        guard !shinies.isEmpty else { return 0 }
        return Double(shinies.reduce(0) { $0 + $1.attempts }) / Double(shinies.count)
    }

    func overallLuckRating(from hunts: [PokemonHunt]) -> String {
        let shinies = hunts.filter { $0.isShiny }
        guard !shinies.isEmpty else { return "Pas encore de données" }
        let avg = Int(averageResets(from: hunts))
        let avgRate = shinies.map { $0.targetAttempts }.reduce(0, +) / shinies.count
        return ShinyMath.luckRating(attempts: avg, rate: avgRate)
    }

    func longestCompletedSession(from hunts: [PokemonHunt]) -> HuntSession? {
        hunts.flatMap { $0.sessions }
            .filter { $0.endedAt != nil }
            .max { a, b in
                guard let endA = a.endedAt, let endB = b.endedAt else { return false }
                return endA.timeIntervalSince(a.startedAt) < endB.timeIntervalSince(b.startedAt)
            }
    }

    func oldestActiveHunt(from hunts: [PokemonHunt]) -> PokemonHunt? {
        hunts.filter { !$0.isShiny }.min { $0.createdAt < $1.createdAt }
    }

    func dailyResets(from hunts: [PokemonHunt]) -> [DailyResetPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let allSessions = hunts.flatMap { $0.sessions }

        return (0..<7).reversed().map { offset -> DailyResetPoint in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today),
                  let nextDay = calendar.date(byAdding: .day, value: 1, to: day) else {
                return DailyResetPoint(date: today, resets: 0)
            }
            let resets = allSessions
                .filter { $0.startedAt >= day && $0.startedAt < nextDay }
                .reduce(0) { $0 + $1.resetsInSession }
            return DailyResetPoint(date: day, resets: resets)
        }
    }
}
