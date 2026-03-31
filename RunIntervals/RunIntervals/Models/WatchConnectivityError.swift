import Foundation

enum WatchConnectivityError: LocalizedError {
    case notSupported
    case notConnected
    case encodingFailed
    case sendFailed(String)

    var errorDescription: String? {
        switch self {
        case .notSupported: return "Watch connectivity not supported."
        case .notConnected: return "Watch not connected."
        case .encodingFailed: return "Failed to encode data."
        case .sendFailed(let string): return "Failed to send data: \(string)"
        }
    }
}
