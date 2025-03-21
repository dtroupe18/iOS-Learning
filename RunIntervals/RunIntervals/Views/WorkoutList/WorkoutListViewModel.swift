import SwiftUI

@Observable
final class WorkoutListViewModel {

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer
    }

    private(set) var workouts: [IntervalWorkout] = []

    func onAppear() {
        loadWorkouts()
        healthKitService.requestAuthorization()
    }

    /// Delete a workout
    func deleteWorkout(_ workout: IntervalWorkout) {
        dataService.delete(workout)
        workouts = workouts.filter { $0.id != workout.id }
    }

    func makeCreateWorkoutViewModel(workout: IntervalWorkout?) -> CreateWorkoutViewModel {
        CreateWorkoutViewModel(dependencyContainer: dependencyContainer, existingWorkout: workout)
    }

    func syncWorkoutsToWatch() async throws {
        try await watchConnectivityManager.sendWorkoutsToWatch(workouts: workouts)
    }

    private let dependencyContainer: DependencyContainer
    private var dataService: DataService { dependencyContainer.dataService }
    private let healthKitService = HealthKitService()

    private var watchConnectivityManager: WatchConnectivityManager {
        dependencyContainer.watchConnectivityManager
    }

    /// Load all workouts from SwiftData
    private func loadWorkouts() {
        let loadedWorkouts: [IntervalWorkout] = dataService.load()
        if loadedWorkouts.isEmpty {
            workouts = [IntervalWorkout.sample()]
        } else {
            workouts = loadedWorkouts
        }
    }
}
