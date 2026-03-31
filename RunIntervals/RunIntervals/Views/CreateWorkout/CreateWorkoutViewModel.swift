import SwiftUI

@Observable
class CreateWorkoutViewModel {

    // Modify the initializer to accept an optional IntervalWorkout
    init(dependencyContainer: DependencyContainer, existingWorkout: IntervalWorkout? = nil) {
        self.dataService = dependencyContainer.dataService

        // If an existing workout is provided, set properties from it; otherwise, use default values
        if let existingWorkout = existingWorkout {
            self.workoutName = existingWorkout.name

            self.rounds = existingWorkout.intervals
                .filter { $0.type == .highIntensity || $0.type == .lowIntensity }.count / 2

            self.highIntensityDuration = existingWorkout.intervals
                .first(where: { $0.type == .highIntensity })?.duration ?? 30

            self.lowIntensityDuration = existingWorkout.intervals
                .first(where: { $0.type == .lowIntensity })?.duration ?? 30

            self.warmupDuration = existingWorkout.intervals
                .first(where: { $0.type == .warmup })?.duration ?? (5 * 60)

            self.cooldownDuration = existingWorkout.intervals
                .first(where: { $0.type == .coolDown })?.duration ?? (5 * 60)
        } else {
            self.workoutName = ""
            self.rounds = 5
            self.highIntensityDuration = 30
            self.lowIntensityDuration = 30
            self.warmupDuration = 5 * 60
            self.cooldownDuration = 5 * 60
        }

        updateIntervals()
    }

    var workoutName: String = "" {
        didSet { updateIntervals() }
    }
    var rounds: Int = 5 {
        didSet { updateIntervals() }
    }
    var highIntensityDuration: TimeInterval = 30 {
        didSet { updateIntervals() }
    }
    var lowIntensityDuration: TimeInterval = 30 {
        didSet { updateIntervals() }
    }
    var warmupDuration: TimeInterval = 5 * 60 {
        didSet { updateIntervals() }
    }
    var cooldownDuration: TimeInterval = 5 * 60 {
        didSet { updateIntervals() }
    }

    /// The computed intervals based on current workout settings.
    private(set) var intervals: [Interval] = []

    /// The total duration formatted as a string.
    private(set) var totalDuration: String = ""

    /// Saves the workout.
    func saveWorkout() {
        let workout = IntervalWorkout(name: workoutName, intervals: intervals)
        dataService.add(workout)
    }

    private func updateIntervals() {
        var generatedIntervals = [
            Interval(type: .warmup, duration: warmupDuration, id: UUID.newString)
        ]

        generatedIntervals.append(contentsOf: IntervalWorkout.generateIntervals(
            rounds: rounds,
            highIntensityDurtion: highIntensityDuration,
            lowIntensityDuration: lowIntensityDuration
        ))

        generatedIntervals.append(
            Interval(type: .coolDown, duration: cooldownDuration, id: UUID.newString)
        )

        intervals = generatedIntervals
        totalDuration = intervals.reduce(0) { $0 + $1.duration }.formattedString
    }

    private let dataService: DataService
}
