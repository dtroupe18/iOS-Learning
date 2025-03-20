import SwiftUI

@main
struct RunIntervals_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            WorkoutListView(
                viewModel: WorkoutListViewModel(
                    dataService: CacheableDataService(directoryName: "watch-workouts")
                )
            )
        }
    }
}
