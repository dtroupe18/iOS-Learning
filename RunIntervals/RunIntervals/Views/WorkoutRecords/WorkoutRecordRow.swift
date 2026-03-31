import HealthKit
import SwiftUI

struct WorkoutRecordRow: View {

    init(record: WorkoutRecord, onDelete: @escaping () -> Void) {
        self.record = record
        self.onDelete = onDelete
    }

    var body: some View {
        HStack {
            Image(systemName: "figure.run")
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(record.intervalWorkout?.name ?? "No Workout Name")
                    .font(.headline)
                Text("\(record.healthKitWorkout.startDate.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text("\(record.healthKitWorkout.durationString)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 6)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private let record: WorkoutRecord
    private let onDelete: () -> Void
}

// Preview Example
struct WorkoutRecordRow_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutRecordRow(record: WorkoutRecord.previewWorkoutRecord) {
            print("Workout deleted")
        }
        .previewLayout(.sizeThatFits)
    }
}
