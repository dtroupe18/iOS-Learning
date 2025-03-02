import SwiftUI

/// This view represents a vertically expanding menu of circular buttons.
/// When the toggle button is clicked, the buttons expand or collapse with an animation.
/// It uses a custom transition that includes expansion, rotation, and staggered appearance effects.

struct VerticalExpansionView: View {

    /// Initializes the view with a specified height for the menu.
    /// - Parameter frameHeight: The height of the container that holds the buttons.
    init(frameHeight: CGFloat) {
        self.frameHeight = frameHeight
    }

    var body: some View {
        HStack {
            // Main horizontal container that holds the entire vertical button group.
            ZStack(alignment: .topLeading) {

                // Layer that holds the expanding buttons. These are only visible when `isOpen` is true.
                ZStack(alignment: .topLeading) {

                    // Loop through the button properties (with index) to generate the buttons.
                    ForEach(Array(buttonProperties.enumerated()), id: \.offset) { index, props in

                        // Only show the buttons when the menu is open, and avoid showing the last button (toggle button).
                        if isOpen && (index != buttonProperties.count - 1) {
                            CircleButtonView(properties: props)
                                // Apply a custom transition for each button (expand and rotate outward)
                                .transition(
                                    ExpandAndRotateTransition(
                                        axis: .vertical,  // Set to vertical expansion.
                                        axisLength: frameHeight,  // Total available vertical space.
                                        index: index,  // The button's index for staggered animation.
                                        numberOfElements: buttonProperties.count  // Total number of buttons.
                                    )
                                )
                                .onTapGesture {
                                    props.action() // Execute the action associated with the button.
                                }
                                // Apply staggered animation to each button with a slight delay based on its index.
                                .animation(
                                    .easeInOut(duration: 0.8)  // Animation duration for smooth transition.
                                        .delay(Double(index) * 0.05),  // Delay per button for staggered effect.
                                    value: isOpen  // Trigger animation when `isOpen` changes.
                                )
                        }
                    }
                }
                // Restrict the expanding button area to the fixed height (to maintain layout constraints).
                .frame(height: frameHeight, alignment: .topLeading)

                // The main toggle button that controls opening and closing the menu.
                VStack {
                    if isOpen {
                        Spacer() // Push the toggle button to the bottom when the menu is open.
                    }

                    if let lastProps = buttonProperties.last {
                        // Create the toggle button. It switches between "+" and "xmark" based on state.
                        CircleButtonView(
                            properties: CircleButtonProperties(
                                symbol: isOpen ? "xmark" : lastProps.symbol,  // Change symbol based on menu state.
                                color: lastProps.color,
                                action: lastProps.action  // Use the action of the last button.
                            )
                        )
                        // Add subtle rotation effect to the toggle button during the transition.
                        .rotationEffect(.degrees(isOpen ? 90 : 0))  // Rotate the button when toggled.
                        .onTapGesture {
                            // Toggle the state when the button is tapped, causing the menu to open/close.
                            withAnimation(.easeInOut(duration: 0.8)) {
                                isOpen.toggle()  // Toggle the menu open/closed.
                            }
                        }
                    }
                }
                // Ensure the toggle button is aligned to the top leading edge of the container
                .frame(maxWidth: frameHeight, maxHeight: frameHeight, alignment: .topLeading) // Align at the top leading edge
            }
        }
        // Ensure the outer container has the same height constraint to maintain consistent layout.
        .frame(maxHeight: frameHeight, alignment: .topLeading)
        // Apply a smooth overall animation when the `isOpen` state changes (for entire view).
        .animation(.easeInOut(duration: 0.8), value: isOpen)
    }

    // Array of button properties (symbol, color, and action) for the menu items.
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
            symbol: "plus", // Initial state shows a "+" button.
            color: .teal,
            action: {}  // Empty action for the toggle button.
        )
    ]

    // The maximum height of the expanding button menu (in this case, 80% of the screen width).
    private let frameHeight: CGFloat

    // State variable to track whether the menu is open (showing buttons) or closed (only showing the toggle button).
    @State private var isOpen: Bool = false
}

#Preview {
    VerticalExpansionView(frameHeight: UIScreen.main.bounds.width * 0.8)
}
