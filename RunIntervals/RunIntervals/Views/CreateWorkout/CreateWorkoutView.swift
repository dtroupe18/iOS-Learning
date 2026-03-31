import SwiftUI

struct CreateWorkoutView: View {
    @State private var viewModel: CreateWorkoutViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: CreateWorkoutViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $viewModel.workoutName)
                        .textFieldStyle(.roundedBorder)

                    Stepper("Rounds: \(viewModel.rounds)", value: $viewModel.rounds, in: 1...50)

                    VStack(alignment: .leading) {
                        Text("High Intensity Duration: \(viewModel.highIntensityDuration.formattedString)")
                        Slider(value: $viewModel.highIntensityDuration, in: 5...60, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Low Intensity Duration: \(viewModel.lowIntensityDuration.formattedString)")
                        Slider(value: $viewModel.lowIntensityDuration, in: 5...60, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Warmup Duration: \(viewModel.warmupDuration.formattedString)")
                        Slider(value: $viewModel.warmupDuration, in: 0...10 * 60, step: 30)
                    }

                    VStack(alignment: .leading) {
                        Text("Cooldown Duration: \(viewModel.cooldownDuration.formattedString)")
                        Slider(value: $viewModel.cooldownDuration, in: 0...10 * 60, step: 30)
                    }
                }

                Section(header: Text("Intervals")) {
                    ForEach(viewModel.intervals, id: \.id) { interval in
                        HStack {
                            Text(interval.type.rawValue.capitalized)
                                .font(.headline)
                            Spacer()
                            Text("\(interval.duration.formattedString)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Text("Total Duration: \(viewModel.totalDuration)")
                .font(.headline)
                .padding()
        }
        .navigationTitle("Create Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    viewModel.saveWorkout()
                    dismiss()
                }
                .disabled(viewModel.workoutName.isEmpty)
            }
        }
    }
}

#Preview {
    CreateWorkoutView(
        viewModel: CreateWorkoutViewModel(dependencyContainer: PreviewDependencyContainer())
    )
}
