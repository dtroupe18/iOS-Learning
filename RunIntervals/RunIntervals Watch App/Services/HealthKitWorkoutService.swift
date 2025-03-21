import HealthKit
import Observation

@Observable
final class HealthKitWorkoutService: NSObject {

    var isWorkoutActive: Bool = false
    var heartRate: Double = 0.0
    var distance: Double = 0.0
    var pace: Double = 0.0

    /// Check if HealthKit is available on the device
    static var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Start the workout session with live heart rate tracking
    func startWorkout(workoutType: HKWorkoutActivityType) {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder() as? HKLiveWorkoutBuilder

            session?.delegate = self
            builder?.delegate = self
            builder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore, workoutConfiguration: configuration)

            session?.startActivity(with: Date())  // Start workout session
            builder?.beginCollection(withStart: Date()) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isWorkoutActive = true
                        print("Live workout session started")
                    }
                } else if let error = error {
                    print("Failed to begin workout collection: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error creating workout session: \(error.localizedDescription)")
        }
    }

    // Stop the workout session and save data
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
                        print("Failed to finish workout: \(error.localizedDescription)")
                    } else {
                        print("Workout session ended successfully and saved to HealthKit")
                    }
                }
            } else if let error = error {
                print("Failed to end workout collection: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Private

    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    private let runningSpeedType = HKObjectType.quantityType(forIdentifier: .runningSpeed)
    private let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)

    // Fetch heart rate samples in real time
    private func handleHeartRateSamples(_ samples: [HKSample]) {
        guard let quantitySamples = samples as? [HKQuantitySample] else { return }

        for sample in quantitySamples {
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let bpm = sample.quantity.doubleValue(for: heartRateUnit)

            DispatchQueue.main.async {
                self.heartRate = bpm
                print("Heart Rate: \(bpm) BPM")
            }
        }
    }

    private func updateDistance() {
        guard let distanceType else { return }

        builder?.statistics(for: distanceType).map {
            self.distance = $0.sumQuantity()?.doubleValue(for: HKUnit.meter()) ?? 0.0
        }
    }
    private func updatePace() {
        guard let runningSpeedType else { return }

        builder?.statistics(for: runningSpeedType).map {
            let avgSpeed = $0.averageQuantity()
            let doubleValue = avgSpeed?.doubleValue(
                for: HKUnit.mile().unitDivided(by: HKUnit.second())
            )

            if let speed = doubleValue {
                // Convert speed (miles per second) to pace (minutes per mile)
                self.pace = speed > 0 ? (1.0 / speed) * 60.0 : 0.0
            }
        }
    }
}

extension HealthKitWorkoutService: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error.localizedDescription)")
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession, didChangeTo state: HKWorkoutSessionState,
        from previousState: HKWorkoutSessionState, date: Date
    ) {
        switch state {
        case .ended:
            print("Workout session ended")
        case .running:
            print("Workout session running")
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
        print("Workout event collected")
    }
}
