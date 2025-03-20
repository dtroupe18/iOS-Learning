import SwiftData
import SwiftUI

@main
struct RunIntervalsApp: App {
    var body: some Scene {
        WindowGroup {
            WorkoutListView()
        }
        .modelContainer(for: IntervalWorkout.self)
    }
}
