import SwiftUI

struct SessionHistoryView: View {
    let sessions: [HuntSession]

    private var sortedSessions: [HuntSession] {
        sessions.sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sortedSessions) { session in
                sessionRow(session)
                if session.id != sortedSessions.last?.id {
                    Divider()
                }
            }
        }
    }

    private func sessionRow(_ session: HuntSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.startedAt.shortFormatted)
                    .font(.subheadline.bold())
                if let endedAt = session.endedAt {
                    Text(endedAt.timeIntervalSince(session.startedAt).durationFormatted)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("\(session.resetsInSession) resets")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let session = HuntSession()
    session.resetsInSession = 42
    session.endedAt = Date()
    return SessionHistoryView(sessions: [session])
        .padding()
}
