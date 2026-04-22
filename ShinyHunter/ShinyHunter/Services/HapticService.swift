import UIKit

final class HapticService {
    static let shared = HapticService()
    private init() {}

    func normalReset() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    func shinyFound() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    func buttonTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
