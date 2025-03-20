import SwiftUI

@Observable
final class WorkoutListViewModel {

    init(dataService: DataService) {
        self.dataService = dataService
        self.watchConnectivityManager = WatchConnectivityManager()
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

    private let dataService: DataService
    private let watchConnectivityManager: WatchConnectivityManager

    private func handleWorkoutsFromApp(_ workouts: [IntervalWorkout]) {
        dataService.add(workouts)
        loadWorkouts()
    }
}
