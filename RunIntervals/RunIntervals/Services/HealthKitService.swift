import Foundation
import HealthKit

final class HealthKitService {

    init() {}

    // Request authorization to access HealthKit data
    func requestAuthorization() {
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

    private let healthStore = HKHealthStore()
}
