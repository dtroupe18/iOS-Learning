import SwiftUI

/// `CircleButtonProperties` defines the configuration for a circular button,
/// including its symbol, color, and action to perform when tapped.
struct CircleButtonProperties: Identifiable {

    /// Unique identifier to conform to `Identifiable` protocol,
    /// which is useful when these buttons are displayed in lists or ForEach loops.
    let id = UUID()

    /// The name of the system image (SF Symbol) to display in the button.
    let symbol: String

    /// The background color of the circular button.
    let color: Color

    /// The action to perform when the button is tapped.
    let action: () -> Void
}

/// `CircleButtonView` displays a circular button with a configurable icon,
/// background color, and shadow. This view does not directly handle taps —
/// it expects its parent to provide tap handling logic using `.onTapGesture`.
struct CircleButtonView: View {

    /// Initializes the button with the given properties.
    ///
    /// - Parameter properties: The properties that define the button's appearance and behavior.
    init(properties: CircleButtonProperties) {
        self.properties = properties
    }

    /// Defines the appearance of the circular button.
    ///
    /// This is a small circle with a solid color background, a centered SF Symbol icon, and a slight shadow.
    var body: some View {
        ZStack {
            // Background circle filled with the configured color.
            Circle()
                .fill(properties.color)

                // Center the symbol inside the circle.
                .overlay {
                    Image(systemName: properties.symbol)
                        .foregroundColor(.white) // Icon color is white for contrast.
                        .bold() // Makes the symbol slightly thicker.
                        // Account for the amount of rotation the animation will do.
                        .rotationEffect(.degrees(-90))
                }
        }
        .frame(width: 40) // Fixed size for all buttons.
        .shadow(
            color: .gray.opacity(0.5), // Subtle shadow for depth.
            radius: 2.0,
            x: 1.0, y: 1.0
        )
    }

    /// Properties that define the button’s appearance (color, symbol) and behavior (action).
    private let properties: CircleButtonProperties
}

/// Provides a preview for `CircleButtonView` inside Xcode's canvas.
/// This preview demonstrates a pink "heart" button.
#Preview {
    CircleButtonView(
        properties: CircleButtonProperties(
            symbol: "heart.fill",     // SF Symbol representing a filled heart.
            color: .pink,              // Background color.
            action: { print("heart") } // Example action (prints "heart").
        )
    )
}
