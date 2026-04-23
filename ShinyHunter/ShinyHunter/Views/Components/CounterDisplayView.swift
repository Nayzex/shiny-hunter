import SwiftUI

struct CounterDisplayView: View {
    let attempts: Int
    let targetAttempts: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(attempts)")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .contentTransition(.numericText())
                .animation(.default, value: attempts)
                .foregroundStyle(.primary)
                .accessibilityValue("\(attempts) sur \(targetAttempts) tentatives")

            Text("/ \(targetAttempts)")
                .font(.title3)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
    }
}

#Preview {
    CounterDisplayView(attempts: 1247, targetAttempts: 4096)
}
