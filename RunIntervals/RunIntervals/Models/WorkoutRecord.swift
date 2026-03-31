import Foundation
import HealthKit

struct WorkoutRecord {
    let intervalWorkout: IntervalWorkout?
    let healthKitWorkout: HKWorkout
}

extension WorkoutRecord {
    #if DEBUG
    static let previewWorkoutRecord: WorkoutRecord = {
        let sampleWorkout = IntervalWorkout.previewWorkout
        let sampleHKWorkout = HKWorkout.previewWorkout()

        return WorkoutRecord(
            intervalWorkout: sampleWorkout,
            healthKitWorkout: sampleHKWorkout
        )
    }()
    #endif
}
