import Foundation

struct IntervalWorkout: Cacheable {

    static var fileName: String = "Interval-Workouts.json"

    var name: String
    var intervals: [Interval]
    var id: String

    init(name: String, intervals: [Interval], id: String = UUID.newString) {
        self.name = name
        self.intervals = intervals
        self.id = id
    }

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
        let warmup = Interval(type: .warmup, duration: 5 * 60, id: UUID.newString)
        let cooldown = Interval(type: .coolDown, duration: 5 * 60, id: UUID.newString)
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
            Interval(type: .highIntensity, duration: highIntensityDurtion, id: UUID.newString),
            Interval(type: .lowIntensity, duration: lowIntensityDuration, id: UUID.newString)
        ]

        return Array(repeating: baseIntervals, count: rounds).flatMap { $0 }
    }
}


