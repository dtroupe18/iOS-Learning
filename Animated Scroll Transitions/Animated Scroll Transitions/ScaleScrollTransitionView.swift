import SwiftUI

struct ScaleScrollTransitionView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    ColorView(index: index)
                        .frame(height: 200)
                        .scrollTransition(
                            .interactive(timingCurve: .easeInOut),
                            axis: .vertical
                        ) { content, phase in
                            // Scale downs the size of the top and bottom views as
                            // they scroll in/out of view.
                            switch phase {
                            case .topLeading, .bottomTrailing:
                                let scaledContent = content.scaleEffect(0.8)
                                return scaledContent
                            case .identity:
                                let scaledContent = content.scaleEffect(1)
                                return scaledContent
                            }
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScaleScrollTransitionView()
}

