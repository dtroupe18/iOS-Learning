import Foundation
import SwiftData

@Model
class Interval: Identifiable {
    var typeRaw: String
    var duration: TimeInterval
    var id: String = UUID().uuidString

    var type: IntervalType {
        get { IntervalType(rawValue: typeRaw) ?? .lowIntensity }
        set { typeRaw = newValue.rawValue }
    }

    init(type: IntervalType, duration: TimeInterval) {
        self.typeRaw = type.rawValue
        self.duration = duration
    }
}

@Model
class IntervalWorkout {

    init(name: String, intervals: [Interval]) {
        self.name = name
        self.intervals = intervals
    }

    var name: String
    var intervals: [Interval]

    var totalDuration: String {
        let totalSeconds = intervals.reduce(0) { $0 + $1.duration }
        return totalSeconds.formattedString
    }

    var description: String {
        let containsWarmup: Bool = intervals.first?.type == .warmup
        let containsCooldown: Bool = intervals.last?.type == .coolDown

        var str = ""
        if containsWarmup {
            str += "Warmup + "
        }
        
        str += "\(intervals.count) rounds"

        if containsCooldown {
            str += " + Cooldown"
        }

        return str
    }

    static func sample() -> IntervalWorkout {
        let warmup = Interval(type: .warmup, duration: 5 * 60)
        let cooldown = Interval(type: .coolDown, duration: 5 * 60)
        let hittRounds = Self.generateIntervals(rounds: 20)
        let intervals = [warmup] + hittRounds + [cooldown]

        return IntervalWorkout(name: "Example", intervals: intervals)
    }

    static func generateIntervals(
        rounds: Int,
        highIntensityDurtion: TimeInterval = 30,
        lowIntensityDuration: TimeInterval = 30
    ) -> [Interval] {

        let baseIntervals = [
            Interval(type: .highIntensity, duration: highIntensityDurtion),
            Interval(type: .lowIntensity, duration: lowIntensityDuration)
        ]

        return Array(repeating: baseIntervals, count: rounds).flatMap { $0 }
    }
}

enum IntervalType: String {
    case warmup, lowIntensity, highIntensity, coolDown
}


// qwe come kinda completed interval workout with date and healthdata?
