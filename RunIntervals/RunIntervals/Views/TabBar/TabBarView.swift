import SwiftUI

final class TabBarViewModel {

    init(dependencyContainer: DependencyContainer) {
        self.dependencyContainer = dependencyContainer

        self.workoutListViewModel = .init(dependencyContainer: dependencyContainer)
        self.workoutRecordsViewModel = .init(dependencyContainer: dependencyContainer)
    }

    let workoutListViewModel: WorkoutListViewModel
    let workoutRecordsViewModel: WorkoutRecordsViewModel

    private let dependencyContainer: DependencyContainer
}

struct TabBarView: View {

    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView {
            WorkoutListView(viewModel: viewModel.workoutListViewModel)
                .tabItem {
                    Label("Workouts", systemImage: "figure.run")
                }


            WorkoutRecordsView(viewModel: viewModel.workoutRecordsViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }

    private let viewModel: TabBarViewModel
}

#Preview {
    TabBarView(
        viewModel: TabBarViewModel(
            dependencyContainer: PreviewDependencyContainer()
        )
    )
}
