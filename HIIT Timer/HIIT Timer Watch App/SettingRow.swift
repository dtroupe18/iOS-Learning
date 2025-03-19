import SwiftUI

struct SettingRow<Destination: View>: View {

    var value: Double
    var settingType: HIITSettingType
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Circle()
                    .fill(settingType.color)
                    .frame(width: 12, height: 12) // Small color indicator

                VStack(alignment: .leading) {
                    Text(settingType.name)
                        .font(.system(size: 14, weight: .bold))
                }

                Spacer()

                if settingType.isTimeBased {
                    Text(formatTime(value))
                        .font(.system(size: 14))
                        .monospacedDigit() // Keeps time formatting aligned
                } else {
                    Text(String(format: "%.0f", value))
                        .font(.system(size: 14))
                        .monospacedDigit() // Keeps time formatting aligned
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
    }

    /// Formats time into `M:SS` or `:SS` format
    private func formatTime(_ seconds: Double) -> String {
        let intSeconds = Int(seconds)
        let minutes = intSeconds / 60
        let remainingSeconds = intSeconds % 60

        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        } else {
            return String(format: ":%02d", remainingSeconds)
        }
    }
}

#Preview {
    SettingRow(
        value: 90,
        settingType: .work,
        destination: AdjustDetailView(
            value: .constant(90),
            type: .work
        )
    )

}
