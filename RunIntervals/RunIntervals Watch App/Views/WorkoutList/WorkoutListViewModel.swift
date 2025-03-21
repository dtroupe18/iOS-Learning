import SwiftUI

@Observable
final class WorkoutListViewModel {

    init(dependencyContainer: WatchDependencyContainer) {
        self.dependencyContainer = dependencyContainer
        self.dataService = dependencyContainer.dataService
        self.watchConnectivityManager = dependencyContainer.watchConnectivityManager
        watchConnectivityManager.workoutsHandler = { [weak self] workouts in
            self?.handleWorkoutsFromApp(workouts)
        }
    }

    private(set) var workouts: [IntervalWorkout] = []

    /// Load all workouts from SwiftData
    func loadWorkouts() {
        let loadedWorkouts: [IntervalWorkout] = dataService.load()
        if loadedWorkouts.isEmpty {
            workouts = [IntervalWorkout.sample()]
        } else {
            workouts = loadedWorkouts
        }
    }

    func deleteWorkout(_ workout: IntervalWorkout) {
        dataService.delete(workout)
        workouts = workouts.filter { $0.id != workout.id }
    }

    func liveWorkoutViewModel(for workout: IntervalWorkout) -> LiveWorkoutViewModel {
        LiveWorkoutViewModel(dependencyContainer: dependencyContainer, workout: workout)
    }

    private let dependencyContainer: WatchDependencyContainer
    private let dataService: DataService
    private let watchConnectivityManager: WatchConnectivityManager

    private func handleWorkoutsFromApp(_ workouts: [IntervalWorkout]) {
        dataService.add(workouts)
        loadWorkouts()
    }
}
