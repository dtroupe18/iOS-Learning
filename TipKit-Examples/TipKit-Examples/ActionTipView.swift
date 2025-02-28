import SwiftUI
import TipKit

struct ActionTipView: View {

    var body: some View {
        VStack(spacing: 20) {
            Text(
                """
                Use action buttons to link to more options. In this example, two actions buttons \
                are provided. One takes the user to the Reset Password feature. The other sends \
                them to an FAQ page.
                """
            )

            // Place your tip near the feature you want to highlight.
            TipView(tip, arrowEdge: .bottom) { action in
                // Define the closure that executes when someone presses the reset button.
                if action.id == "reset-password", let url = URL(string: "https://iforgot.apple.com")
                {
                    openURL(url) { accepted in
                        print(accepted ? "Success Reset" : "Failure")
                    }
                }

                // Define the closure that executes when someone presses the FAQ button.
                if action.id == "faq", let url = URL(string: "https://appleid.apple.com/faq") {
                    openURL(url) { accepted in
                        print(accepted ? "Success FAQ" : "Failure")
                    }
                }
            }
            Button("Login") {
                // Perform login action.
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Password reset")
    }

    @Environment(\.openURL) private var openURL

    // Create an instance of your tip content.
    private let tip = ExampleTipWithActions()
}

#Preview {
    ActionTipView()
}
