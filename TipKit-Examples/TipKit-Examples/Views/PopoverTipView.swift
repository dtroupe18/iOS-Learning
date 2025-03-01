import SwiftUI
import TipKit

struct PopoverTipView: View {

    var body: some View {

        Image(systemName: "wand.and.stars")
            .imageScale(.large)
            // Place the tip on the feature to highlight.
            .popoverTip(tip)
            .onTapGesture {
                // Invalidate the tip when someone uses the feature.
                tip.invalidate(reason: .actionPerformed)
            }
    }

    private let tip = ExamplePopoverTip()
}

#Preview {
    PopoverTipView()
}
