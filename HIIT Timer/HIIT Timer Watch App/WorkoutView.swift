import Combine
import SwiftUI

struct WorkoutView: View {
    @ObservedObject var settings: HIITSettings
    @ObservedObject var healthKitService = HealthKitService()

    @State private var currentRound: Int = 1
    @State private var timeRemaining: Double = 0
    @State private var isWorking = true
    @State private var timer: AnyCancellable?
    @State private var isRunning = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 5)  // Background ring

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(currentPhase.color, lineWidth: 5)
                    .rotationEffect(.degrees(-90))  // Start from top
                    .animation(.easeInOut(duration: 0.5), value: progress)

                Text("\(timeString(timeRemaining))")
                    .font(.largeTitle)
                    .monospacedDigit()
            }
            .frame(width: 100, height: 100)

            Text(currentPhase.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(currentPhase.color)

            Text("Round \(currentRound) of \(String(format: "%.0f", settings.rounds))")
                .font(.system(size: 12))

            // Heart rate display
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .scaleEffect(isRunning ? 1.2 : 1.0)  // Scale up and down
                    .animation(
                        .easeInOut(duration: 0.5).repeatForever(autoreverses: true),
                        value: isRunning
                    )

                Text("\(Int(healthKitService.heartRate)) BPM")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.red)
            }

            // TODO: make the HR animate based on the actual rate and the color should
            // match the HR zone the user is in.

            Button(isRunning ? "Stop Workout" : "Start Workout") {
                if isRunning {
                    stopWorkout()
                } else {
                    startWorkout()
                }
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .onAppear {
            timeRemaining = settings.workTime
            healthKitService.requestAuthorization()
        }
        .padding(.vertical, 8)
        .navigationBarBackButtonHidden(true)  // Hide the back button
    }

    private var currentPhase: HIITSettingType {
        isWorking ? .work : .rest
    }

    private var progress: CGFloat {
        CGFloat(timeRemaining) / CGFloat(isWorking ? settings.workTime : settings.restTime)
    }

    private func startWorkout() {
        healthKitService.startWorkout(workoutType: .highIntensityIntervalTraining)
        timeRemaining = settings.workTime
        startTimer()
        isRunning = true
    }

    private func stopWorkout() {
        healthKitService.stopWorkout()
        timer?.cancel()
        isRunning = false
    }

    private func startTimer() {
        timer = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 0.25
                } else {
                    WKInterfaceDevice.current().play(.notification)  // Strong haptic feedback
                    switchInterval()
                }
            }
    }

    private func switchInterval() {
        if isWorking {
            isWorking = false
            timeRemaining = settings.restTime
        } else {
            if currentRound < Int(settings.rounds) {
                currentRound += 1
                isWorking = true
                timeRemaining = settings.workTime
            } else {
                stopWorkout()
                dismiss()
            }
        }
    }

    private func timeString(_ seconds: Double) -> String {
        let intSeconds = Int(seconds)
        let minutes = intSeconds / 60
        let remainingSeconds = intSeconds % 60

        return minutes > 0
            ? String(format: "%d:%02d", minutes, remainingSeconds)
            : String(format: "0:%02d", remainingSeconds)
    }
}

#Preview {
    WorkoutView(
        settings: {
            let settings = HIITSettings()
            settings.workTime = 45
            settings.restTime = 15
            settings.rounds = 3
            return settings
        }())
}
