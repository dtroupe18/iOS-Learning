import TipKit

struct ExampleInlineTip: Tip {
    var title: Text {
        Text("Inline Tip Example")
    }

    var message: Text? {
        Text("Your favorite backyards always appear at the top of the list.")
    }

    var image: Image? {
        Image(systemName: "star")
    }
}
