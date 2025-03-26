import SwiftUI

struct WorkoutRecordsView: View {

    init(viewModel: WorkoutRecordsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading Workouts...")

                case .error(let error):
                    VStack {
                        Text("Failed to load workouts")
                            .font(.headline)
                            .padding()

                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)

                        Button(action: viewModel.retry) {
                            Label("Retry", systemImage: "arrow.clockwise")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding()
                    }

                case .loaded:
                    if viewModel.workoutRecords.isEmpty {
                        Text("No Workouts Found")
                            .font(.headline)
                            .foregroundColor(.gray)
                    } else {
                        List(viewModel.workoutRecords, id: \.healthKitWorkout.uuid) { record in
                            NavigationLink(
                                destination: WorkoutRecordDetails(
                                    viewModel: viewModel.workoutRecordDetailsViewModel(for: record)
                                )
                            ) {
                                WorkoutRecordRow(
                                    record: record,
                                    onDelete: {
                                        viewModel.deleteWorkout(record)
                                    }
                                )
                            }
                        }
                        .refreshable {
                            viewModel.refresh()
                        }
                        .navigationTitle("Workout History")
                    }
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    @State private var viewModel: WorkoutRecordsViewModel
}

#Preview {
    WorkoutRecordsView(
        viewModel: WorkoutRecordsViewModel(
            dependencyContainer: PreviewDependencyContainer()
        )
    )
}
