import SwiftUI

@main
struct RunIntervalsApp: App {
    var body: some Scene {
        WindowGroup {
            WorkoutListView(
                viewModel: WorkoutListViewModel(dependencyContainer: appDependencyContainer)
            )
        }
    }

    let appDependencyContainer: DependencyContainer = AppDependencyContainer()
}
