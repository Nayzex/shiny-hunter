import Foundation

extension Date {
    var shortFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var relativeFormatted: String {
        formatted(.relative(presentation: .named))
    }

    var timeFormatted: String {
        formatted(date: .omitted, time: .shortened)
    }
}

extension TimeInterval {
    var durationFormatted: String {
        let totalMinutes = Int(self) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }
}
