import SwiftUI
import TipKit

struct RuleTipView: View {

    var body: some View {
        VStack(spacing: 20) {
            // Place your tip near the feature you want to highlight.
            TipView(tip, arrowEdge: .bottom)
                .padding(.horizontal, 16)

            Image(systemName: "photo.on.rectangle")
                .imageScale(.large)

            Button(buttonText) {
                // Trigger a change in app state to make the tip appear or disappear.
                ExampleRuleTip.isEnabled.toggle()
                isDisplayingTip.toggle()
            }
        }
    }

    @State private var isDisplayingTip: Bool = false

    private let tip = ExampleRuleTip()

    var buttonText: String {
        return isDisplayingTip ? "Tap to disable tip" : "Tap to enable tip"
    }
}

#Preview {
    RuleTipView()
}
