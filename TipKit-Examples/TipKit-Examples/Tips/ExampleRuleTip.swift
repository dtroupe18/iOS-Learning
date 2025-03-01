import Foundation
import TipKit

struct ExampleRuleTip: Tip {

    // Define the app state you want to track.
    @Parameter
    static var isEnabled: Bool = false

    var title: Text {
        Text("Rule Tip Example")
    }

    var rules: [Rule] {
        // Define a rule based on the app state.
        #Rule(Self.$isEnabled) {
            // Set the conditions for when the tip displays.
            $0 == true
        }
    }
}

