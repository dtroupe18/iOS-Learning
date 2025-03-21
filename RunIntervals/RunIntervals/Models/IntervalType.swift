import Foundation
import SwiftUI

enum IntervalType: String, Codable {
    case warmup, lowIntensity, highIntensity, coolDown

    // Computed property to return the color for each interval type
    var color: Color {
        switch self {
        case .warmup, .coolDown:
            return .green
        case .lowIntensity:
            return .yellow
        case .highIntensity:
            return .orange
        }
    }

    // Computed property to return the name for each interval type
    var name: String {
        switch self {
        case .warmup:
            return "Warm-up"
        case .lowIntensity:
            return "Low Intensity"
        case .highIntensity:
            return "High Intensity"
        case .coolDown:
            return "Cool Down"
        }
    }
}

