import SwiftData
import SwiftUI

@Observable
class WorkoutListViewModel {
    private(set) var workouts: [IntervalWorkout] = []

    var modelContext: ModelContext?

    // Load all workouts from SwiftData
    func loadWorkouts() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<IntervalWorkout>()
        do {
            let loadedWorkouts = try context.fetch(descriptor)
            if loadedWorkouts.isEmpty {
                workouts = [IntervalWorkout.sample()]
            } else {
                workouts = loadedWorkouts
            }

        } catch {
            print("Failed to load workouts: \(error)")
        }
    }

    // Save a new workout
    func saveWorkout(name: String, intervals: [Interval]) {
        guard let context = modelContext else { return }
        let workout = IntervalWorkout(name: name, intervals: intervals)
        context.insert(workout)
        do {
            try context.save()
            loadWorkouts()  // Refresh list
        } catch {
            print("Failed to save workout: \(error)")
        }
    }

    // Delete a workout
    func deleteWorkout(_ workout: IntervalWorkout) {
        guard let context = modelContext else { return }
        context.delete(workout)
        do {
            try context.save()
            loadWorkouts()
        } catch {
            print("Failed to delete workout: \(error)")
        }
    }
}
