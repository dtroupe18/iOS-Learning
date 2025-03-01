import SwiftUI

struct ContentView: View {

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                Text("Scroll Transitions")
                    .font(.headline)

                List {
                    NavigationLink(destination: {
                        ScaleScrollTransitionView()
                    }, label: {
                        Text("Scale Scroll Transition")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    })

                    NavigationLink(destination: {
                        ScaleFadeScrollTransitionView()
                    }, label: {
                        Text("Scale Fade Scroll Transition")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    })

                    NavigationLink(destination: {
                        BlurFadeScrollTransitionView()
                    }, label: {
                        Text("Blur Fade Scroll Transition")
                            .font(.subheadline)
                            .padding(.vertical, 8)
                    })
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

    @State private var navPath = NavigationPath()
}

#Preview {
    ContentView()
}
