import SwiftUI
import TipKit

@main
struct TipKit_ExamplesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    init() {
        do {
            #if DEBUG
            try Tips.resetDatastore()
            #endif

            try Tips.configure()
        } catch {
            fatalError("Error configuring tips: \(error)")
        }
    }
}
