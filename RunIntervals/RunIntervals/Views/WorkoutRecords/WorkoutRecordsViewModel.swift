import Foundation
import os

@Observable
final class WorkoutRecordsViewModel {

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self.healthKitService = dependencyContainer.healthKitService
        self.logger = dependencyContainer.logger
    }

    enum State {
        case loading
        case error(Error)
        case loaded
    }

    private(set) var state: State = .loading
    private(set) var workoutRecords: [WorkoutRecord] = []

    func onAppear() {
        loadWorkoutRecords()
    }

    func retry() {
        state = .loading
        loadWorkoutRecords()
    }

    func refresh() {
        retry()
    }

    func deleteWorkout(_ record: WorkoutRecord) {
        healthKitService.deleteWorkout(record.healthKitWorkout)
    }

    func workoutRecordDetailsViewModel(for record: WorkoutRecord) -> WorkoutRecordDetailsViewModel {
        WorkoutRecordDetailsViewModel(workoutRecord: record)
    }

    private let dependencyContainer: DependencyContainer
    private let healthKitService: HealthKitService
    private let logger: Logger

    private func loadWorkoutRecords() {
        Task(priority: .background) {
            do {
                let records = try await healthKitService.loadWorkouts(workoutID: nil)
                await MainActor.run {
                    self.workoutRecords = records
                    self.state = .loaded
                }
            } catch {
                logger.error("Error loading workout records: \(error)")
                await MainActor.run {
                    self.state = .error(error)
                }
            }
        }
    }
}
