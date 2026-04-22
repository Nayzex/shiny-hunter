import SwiftUI

struct ProbabilityView: View {
    let attempts: Int
    let targetAttempts: Int

    private var probability: Double {
        ShinyMath.cumulativeProbability(attempts: attempts, rate: targetAttempts)
    }

    var body: some View {
        HStack {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .foregroundStyle(Color.shinyGold)
                .accessibilityHidden(true)
            Text("Probabilité cumulée : ")
                .foregroundStyle(.secondary)
            Text(String(format: "%.1f%%", probability))
                .font(.title3.monospacedDigit())
                .foregroundStyle(probabilityColor)
                .contentTransition(.numericText())
        }
        .font(.title3)
    }

    private var probabilityColor: Color {
        switch probability {
        case ..<50:    return .primary
        case 50..<75:  return Color.shinyGold
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
