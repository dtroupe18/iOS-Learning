import HealthKit

extension HKWorkout {
    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }

    #if DEBUG
    static func previewWorkout() -> HKWorkout {
        // qwe create a protocol for this and then stubbing will be much easier.
        let startDate = Date().addingTimeInterval(-1800) // 30 minutes ago
        let endDate = Date()

        return HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            workoutEvents: [],
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 250),
            totalDistance: HKQuantity(unit: .mile(), doubleValue: 3.1),
            device: nil,
            metadata: nil
        )
    }
    #endif
}
