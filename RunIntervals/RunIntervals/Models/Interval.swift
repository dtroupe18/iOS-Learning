import Foundation
import SwiftUI

struct Interval: Codable, Identifiable {
    let type: IntervalType
    let duration: TimeInterval
    let id: String

    init(
        type: IntervalType,
        duration: TimeInterval,
        id: String
    ) {
        self.type = type
        self.duration = duration
        self.id = id
    }

    var color: Color { type.color }
    var name: String { type.name }

    var healthKitEventMetadata: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return ["interval_data_string": data.base64EncodedString()]
    }
}

struct CompletedInterval: Identifiable {
    let interval: Interval
    let startDate: Date
    let endDate: Date

    var id: String { interval.id }
    var color: Color { interval.color }
}
