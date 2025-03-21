import SwiftUI

struct WorkoutListView: View {

    init(viewModel: WorkoutListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.workouts, id: \.id) { workout in
                    NavigationLink(
                        destination: CreateWorkoutView(
                            viewModel: viewModel.makeCreateWorkoutViewModel(workout: workout)
                        )
                    ) {
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
                            .buttonStyle(BorderlessButtonStyle()) // Prevents row from triggering tap gesture
                        }
                    }
                }
            }
            .overlay(
                // Show activity indicator when syncing
                syncing ? ProgressView("Syncing...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10)) : nil
            )
            .onAppear {
                viewModel.onAppear()
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sync to Watch") {
                        Task {
                            await syncWorkouts()
                        }
                    }
                    .disabled(syncing)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: CreateWorkoutView(
                        viewModel: viewModel.makeCreateWorkoutViewModel(workout: nil))
                    ) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
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
                Text("Are you sure you want to delete this workout? This action cannot be undone.")
            }
        }
    }

    @State private var viewModel: WorkoutListViewModel
    @State private var workoutToDelete: IntervalWorkout?
    @State private var showDeleteAlert = false

    // Syncing state variables
    @State private var syncing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private func syncWorkouts() async {
        syncing = true
        do {
            try await viewModel.syncWorkoutsToWatch()
            alertMessage = "Workouts successfully synced to the watch!"
        } catch {
            alertMessage = "Failed to sync workouts: \(error.localizedDescription)"
        }
        syncing = false
        showAlert = true
    }
}

#Preview {
    WorkoutListView(
        viewModel: WorkoutListViewModel(dependencyContainer: PreviewDependencyContainer())
    )
}
