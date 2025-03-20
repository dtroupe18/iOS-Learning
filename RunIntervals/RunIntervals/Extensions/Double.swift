import Foundation

extension Double {
    var formattedString: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        if minutes > 0 {
            return String(format: "%d:%02d min", minutes, seconds)
        } else {
            return String(format: "%d sec", seconds)
        }
    }
}
