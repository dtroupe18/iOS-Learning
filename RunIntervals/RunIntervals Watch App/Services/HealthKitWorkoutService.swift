import HealthKit
import Observation
import os

// TODO: Protocol

@Observable
final class HealthKitWorkoutService: NSObject {

    init(logger: Logger) {
        self.logger = logger
    }

    private(set) var isWorkoutActive: Bool = false
    private(set) var heartRate: Double = 0.0
    private(set) var distance: Double = 0.0
    private(set) var pace: Double = 0.0

    /// Check if HealthKit is available on the device
    static var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Start the workout session with live heart rate tracking
    func startWorkout(_ workout: IntervalWorkout) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType  = .running
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder() as? HKLiveWorkoutBuilder

            session?.delegate = self
            builder?.delegate = self
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore, workoutConfiguration: configuration
            )

            let workoutData = try! JSONEncoder().encode(workout)
            let metadata: [String: Any] = [
                "source_app": "com.highTree.RunIntervals",
                "workout_data_string": workoutData.base64EncodedString()
            ]

            builder?.addMetadata(metadata) { success, error in
                if success {
                    self.logger.debug("Interval workout metadata added to healthkit")
                } else if let error = error {
                    self.logger.error("Failed to add  Interval Workout metadata: \(error.localizedDescription)")
                }
            }

            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isWorkoutActive = true
                        self.logger.debug("Live workout session started")
                    }
                } else if let error = error {
                    self.logger.error("Failed to begin workout collection: \(error.localizedDescription)")
                }
            }
        } catch {
            logger.error("Error creating workout session: \(error.localizedDescription)")
        }
    }

    func stopWorkout() {
        guard let builder = builder, let session = session else { return }

        session.end()
        builder.endCollection(withEnd: Date()) { success, error in
            if success {
                builder.finishWorkout { workout, error in
                    DispatchQueue.main.async {
                        self.isWorkoutActive = false
                    }

                    if let error = error {
                        self.logger.error("Failed to finish workout: \(error.localizedDescription)")
                    } else {
                        self.logger.debug("Workout session ended successfully and saved to HealthKit")
                    }
                }
            } else if let error = error {
                self.logger.error("Failed to end workout collection: \(error.localizedDescription)")
            }
        }
    }

    func addWorkoutEventFor(interval: Interval) {
        let event = HKWorkoutEvent(
            type: .segment,
            dateInterval: DateInterval(start: Date.now, duration: interval.duration),
            metadata: interval.healthKitEventMetadata
        )

        // Add event to the HealthKit workout builder.
        builder?.addWorkoutEvents([event]) { success, error in
            if success {
                self.logger.debug("Workout event added successfully")
            } else if let error = error {
                self.logger.error("Failed to add workout event: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Private

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var workoutEvents: [HKWorkoutEvent] = []

    private let runningSpeedType = HKObjectType.quantityType(forIdentifier: .runningSpeed)
    private let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)

    private let logger: Logger

    // Fetch heart rate samples in real time
    private func handleHeartRateSamples(_ samples: [HKSample]) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        for sample in quantitySamples {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let bpm = sample.quantity.doubleValue(for: heartRateUnit)

            DispatchQueue.main.async {
                self.heartRate = bpm
                self.logger.debug("Heart Rate: \(bpm) BPM")
            }
        }
    }

    private func updateDistance() {
        guard let distanceType else { return }

        builder?.statistics(for: distanceType).map {
            self.distance = $0.sumQuantity()?.doubleValue(for: HKUnit.mile()) ?? 0.0
        }
    }

    private func updatePace() {
        guard let runningSpeedType else { return }

        builder?.statistics(for: runningSpeedType).map {
            let avgSpeed = $0.averageQuantity()
            let speed = avgSpeed?.doubleValue(for: HKUnit.mile().unitDivided(by: HKUnit.hour()))

            if let speed, speed > 0 {
                // Convert speed (miles per hour) to pace (minutes per mile)
                self.pace = 60.0 / speed
            } else {
                self.pace = 0.0
            }
        }
    }
}

extension HealthKitWorkoutService: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        logger.error("HealthKitWorkoutService didFailWithError: \(error.localizedDescription)")
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession, didChangeTo state: HKWorkoutSessionState,
        from previousState: HKWorkoutSessionState, date: Date
    ) {
        switch state {
        case .ended:
            logger.debug("Workout session ended")
        case .running:
            logger.debug("Workout session running")
        default:
            break
        }
    }
}

extension HealthKitWorkoutService: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        // Get Heartrate data.
        if let heartRateType {
            if let statistics = workoutBuilder.statistics(for: heartRateType),
                let quantity = statistics.mostRecentQuantity()
            {
                handleHeartRateSamples([
                    HKQuantitySample(
                        type: heartRateType, quantity: quantity, start: statistics.startDate,
                        end: statistics.endDate)
                ])
            }
        }

        // Get running distance
        if let distanceType, collectedTypes.contains(distanceType) {
            self.updateDistance()
        }

        // Get running pace
        if let runningSpeedType, collectedTypes.contains(runningSpeedType) {
            self.updatePace()
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        logger.debug("Workout event collected")
    }
}
