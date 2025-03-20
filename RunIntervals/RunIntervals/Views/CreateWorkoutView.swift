import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutListViewModel

    @State private var workoutName: String = ""
    @State private var rounds: Int = 5
    @State private var highIntensityDuration: TimeInterval = 30
    @State private var lowIntensityDuration: TimeInterval = 30
    @State private var warmupDuration: TimeInterval = 5 * 60  // Default 5 minutes
    @State private var cooldownDuration: TimeInterval = 5 * 60  // Default 5 minutes

    init(viewModel: WorkoutListViewModel) {
        self.viewModel = viewModel
    }

    private var intervals: [Interval] {
        var intervals = [Interval(type: .warmup, duration: warmupDuration)]
        intervals.append(contentsOf: IntervalWorkout.generateIntervals(
            rounds: rounds,
            highIntensityDurtion: highIntensityDuration,
            lowIntensityDuration: lowIntensityDuration
        ))
        intervals.append(Interval(type: .coolDown, duration: cooldownDuration))
        return intervals
    }

    private var totalDuration: String {
        let totalSeconds = intervals.reduce(0) { $0 + $1.duration }
        return totalSeconds.formattedString
    }

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Workout Details")) {
                    TextField("Workout Name", text: $workoutName)
                        .textFieldStyle(.roundedBorder)

                    Stepper("Rounds: \(rounds)", value: $rounds, in: 1...50)

                    VStack(alignment: .leading) {
                        Text("High Intensity Duration: \(highIntensityDuration.formattedString)")
                        Slider(value: $highIntensityDuration, in: 5...60, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Low Intensity Duration: \(lowIntensityDuration.formattedString)")
                        Slider(value: $lowIntensityDuration, in: 5...60, step: 5)
                    }

                    VStack(alignment: .leading) {
                        Text("Warmup Duration: \(warmupDuration.formattedString)")
                        Slider(value: $warmupDuration, in: 0...10 * 60, step: 30)
                    }

                    VStack(alignment: .leading) {
                        Text("Cooldown Duration: \(cooldownDuration.formattedString)")
                        Slider(value: $cooldownDuration, in: 0...10 * 60, step: 30)
                    }
                }

                Section(header: Text("Intervals")) {
                    ForEach(intervals, id: \.id) { interval in
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

            Text("Total Duration: \(totalDuration)")
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
                    viewModel.saveWorkout(name: workoutName, intervals: intervals)
                    dismiss()
                }
                .disabled(workoutName.isEmpty)
            }
        }
    }
}

#Preview {
    struct Preview: View {
        var body: some View {
            makeBody()
        }

        private func makeBody() -> AnyView {
            do {
                let container = try ModelContainer(
                    for: IntervalWorkout.self,
                    configurations: .init(isStoredInMemoryOnly: true)
                )

                let mockViewModel = WorkoutListViewModel()
                mockViewModel.modelContext = container.mainContext
                return AnyView(NavigationStack {
                    CreateWorkoutView(viewModel: mockViewModel)
                }
                .modelContainer(container))
            } catch {
                return AnyView(Text("Failed to create preview: \(error.localizedDescription)"))
            }
        }
    }

    return Preview()
}

