import Combine
import Foundation
import Observation
import WatchKit

@Observable
final class LiveWorkoutViewModel {

    init(dependencyContainer: WatchDependencyContainer, workout: IntervalWorkout) {
        self.healthKitService = dependencyContainer.healthKitService
        self.healthKitWorkoutService = dependencyContainer.healthKitWorkoutService
        self.audioManager = dependencyContainer.audioManager
        self.workout = workout

        timeRemaining = workout.intervals[currentIntervalIndex].duration
    }

    var onWorkoutComplete: (() -> Void)?

    private(set) var currentIntervalIndex: Int = 0
    private(set) var timeRemaining: Double = 0
    private(set) var timer: AnyCancellable?
    private(set) var isRunning = false

    var heartRate: Int { Int(healthKitWorkoutService.heartRate) }
    var heartRateString: String { heartRate > 0 ? "\(heartRate) BPM" : "-- BPM"}

    var distance: Double { healthKitWorkoutService.distance }
    var distanceString: String { "\(String(format: "%.2f", distance)) miles"}

    var pace: Double { healthKitWorkoutService.pace }
    var paceString: String { "\(String(format: "%.2f", pace)) min/mile" }

    var currentIntervalDescription: String {
        switch currentInterval.type {
        case .warmup, .coolDown:
            return currentInterval.type.name
        case .lowIntensity, .highIntensity:
            return currentInterval.type.name +
            " Round \(currentIntervalIndex) of " +
            " of \(totalIntervalRounds)"
        }
    }

    var intervals: [Interval] { workout.intervals }
    var currentInterval: Interval { workout.intervals[currentIntervalIndex] }
    var timeRemainingString: String { timeString(timeRemaining) }
    var progress: CGFloat { CGFloat(timeRemaining) / CGFloat(currentInterval.duration) }

    // Half of intervals are work-rest pairs.
    var totalIntervalRounds: Int { intervals.count / 2 }

    func onAppear() {
        audioManager.prepare()
        healthKitService.requestAuthorization()
    }

    func startWorkout() {
        playRepeatedHaptics()
        audioManager.playBellSound()
        healthKitWorkoutService.startWorkout()
        startTimer()
        isRunning = true
    }

    func stopWorkout() {
        healthKitWorkoutService.stopWorkout()
        timer?.cancel()
        isRunning = false
    }

    // MARK: Private

    private let workout: IntervalWorkout
    private let healthKitService: HealthKitService
    private let healthKitWorkoutService: HealthKitWorkoutService
    private let audioManager: AudioManager

    private func startTimer() {
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
            .sink { _ in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 0.25
                } else {
                    self.audioManager.playBellSound()
                    self.switchInterval()
                    self.playRepeatedHaptics()
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

    private func playRepeatedHaptics(
        count: Int = 10,
        interval: TimeInterval = 0.1
    ) {
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * interval)) {
                WKInterfaceDevice.current().play(.notification)
            }
        }
    }

}
