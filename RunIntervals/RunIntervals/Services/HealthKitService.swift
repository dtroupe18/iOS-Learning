import Foundation
import HealthKit

final class HealthKitService {

    init() {}

    /// Requests authorization to access HealthKit data.
    func requestAuthorization() {
        let workoutType = HKObjectType.workoutType()

        let readTypes: Set = [
            workoutType,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!
        ]

        let writeTypes: Set = [workoutType]


        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in
            if success {
                print("HealthKit authorization granted")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }

    private let healthStore = HKHealthStore()
}
