import TipKit

struct EventBasedTip: Tip {

    // Define the user interaction you want to track.
    static let buttonPressed = Event(id: "buttonPressed")

    var title: Text {
        Text("Explore Hidden Features!")
    }

    var message: Text? {
        Text(
            "Did you know? You can tap on each item for more details and swipe to favorite or remove it."
        )
    }

    var image: Image? {
        Image(systemName: "lightbulb.fill")
    }

    var rules: [Rule] {
        // Define an event-based rule tracking user state.
        #Rule(Self.buttonPressed) {
            $0.donations.count >= 3
        }
    }

    var options: [Option] {
        // Show this tip once.
        MaxDisplayCount(1)
    }
}
