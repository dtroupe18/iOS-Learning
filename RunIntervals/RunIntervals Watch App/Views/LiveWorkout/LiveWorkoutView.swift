import SwiftUI
import WatchKit

// qwe some kinda wokrout summary to display at the end?
struct LiveWorkoutView: View {

    init(viewModel: LiveWorkoutViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            TabView(selection: $selectedTab) {
                intervalWorkoutView()
                    .tag(0)

                NowPlayingView()
                    .tag(1)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .onAppear {
            viewModel.onAppear()
            setupViewModelCallbacks()
        }
        .navigationBarBackButtonHidden(true)
    }

    @State private var viewModel: LiveWorkoutViewModel
    @State private var selectedTab = 0

    @Environment(\.dismiss) private var dismiss

    private func intervalWorkoutView() -> some View {
        VStack(spacing: 4) {
            Text(viewModel.currentIntervalDescription)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(viewModel.currentInterval.color)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(viewModel.currentInterval.color, lineWidth: 5)
                    .rotationEffect(.degrees(-90))  // Start from top
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)

                Text("\(viewModel.timeRemainingString)")
                    .font(.system(size: 24, weight: .bold))
                    .monospacedDigit()
            }
            .frame(width: 80, height: 80)

            metricsView()
            buttons()
        }
    }

    private func metricsView() -> some View {
        VStack {
            // Distance display
            HStack {
                Image(systemName: "map.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.blue)

                Text(viewModel.distanceString)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.blue)
            }

            // Pace display
            HStack {
                Image(systemName: "clock.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.orange)

                Text(viewModel.paceString)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
            }

            // Heart rate display
            HStack {
                Text("\(viewModel.heartRateString)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)

                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.red)
                    .scaleEffect(viewModel.isRunning ? 0.8 : 1.0)  // Scale up and down
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: viewModel.isRunning
                    )
            }
        }
    }

    private func buttons() -> some View {
        HStack(spacing: 16) {
            Button(action: {
                if viewModel.isRunning {
                    viewModel.stopWorkout()
                } else {
                    viewModel.startWorkout()
                }
            }) {
                VStack(spacing: 0) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                    Text(viewModel.isRunning ? "Pause" : "Start")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(viewModel.isRunning ? Color.red.opacity(0.5) : Color.green.opacity(0.5))
            .clipShape(Capsule())
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                if viewModel.isRunning {
                    viewModel.stopWorkout()
                } else {
                    dismiss()
                }
            }) {
                VStack(spacing: 0) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                    Text(viewModel.isRunning ? "End" : "Exit")
                        .font(.system(size: 8))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.5))
            .clipShape(Capsule())
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func setupViewModelCallbacks() {
        self.viewModel.onWorkoutComplete = {
            dismiss()  // Dismiss the view when the workout is complete
        }
    }
}

#Preview {
    LiveWorkoutView(
        viewModel: LiveWorkoutViewModel(
            dependencyContainer: DependencyContainer(),
            workout: IntervalWorkout(
                name: "Test",
                intervals: [
                    Interval(type: .warmup, duration: 10, id: "1"),
                    Interval(type: .highIntensity, duration: 10, id: "2"),
                    Interval(type: .lowIntensity, duration: 10, id: "3"),
                    Interval(type: .coolDown, duration: 10, id: "4"),
                ]
            )
        )
    )
}
