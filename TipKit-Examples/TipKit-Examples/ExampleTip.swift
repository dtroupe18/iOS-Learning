import TipKit

struct ExampleTip: Tip {

    init(
        title: Text,
        message: Text? = nil,
        image: Image? = nil
    ) {
        self.title = title
        self.message = message
        self.image = image
    }

    let title: Text
    let message: Text?
    let image: Image?

    static let inline: Self = .init(
        title: Text("Inline Tip Example"),
        message: Text("Your favorite backyards always appear at the top of the list."),
        image: Image(systemName: "star")
    )

    static let popover: Self = .init(
        title: Text("Popover Tip Example").foregroundStyle(.indigo),
        message: Text(
            "Touch and hold \(Image(systemName: "wand.and.stars")) to add an effect to your favorite image."
        )
    )
}

