import Combine
import Foundation
import Observation

@Observable
final class LiveWorkoutViewModel {

    init(dependencyContainer: WatchDependencyContainer, workout: IntervalWorkout) {
        self.healthKitService = dependencyContainer.healthKitService
        self.healthKitWorkoutService = dependencyContainer.healthKitWorkoutService
        self.workout = workout

        timeRemaining = workout.intervals[currentIntervalIndex].duration
    }

    var onWorkoutComplete: (() -> Void)?
    var onPlaySound: (() -> Void)?

    private(set) var currentRound: Int = 1
    private(set) var currentIntervalIndex: Int = 0
    private(set) var timeRemaining: Double = 0
    private(set) var timer: AnyCancellable?
    private(set) var isRunning = false

    var heartRate: Int { Int(healthKitWorkoutService.heartRate) }
    var distance: Double { healthKitWorkoutService.distance }
    var pace: Double { healthKitWorkoutService.pace }

    var intervals: [Interval] { workout.intervals }
    var currentInterval: Interval { workout.intervals[currentIntervalIndex] }
    var timeRemainingString: String { timeString(timeRemaining) }
    var progress: CGFloat { CGFloat(timeRemaining) / CGFloat(currentInterval.duration) }

    func startWorkout() {
        healthKitWorkoutService.startWorkout(workoutType: .highIntensityIntervalTraining)
        startTimer()
        isRunning = true
    }

    func stopWorkout() {
        healthKitWorkoutService.stopWorkout()
        timer?.cancel()
        isRunning = false
    }

    func requestHealthKitPermission() {
        healthKitService.requestAuthorization()
    }

    // MARK: Private

    private func startTimer() {
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.25
                } else {
                    self.onPlaySound?()
                    self.switchInterval()
                }
            }
    }

    private func switchInterval() {
        if currentIntervalIndex < workout.intervals.count - 1 {
            currentIntervalIndex += 1
            timeRemaining = workout.intervals[currentIntervalIndex].duration
        } else {
            stopWorkout()
            onWorkoutComplete?()
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let intSeconds = Int(seconds)
        let minutes = intSeconds / 60
        let remainingSeconds = intSeconds % 60

        return minutes > 0
            ? String(format: "%d:%02d", minutes, remainingSeconds)
            : String(format: "0:%02d", remainingSeconds)
    }

    private let workout: IntervalWorkout
    private let healthKitService: HealthKitService
    private let healthKitWorkoutService: HealthKitWorkoutService
}
