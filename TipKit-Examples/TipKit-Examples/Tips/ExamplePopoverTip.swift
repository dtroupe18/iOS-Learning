import TipKit

struct ExamplePopoverTip: Tip {
    var title: Text {
        Text("Popover Tip Example").foregroundStyle(.indigo)
    }

    var message: Text? {
        Text(
            "Touch and hold \(Image(systemName: "wand.and.stars")) to add an effect to your favorite image."
        )
    }
}
