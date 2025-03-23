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
            return "WARM UP"
        case .lowIntensity:
            return "LOW INTENSITY"
        case .highIntensity:
            return "HIGH INTENSITY"
        case .coolDown:
            return "COOL DOWN"
        }
    }
}

