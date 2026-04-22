import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    init(title: String, icon: String? = nil, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: performAction) {
            buttonLabel
        }
        .accessibilityLabel(title)
    }

    private var buttonLabel: some View {
        Group {
            if let icon {
                Label(title, systemImage: icon)
            } else {
                Text(title)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(color)
        .foregroundStyle(.white)
        .font(.title3.bold())
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        .scaleEffect(isPressed ? 0.96 : 1.0)
    }

    private func performAction() {
        withAnimation(.spring(duration: 0.12)) { isPressed = true }
        withAnimation(.spring(duration: 0.12).delay(0.12)) { isPressed = false }
        action()
    }
}

#Preview {
    VStack(spacing: 16) {
        ActionButton(title: "NORMAL", icon: "arrow.counterclockwise", color: .normalRed) {}
        ActionButton(title: "SHINY ✨", icon: "sparkles", color: .shinyGreen) {}
    }
    .padding()
}
