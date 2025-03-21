import Combine
import HealthKit

final class HealthKitService: NSObject, ObservableObject {
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var isWorkoutActive: Bool = false
    @Published var heartRate: Double = 0.0

    private var cancellables = Set<AnyCancellable>()

    // Check if HealthKit is available on the device
    static var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Request authorization to access HealthKit data
    func requestAuthorization() {
        // qwe this is copy paste
        let workoutType = HKObjectType.workoutType()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let readTypes: Set = [workoutType, heartRateType]
        let writeTypes: Set = [workoutType]

        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("HealthKit authorization granted")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
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
}

extension HealthKitService: HKWorkoutSessionDelegate {
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

extension HealthKitService: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

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

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        print("Workout event collected")
    }
}
