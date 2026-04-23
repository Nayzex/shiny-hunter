import SwiftUI

struct EmptyStateView: View {
    let message: String
    let icon: String

    init(_ message: String, icon: String = "sparkles") {
        self.message = message
        self.icon = icon
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(ThemeManager.shared.accentColor.opacity(0.8))
                .accessibilityHidden(true)
            Text(message)
                .font(.headline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView("Aucune chasse en cours. Lance-toi !", icon: "target")
}
