import SwiftUI

struct StreakBadgeView: View {
    let currentSessionResets: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundStyle(Color.shinyGold)
                .accessibilityHidden(true)
            Text("Session actuelle : \(currentSessionResets) resets")
                .font(.subheadline.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.shinyGold.opacity(0.15))
        .clipShape(Capsule())
        .accessibilityLabel("Session actuelle : \(currentSessionResets) resets")
    }
}

#Preview {
    StreakBadgeView(currentSessionResets: 42)
        .padding()
}
