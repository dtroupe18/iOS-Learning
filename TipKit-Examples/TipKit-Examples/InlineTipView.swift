import SwiftUI
import TipKit

struct InlineTipView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text(
                "A TipView embeds itself directly in the view. Make this style of tip your first choice as it doesn't obscure or hide any underlying UI elements."
            )

            // Place your tip near the feature you want to highlight.
            TipView(inlineTip, arrowEdge: .bottom)
            Button {
                // Invalidate the tip when someone uses the feature.
                inlineTip.invalidate(reason: .actionPerformed)
            } label: {
                Label("Favorite", systemImage: "star")
            }

            Text(
                "To dismiss the tip, tap the close button in the upper right-hand corner of the tip or tap the Favorite button to use the feature, which then invalidates the tip programmatically."
            )

            Spacer()
        }
        .padding()
        .navigationTitle("Inline Tip View")
    }

    private let inlineTip = ExampleTip.inline
}

#Preview {
    InlineTipView()
}
