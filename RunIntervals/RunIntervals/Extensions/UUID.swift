import Foundation

extension UUID {
    static var newString: String { UUID().uuidString.lowercased() }
}
