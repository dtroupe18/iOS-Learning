import Foundation

struct HeartRateReading: Identifiable {
    let id = UUID()
    let timestamp: Date
    let heartRate: Double
}
