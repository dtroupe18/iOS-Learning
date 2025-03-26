import SwiftUI

// qwe view suffix
struct WorkoutRecordDetails: View {

    init(viewModel: WorkoutRecordDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.workoutName)
                .font(.title)
                .bold()

            HeartRateGraphView(
                heartRateReadings: viewModel.heartRateReadings,
                completedIntervals: viewModel.completedIntervals,
                avgHeartRate: viewModel.averageHeartRate ?? 0
            )

            if let hr = viewModel.averageHeartRateString {
                LabeledContent("Average HR", value: hr)
            }

            if let caloriesBurned = viewModel.caloriesString {
                LabeledContent("Calories", value: caloriesBurned)
            }

            if let distanceString = viewModel.distanceString {
                LabeledContent("Distance", value: distanceString)
            }

            if let paceString = viewModel.paceString {
                LabeledContent("Pace", value: paceString)
            }

            LabeledContent("Duration", value: viewModel.durationString)
        }
        .onAppear {
            viewModel.onAppear()
        }
        .padding()
    }

    @State private var viewModel: WorkoutRecordDetailsViewModel
}

// TODO: Mock records for preview

//#Preview {
//    WorkoutRecordDetails()
//}
