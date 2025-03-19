import SwiftUI

struct HomeView: View {
    @StateObject var settings = HIITSettings()
    @State private var navigateToAdjust = false
    @State private var navigateToWorkout = false

    var body: some View {
        NavigationStack {
            VStack {
                SettingRow(
                    value: settings.workTime,
                    settingType: .work,
                    destination: AdjustDetailView(
                        value: $settings.workTime,
                        type: .work
                    )
                )

                SettingRow(
                    value: settings.restTime,
                    settingType: .rest,
                    destination: AdjustDetailView(
                        value: $settings.restTime,
                        type: .rest
                    )
                )

                SettingRow(
                    value: settings.rounds,
                    settingType: .rounds,
                    destination: AdjustDetailView(
                        value: $settings.rounds,
                        type: .rounds
                    )
                )

                NavigationLink(
                    "Start Workout",
                    destination: WorkoutView(settings: settings)
                )
            }
            .padding(.vertical, 8)
        }
        .onAppear {
            self.healthKitService.requestAuthorization()
        }
    }

    private let healthKitService = HealthKitService()
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
