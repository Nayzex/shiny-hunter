import SwiftUI

struct ProbabilityView: View {
    let attempts: Int
    let targetAttempts: Int

    private var probability: Double {
        ShinyMath.cumulativeProbability(attempts: attempts, rate: targetAttempts)
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(ThemeManager.shared.accentColor)
                .accessibilityHidden(true)
            Text(String(format: "%.1f%%", probability))
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(probabilityColor)
                .contentTransition(.numericText())
                .animation(.default, value: probability)
            Text("Probabilité cumulée")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var probabilityColor: Color {
        switch probability {
        case ..<50:    return .primary
        case 50..<75:  return ThemeManager.shared.accentColor
        default:       return .orange
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        ProbabilityView(attempts: 500, targetAttempts: 4096)
        ProbabilityView(attempts: 2500, targetAttempts: 4096)
        ProbabilityView(attempts: 4000, targetAttempts: 4096)
    }
    .padding()
}
