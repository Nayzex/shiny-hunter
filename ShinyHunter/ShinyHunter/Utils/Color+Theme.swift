import SwiftUI

extension Color {
    static let shinyGold      = Color(red: 1.0, green: 0.8, blue: 0.0)
    static let normalRed      = Color.red
    static let shinyGreen     = Color.green
    static let cardBackground = Color(.secondarySystemBackground)
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
