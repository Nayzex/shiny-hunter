import WidgetKit
import SwiftUI

private let appGroupID = "group.com.nayzex.shinyhunter"
private let huntDataKey = "widgetHuntData"
private let accentColor = Color(red: 1.0, green: 0.8, blue: 0.0)

// MARK: — Data

struct WidgetHuntData {
    let pokemonName: String
    let attempts: Int
    let targetAttempts: Int
    let huntID: String

    static let placeholder = WidgetHuntData(
        pokemonName: "Dialga",
        attempts: 1247,
        targetAttempts: 4096,
        huntID: ""
    )

    static func load() -> WidgetHuntData? {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let data = defaults.data(forKey: huntDataKey),
            let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let name = payload["pokemonName"] as? String,
            let attempts = payload["attempts"] as? Int,
            let target = payload["targetAttempts"] as? Int,
            let huntID = payload["huntID"] as? String
        else { return nil }
        return WidgetHuntData(pokemonName: name, attempts: attempts, targetAttempts: target, huntID: huntID)
    }
}

// MARK: — Timeline

struct HuntEntry: TimelineEntry {
    let date: Date
    let huntData: WidgetHuntData?
}

struct ShinyHunterWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HuntEntry {
        HuntEntry(date: Date(), huntData: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (HuntEntry) -> Void) {
        completion(HuntEntry(date: Date(), huntData: .load() ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HuntEntry>) -> Void) {
        let entry = HuntEntry(date: Date(), huntData: .load())
        completion(Timeline(entries: [entry], policy: .never))
    }
}

// MARK: — Views

struct ShinyHunterWidgetEntryView: View {
    let entry: HuntEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if let hunt = entry.huntData {
            if family == .systemSmall {
                smallView(hunt: hunt)
            } else {
                mediumView(hunt: hunt)
            }
        } else {
            emptyView
        }
    }

    private func smallView(hunt: WidgetHuntData) -> some View {
        VStack(spacing: 6) {
            Text("🎯")
                .font(.title2)
            Text(hunt.pokemonName)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text("\(hunt.attempts)")
                .font(.system(.title, design: .rounded, weight: .heavy))
                .monospacedDigit()
                .foregroundStyle(accentColor)
            Text("resets")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }

    private func mediumView(hunt: WidgetHuntData) -> some View {
        let safeTarget = max(1, hunt.targetAttempts)
        let progress = min(1.0, Double(hunt.attempts) / Double(safeTarget))
        let probability = (1.0 - pow(Double(safeTarget - 1) / Double(safeTarget), Double(hunt.attempts))) * 100.0
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hunt.pokemonName)
                    .font(.title3.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(hunt.attempts)")
                    .font(.system(.title, design: .rounded, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(accentColor)
                Text("/ \(hunt.targetAttempts) resets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(spacing: 4) {
                CircularProgressWidgetView(progress: progress)
                    .frame(width: 56, height: 56)
                Text(String(format: "%.1f%%", probability))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "target")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Aucune chasse")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct CircularProgressWidgetView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: — Configuration

struct ShinyHunterWidgetConfig: Widget {
    let kind = "ShinyHunterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ShinyHunterWidgetProvider()) { entry in
            ShinyHunterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Shiny Hunter")
        .description("Suivez votre chasse shiny en cours.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct ShinyHunterWidgetBundle: WidgetBundle {
    var body: some Widget {
        ShinyHunterWidgetConfig()
    }
}
