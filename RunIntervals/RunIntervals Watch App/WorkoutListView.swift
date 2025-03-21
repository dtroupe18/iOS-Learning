import SwiftUI

struct WorkoutListView: View {

    init(viewModel: WorkoutListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.workouts, id: \.id) { workout in
                NavigationLink(destination: LiveWorkoutView(workout: workout)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workout.name)
                                .font(.headline)
                            Text("\(workout.totalDuration)")
                                .font(.subheadline)
                        }

                        Spacer()

                        Button {
                            workoutToDelete = workout
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .contentShape(Rectangle()) // Ensures the entire row is tappable
                }
            }
            .navigationTitle("Workouts")
            .onAppear {
                viewModel.loadWorkouts()
            }
            .alert("Delete Workout?", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    workoutToDelete = nil
                }

                Button("Delete", role: .destructive) {
                    if let workout = workoutToDelete {
                        viewModel.deleteWorkout(workout)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this workout?")
            }
        }
    }

    private let viewModel: WorkoutListViewModel

    @State private var workoutToDelete: IntervalWorkout?
    @State private var showDeleteAlert = false
}

#Preview {
    WorkoutListView(
        viewModel: WorkoutListViewModel(
            dataService: CacheableDataService(directoryName: "watch-preview")
        )
    )
}
