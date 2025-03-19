import Combine
import SwiftUI

enum HIITSettingType: String {
    case work = "Work"
    case rest = "Rest"
    case rounds = "Rounds"

    var color: Color {
        switch self {
        case .work: return .green
        case .rest: return .red
        case .rounds: return .blue
        }
    }

    var name: String { rawValue }

    var adjustDetailTitle: String {
        switch self {
        case .work: return "Work Interval"
        case .rest: return "Rest Interval"
        case .rounds: return "Number of rounds"
        }
    }

    var adjustDetailSubtitle: String? {
        switch self {
        case .work, .rest: return "Seconds"
        case .rounds: return nil
        }
    }

    var isTimeBased: Bool {
        switch self {
        case .work, .rest: return true
        case .rounds: return false
        }
    }
}

class HIITSettings: ObservableObject {
    // We use Doubles here because digitalCrownRotation requires that.

    /// Number of seconds the work interval should last.
    @Published var workTime: Double = 30

    /// Number of seconds the rest interval should last.
    @Published var restTime: Double = 30

    /// Number of rounds (one round is work + rest).
    @Published var rounds: Double = 30
}
