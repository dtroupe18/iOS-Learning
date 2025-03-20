import SwiftData
import SwiftUI

struct WorkoutListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutListViewModel

    init() {
        viewModel = WorkoutListViewModel()
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.workouts, id: \.name) { workout in
                    VStack(alignment: .leading) {
                        Text(workout.name)
                            .font(.headline)
                        Text("\(workout.totalDuration)")
                            .font(.subheadline)
                    }
                }
            }
            .onAppear {
                viewModel.modelContext = modelContext
                viewModel.loadWorkouts()
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CreateWorkoutView(viewModel: viewModel)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutListView()
}
