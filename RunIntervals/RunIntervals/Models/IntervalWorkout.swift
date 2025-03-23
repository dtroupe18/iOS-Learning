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

    static let sampleWorkout: IntervalWorkout = {
        let warmup = Interval(type: .warmup, duration: 5 * 60, id: UUID.newString)
        let cooldown = Interval(type: .coolDown, duration: 5 * 60, id: UUID.newString)
        let hittRounds = Self.generateIntervals(rounds: 20)
        let intervals = [warmup] + hittRounds + [cooldown]

        return IntervalWorkout(name: "Example", intervals: intervals, id: "sample-workout-id")
    }()

    static let testWorkout: IntervalWorkout = {
        IntervalWorkout(
            name: "Test",
            intervals: [
                Interval(type: .warmup, duration: 10, id: UUID.newString),
                Interval(type: .highIntensity, duration: 10, id: UUID.newString),
                Interval(type: .lowIntensity, duration: 10, id: UUID.newString),
                Interval(type: .coolDown, duration: 10, id: UUID.newString),
            ],
            id: "test-workout-id"
        )
    }()

    static var defaultWorkouts: [IntervalWorkout] {
        #if DEBUG
        return [sampleWorkout, testWorkout]
        #else
        return [sampleWorkout]
        #endif
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


