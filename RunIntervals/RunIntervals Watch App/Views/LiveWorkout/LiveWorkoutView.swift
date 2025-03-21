import SwiftUI

struct LiveWorkoutView: View {

    init(viewModel: LiveWorkoutViewModel) {
        self.viewModel = viewModel
        self.setupViewModelCallbacks()
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)  // Background ring

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(viewModel.currentInterval.color, lineWidth: 5)
                    .rotationEffect(.degrees(-90))  // Start from top
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)

                Text("\(viewModel.timeRemainingString)")
                    .font(.largeTitle)
                    .monospacedDigit()
            }
            .frame(width: 100, height: 100)

            Text(viewModel.currentInterval.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(viewModel.currentInterval.color)

            Text(roundText)
                .font(.system(size: 12))

            // Heart rate display
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .scaleEffect(viewModel.isRunning ? 1.2 : 1.0)  // Scale up and down
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: viewModel.isRunning
                    )

                Text("\(viewModel.heartRate) BPM")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            }

            Button(viewModel.isRunning ? "Stop Workout" : "Start Workout") {
                if viewModel.isRunning {
                    viewModel.stopWorkout()
                } else {
                    viewModel.startWorkout()
                }
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .onAppear {
            viewModel.requestHealthKitPermission()
        }
        .padding(.vertical, 8)
        .navigationBarBackButtonHidden(true)  // Hide the back button
    }

    private let viewModel: LiveWorkoutViewModel

    @Environment(\.dismiss) private var dismiss

    private var roundText: String {
        "Round \(viewModel.currentRound) of " +
        // Half of intervals are work-rest pairs.
        "\(String(format: "%.0f", Double(viewModel.intervals.count / 2)))"
    }

    private func setupViewModelCallbacks() {
        self.viewModel.onWorkoutComplete = {
            dismiss()  // Dismiss the view when the workout is complete
        }

        self.viewModel.onPlaySound = {
            WKInterfaceDevice.current().play(.notification)  // Play a sound
        }
    }
}
