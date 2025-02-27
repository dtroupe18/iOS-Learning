import SwiftUI
import TipKit

struct ContentView: View {

    var body: some View {
        NavigationStack(path: $navPath) {
            VStack {
                Text("TipKit Examples")
                    .font(.headline)

                List {
                    ForEach(TipType.allCases) { tipType in
                        NavigationLink(destination: {
                            tipType.view
                        }, label: {
                            Text(tipType.rawValue)
                                .font(.title)
                        })
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

    @State private var navPath = NavigationPath()

    private enum TipType: String, Identifiable, CaseIterable {
        case inline = "Inline Tip"

        var id: String { rawValue }

        var view: some View {
            switch self {
            case .inline: return InlineTipView()
            }
        }
    }
}

#Preview {
    ContentView()
}
