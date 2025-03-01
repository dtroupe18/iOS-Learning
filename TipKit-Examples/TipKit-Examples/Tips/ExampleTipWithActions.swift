import Foundation
import TipKit

struct ExampleTipWithActions: Tip {

    var title: Text {
        Text("Example Tip with Actions")
    }

    var message: Text? {
        Text("Do you need help logging in to your account?")
    }

    var image: Image? {
        Image(systemName: "lock.shield")
    }

    // Non-sendable type so has to be read only.
    var actions: [Action] {
        // Define a reset password button.
        Action(id: "reset-password", title: "Reset Password")
        // Define a FAQ button.
        Action(id: "faq", title: "View our FAQ")
    }
}
