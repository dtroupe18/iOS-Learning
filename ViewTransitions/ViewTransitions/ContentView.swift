import SwiftUI

struct ContentView: View {

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 32) {
                VStack(spacing: 0) {
                    Text("Horizontal Expansion")
                        .padding(.bottom, 8)

                    HorizontalExpansionView(frameWidth: geo.size.width * 0.8)
                }

                VStack(spacing: 0) {
                    Text("Vertical Expansion")
                        .padding(.bottom, 8)

                    VerticalExpansionView(frameHeight: geo.size.width * 0.8)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    ContentView()
}
