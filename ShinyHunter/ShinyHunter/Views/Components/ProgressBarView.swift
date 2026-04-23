import SwiftUI

struct ProgressBarView: View {
    let attempts: Int
    let targetAttempts: Int

    private var progress: Double {
        guard targetAttempts > 0 else { return 0 }
        return min(Double(attempts) / Double(targetAttempts), 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(ThemeManager.shared.accentColor.opacity(0.2))
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [ThemeManager.shared.accentColor, Color.shinyGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut, value: attempts)
            }
        }
        .frame(height: 12)
        .accessibilityLabel("Progression vers le shiny")
        .accessibilityValue(String(format: "%.0f pourcent", progress * 100))
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressBarView(attempts: 500, targetAttempts: 4096)
        ProgressBarView(attempts: 2000, targetAttempts: 4096)
        ProgressBarView(attempts: 4096, targetAttempts: 4096)
    }
    .padding()
}
