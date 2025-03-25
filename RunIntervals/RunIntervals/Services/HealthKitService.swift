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

    #if !os(watchOS)
    func loadWorkouts(workoutID: String?) async throws -> [WorkoutRecord] {

        do {
            let healthKitWorkouts = try await loadHealthKitWorkouts()
            let workoutRecords: [WorkoutRecord] = healthKitWorkouts.map {
                self.createWorkoutRecord(from: $0)
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
        let workoutType = HKObjectType.workoutType()

        // Create a continuation to use async/await
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: nil, // Fetch all workouts or you can modify this for filtering
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
        if let workoutData = healthKitWorkout.metadata?["workout_data"] as? Data {
            do {
                let decodedWorkout = try JSONDecoder().decode(
                    IntervalWorkout.self,
                    from: workoutData
                )

                return WorkoutRecord(
                    intervalWorkout: decodedWorkout,
                    healthKitWorkout: healthKitWorkout
                )

            } catch {
                self.logger.error("Failed to decode IntervalWorkout metadata: \(error.localizedDescription)")
                return WorkoutRecord(intervalWorkout: nil, healthKitWorkout: healthKitWorkout)
            }
        }

        return WorkoutRecord(intervalWorkout: nil, healthKitWorkout: healthKitWorkout)
    }
    #endif
}
