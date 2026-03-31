import Foundation
import HealthKit
import os

enum HealthKitServiceError: LocalizedError {
    case failedToFetchWorkouts(String)
    case failedToCastSamples
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .failedToFetchWorkouts(let string):
            return "Failed to fetch workouts: \(string)"
        case .failedToCastSamples:
            return "Failed to cast samples"
        case .decodingError(let string):
            return "Decoding error: \(string)"
        }
    }
}

final class HealthKitService {

    init(logger: Logger) {
        self.logger = logger
    }

    /// Requests authorization to access HealthKit data.
    func requestAuthorization() {
        let workoutType = HKObjectType.workoutType()

        let readTypes: Set = [
            workoutType,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
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

    #if !os(watchOS)
    func loadWorkouts(workoutID: String?) async throws -> [WorkoutRecord] {

        do {
            let healthKitWorkouts = try await loadHealthKitWorkouts()
            let workoutRecords: [WorkoutRecord] = healthKitWorkouts.map {
                print("#37 metadata \(String(describing: $0.metadata))")

                let events = $0.workoutEvents ?? []
                for event in events {
                    print("#37 Event Type: \(event.type.rawValue)")
                    print("#37 Start: \(event.dateInterval.start), End: \(event.dateInterval.end)")
                    if let metadata = event.metadata {
                        print("#37  event Metadata: \(metadata)")
                    }
                }

                return self.createWorkoutRecord(from: $0)
            }

            self.logger.debug("Successfully fetched \(healthKitWorkouts.count) workouts")
            return workoutRecords

        } catch {
            logger.debug("Error loading healthkit workouts: \(error)")
            throw error
        }
    }
    #endif

    private let healthStore = HKHealthStore()
    private let logger: Logger

    #if !os(watchOS)
    private func loadHealthKitWorkouts() async throws -> [HKWorkout] {
        // Create a continuation to use async/await
        return try await withCheckedThrowingContinuation { continuation in
            let workoutType = HKObjectType.workoutType()
            // Predicate to filter workouts that contain the "source_app" metadata key
            let predicate = NSPredicate(
                format: "metadata.source_app == %@", "com.highTree.RunIntervals")
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                // Handle the query result
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(throwing: HealthKitServiceError.failedToCastSamples)
                    return
                }

                continuation.resume(returning: workouts)
            }

            self.healthStore.execute(query)
        }
    }

    private func createWorkoutRecord(from healthKitWorkout: HKWorkout) -> WorkoutRecord {
        if let workoutDataString = healthKitWorkout.metadata?["workout_data_string"] as? String,
           let workoutData = Data(base64Encoded: workoutDataString) {

            do {
                let intervalWorkout = try JSONDecoder().decode(IntervalWorkout.self, from: workoutData)
                return WorkoutRecord(
                    intervalWorkout: intervalWorkout,
                    healthKitWorkout: healthKitWorkout
                )
            } catch {
                self.logger.error("Failed to decode IntervalWorkout metadata error: \(error)")
                return WorkoutRecord(intervalWorkout: nil, healthKitWorkout: healthKitWorkout)
            }
        } else {
            self.logger.error("Failed to decode IntervalWorkout metadata")
            return WorkoutRecord(intervalWorkout: nil, healthKitWorkout: healthKitWorkout)
        }
    }

    // qwe convert to throws or result.
    func deleteWorkout(_ workout: HKWorkout) {
        let healthStore = HKHealthStore()

        healthStore.delete(workout) { success, error in
            if success {
                self.logger.debug("Workout deleted successfully")
            } else if let error = error {
                self.logger.error("Error deleting workout: \(error.localizedDescription)")
            }
        }
    }
    #endif
}
