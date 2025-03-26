import Foundation
import HealthKit

@Observable
final class WorkoutRecordDetailsViewModel {

    init(workoutRecord: WorkoutRecord) {
        self.workoutRecord = workoutRecord
    }

    private(set) var averageHeartRate: Double?
    var averageHeartRateString: String? {
        guard let avgHR = averageHeartRate else { return nil }
        return String(format: "%.0f BPM", avgHR)
    }

    private(set) var heartRateReadings: [HeartRateReading] = []

    private(set) var caloriesBurned: Double?
    var caloriesString: String? {
        guard let caloriesBurned = caloriesBurned else { return nil }
        return String(format: "%.0f kcal", caloriesBurned)
    }

    private(set) var totalDistance: Double?
    var distanceString: String? {
        guard let totalDistance = totalDistance else { return nil }
        return String(format: "%.2f miles", totalDistance)
    }

    private(set) var avgPace: Double?
    var paceString: String? {
        guard let avgPace = avgPace else { return nil }
        // Get the whole minutes and the remaining seconds
        let paceMinutes = Int(avgPace)
        let paceSeconds = Int((avgPace - Double(paceMinutes)) * 60)

        // Format the pace as "mm:ss"
        return String(format: "%02d:%02d min/mile", paceMinutes, paceSeconds)
    }

    private(set) var completedIntervals: [CompletedInterval] = []

    // qwe
    private(set) var vo2Max: Double?
    var vo2MaxString: String? {
        guard let vo2Max = vo2Max else { return nil }
        return String(format: "%.2f L/min", vo2Max)
    }

    var workoutName: String { workoutRecord.intervalWorkout?.name ?? "No Workout Name" }
    var durationString: String { workoutRecord.healthKitWorkout.durationString }

    func onAppear() {
        loadMetrics()
    }

    // MARK: Private

    private func loadMetrics() {
        loadAvgHeartRate()
        loadHeartRateReadings()
        loadCaloriesBurned()
        loadDistanceAndPace()
        loadIntervalMetrics()
    }

    private func loadAvgHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let heartRateStats = workoutRecord.healthKitWorkout.statistics(for: heartRateType)
        let avgHR = heartRateStats?
            .averageQuantity()?
            .doubleValue(for: .count().unitDivided(by: .minute())) ?? 0.0

        if avgHR > 0 {
            self.averageHeartRate = avgHR
        }
    }

    private func loadCaloriesBurned() {
        guard let caloriesType = HKQuantityType.quantityType(
            forIdentifier: .activeEnergyBurned) else {
            return
        }

        let caloriesStats = workoutRecord.healthKitWorkout.statistics(for: caloriesType)
        let totalCalories = caloriesStats?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0.0

        if totalCalories > 0 {
            self.caloriesBurned = totalCalories
        }
    }

    private func loadDistanceAndPace() {
        guard let distanceType = HKQuantityType.quantityType(
            forIdentifier: .distanceWalkingRunning) else {
            return
        }

        let distanceStats = workoutRecord.healthKitWorkout.statistics(for: distanceType)
        let distance = distanceStats?.sumQuantity()?.doubleValue(for: .mile()) ?? 0.0

        // Pace (miles per minute) = total time (minutes) / total distance (miles).
        let timeInMinutes = workoutRecord.healthKitWorkout.duration / 60
        let pace = timeInMinutes / distance

        self.totalDistance = distance
        self.avgPace = pace
    }

    private func loadIntervalMetrics() {
        guard let events = workoutRecord.healthKitWorkout.workoutEvents else { return }
        var completedIntervals: [CompletedInterval] = []

        if let warmupInterval = workoutRecord.intervalWorkout?.intervals.first,
           warmupInterval.type == .warmup {
            
            let start = workoutRecord.healthKitWorkout.startDate
            let end = start.addingTimeInterval(warmupInterval.duration)

            let completedWarmup = CompletedInterval(
                interval: warmupInterval,
                startDate: start,
                endDate: end
            )

            completedIntervals.append(completedWarmup)
        }

        for event in events {
            if let metadata = event.metadata?["interval_data_string"] as? String,
               let data = Data(base64Encoded: metadata),
               let interval = try? JSONDecoder().decode(Interval.self, from: data) {
                let completedInterval = CompletedInterval(
                    interval: interval,
                    startDate: event.dateInterval.start,
                    endDate: event.dateInterval.end
                )

                completedIntervals.append(completedInterval)
            }
        }

        if let coolDownInterval = workoutRecord.intervalWorkout?.intervals.last,
            coolDownInterval.type == .coolDown, let start = completedIntervals.last?.endDate {

            let end = start.addingTimeInterval(coolDownInterval.duration)
            let completedCoolDown = CompletedInterval(
                interval: coolDownInterval,
                startDate: start,
                endDate: end
            )

            completedIntervals.append(completedCoolDown)
        }

        self.completedIntervals = completedIntervals
    }

    private func loadHeartRateReadings() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            return
        }

        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        let predicate = HKQuery.predicateForSamples(
            withStart: workoutRecord.healthKitWorkout.startDate,
            end: workoutRecord.healthKitWorkout.endDate,
            options: .strictStartDate
        )

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sort]
        ) { _, samples, error in

            guard let quantitySamples = samples as? [HKQuantitySample], error == nil else {
                return
            }

            let readings = quantitySamples.map { sample in
                let hr = sample.quantity.doubleValue(
                    for: HKUnit.count().unitDivided(by: HKUnit.minute())
                )

                return HeartRateReading(timestamp: sample.startDate, heartRate: hr)
            }

            DispatchQueue.main.async {
                self.heartRateReadings = readings.sorted { $0.timestamp < $1.timestamp }
            }
        }

        healthStore.execute(query)
    }

    private let workoutRecord: WorkoutRecord
    private let healthStore = HKHealthStore()

}
