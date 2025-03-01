import SwiftUI

struct BlurFadeScrollTransitionView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<10) { index in
                    ColorView(index: index)
                        .frame(height: 200)
                        // transition once views are at least 30% visible
                        .scrollTransition(.animated.threshold(.visible(0.3))) { content, phase in
                            content
                                .opacity(phase.isIdentity ? 1 : 0)
                                .scaleEffect(phase.isIdentity ? 1 : 0.75)
                                .blur(radius: phase.isIdentity ? 0 : 10)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    BlurFadeScrollTransitionView()
}
