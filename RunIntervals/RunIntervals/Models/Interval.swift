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
}
