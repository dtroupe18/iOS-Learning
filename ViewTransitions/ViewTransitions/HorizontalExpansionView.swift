import SwiftUI

/// The main view that displays a horizontally expanding menu of circular buttons.
/// This view includes an expandable button group that animates open/closed when the last button is tapped.
struct HorizontalExpansionView: View {

    init(frameWidth: CGFloat) {
        self.frameWidth = frameWidth
    }

    var body: some View {
        HStack {
            // Main horizontal container that holds all buttons
            ZStack(alignment: .leading) {
                // Layer for the expanding buttons (only visible when `isOpen` is true)
                ZStack(alignment: .leading) {
                    // Loop through all button properties, using their index and data
                    ForEach(Array(buttonProperties.enumerated()), id: \.offset) { index, props in
                        // Only show these buttons when the menu is open
                        if isOpen && (index != buttonProperties.count - 1) {
                            CircleButtonView(properties: props)
                                // Apply a custom transition for each button (expand and rotate outward)
                                .transition(
                                    ExpandAndRotateTransition(
                                        axis: .horizontal,
                                        axisLength: frameWidth,
                                        index: index,
                                        numberOfElements: buttonProperties.count
                                    )
                                )
                                .onTapGesture {
                                    props.action() // Trigger the action when tapped
                                }
                                // Staggered appearance effect - each button starts a bit later
                                .animation(
                                    .easeInOut(duration: 0.8)
                                        .delay(Double(index) * 0.05),
                                    value: isOpen
                                )
                        }
                    }
                }
                // Restrict the expanding button area to a fixed width
                .frame(width: frameWidth, alignment: .leading)

                // Main "toggle" button that opens/closes the menu
                HStack {
                    if isOpen {
                        Spacer() // Pushes the toggle button to the right when open
                    }

                    if let lastProps = buttonProperties.last {
                        // Create the main button (either "+" or "xmark" when open)
                        CircleButtonView(
                            properties: CircleButtonProperties(
                                // Swap the symbol between "+" and "xmark" based on state
                                symbol: isOpen ? "xmark" : lastProps.symbol,
                                color: lastProps.color,
                                action: lastProps.action
                            )
                        )
                        // Add subtle rotation effect when toggling the menu
                        .rotationEffect(.degrees(isOpen ? 90 : 0))
                        .onTapGesture {
                            // Tapping this button opens/closes the menu with animation
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isOpen.toggle()
                            }
                        }
                    }
                }
                // Force the toggle button area to the same max width as the full menu
                .frame(maxWidth: frameWidth, alignment: .leading)
            }
        }
        // Ensure the outer container has the same width constraint
        .frame(maxWidth: frameWidth, alignment: .leading)
        // Overall state animation for when the `isOpen` state changes
        .animation(.easeInOut(duration: 0.8), value: isOpen)
    }

    // Array of button configurations for the menu items (each has a symbol, color, and action)
    private let buttonProperties: [CircleButtonProperties] = [
        CircleButtonProperties(
            symbol: "heart.fill",
            color: .pink,
            action: { print("heart") }
        ),
        CircleButtonProperties(
            symbol: "bookmark.fill",
            color: .purple,
            action: { print("bookmark") }
        ),
        CircleButtonProperties(
            symbol: "moon.fill",
            color: .yellow,
            action: { print("moon") }
        ),
        CircleButtonProperties(
            symbol: "message.fill",
            color: .blue,
            action: { print("message") }
        ),
        CircleButtonProperties(
            symbol: "plus", // Initial state shows a "+" button
            color: .teal,
            action: {}
        )
    ]

    // Maximum width of the expanding button menu (80% of screen width)
    private let frameWidth: CGFloat

    // Controls whether the menu is open (showing buttons) or closed (only the toggle button)
    @State private var isOpen: Bool = false
}

#Preview {
    HorizontalExpansionView(frameWidth: UIScreen.main.bounds.width * 4 / 5)
}
