import SwiftUI

@main
struct RunIntervalsApp: App {
    var body: some Scene {
        WindowGroup {
            TabBarView(
                viewModel: TabBarViewModel(dependencyContainer: appDependencyContainer)
            )
        }
    }

    let appDependencyContainer: DependencyContainer = AppDependencyContainer()
}
