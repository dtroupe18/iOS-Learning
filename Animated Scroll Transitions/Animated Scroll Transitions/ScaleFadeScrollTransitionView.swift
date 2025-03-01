import SwiftUI

struct ScaleFadeScrollTransitionView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    ColorView(index: index)
                        .frame(height: 200)
                        .scrollTransition(
                            topLeading: .interactive(timingCurve: .easeIn),
                            bottomTrailing: .animated(.bouncy(duration: 0.8)),
                            axis: .vertical
                        ) { content, phase in
                            content
                                // Scale up the bottom view in size as it scroll on screen.
                                .scaleEffect(phase == .bottomTrailing ? 0.9 * phase.value : 1)
                                // Scale the top view down in size as it scrolls off screen.
                                .scaleEffect(phase == .topLeading ? -0.9 * phase.value : 1)
                                // Fading in and out
                                .opacity(phase == .topLeading ? 1 + phase.value : 1 - phase.value)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ScaleFadeScrollTransitionView()
}
