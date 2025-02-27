import TipKit

struct InlineTip: Tip {

    init(title: Text, message: Text? = nil, image: Image? = nil) {
        self.title = title
        self.message = message
        self.image = image
    }

    let title: Text
    let message: Text?
    let image: Image?

    static let `default`: Self = .init(
        title: Text("Save as a Favorite"),
        message: Text("Your favorite backyards always appear at the top of the list."),
        image: Image(systemName: "star")
    )
}
