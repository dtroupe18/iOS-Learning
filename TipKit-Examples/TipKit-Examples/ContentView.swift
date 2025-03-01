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
                                .padding(.vertical, 8)
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
        case popover = "Popover Tip"
        case action = "Action Tip"
        case rule = "Rule Tip"
        case ruleTwo = "Rule Tip Two"
        case event = "Event Tip"

        var id: String { rawValue }

        var view: some View {
            switch self {
            case .inline: return AnyView(InlineTipView())
            case .popover: return AnyView(PopoverTipView())
            case .action: return AnyView(ActionTipView())
            case .rule: return AnyView(RuleTipView())
            case .ruleTwo: return AnyView(RuleTipTwoView())
            case .event: return AnyView(EventBasedTipView())
            }
        }
    }
}

#Preview {
    ContentView()
}
