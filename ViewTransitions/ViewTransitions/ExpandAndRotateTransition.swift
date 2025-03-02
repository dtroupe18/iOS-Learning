import SwiftUI

/// `ExpandAndRotateTransition` is a custom transition that animates
/// a view  (or any content) expanding into position along a specified axis (horizontal or vertical),
/// while also fading in and rotating slightly.
///
/// This is designed for view groups that expand in either horizontal or vertical directions,
/// where views appear one by one with spacing, rotation, and opacity effects.
///
/// - Parameters:
///   - axis: The axis along which the views will expand (horizontal or vertical).
///   - axisLength: The total available length (width or height) along the specified axis.
///   - index: The position of the view within the group (0-based index).
///   - numberOfElements: The total number of views in the group, including the main toggle view.
struct ExpandAndRotateTransition: Transition {

    /// Axis along which the views expand (horizontal or vertical).
    private let axis: Axis

    /// The index of the current view in the view array.
    private let index: Int

    /// The total length of the container along the chosen axis (width for horizontal, height for vertical).
    private let axisLength: CGFloat

    /// Total number of views.
    private let numberOfElements: Int

    /// Creates a new `ExpandAndRotateTransition`.
    ///
    /// - Parameters:
    ///   - axis: Horizontal or vertical layout direction.
    ///   - axisLength: Total length of the container along the specified axis.
    ///   - index: Index of the view in the group (0-based).
    ///   - numberOfElements: Total number of views.
    init(axis: Axis, axisLength: CGFloat, index: Int, numberOfElements: Int) {
        self.axis = axis
        self.index = index
        self.axisLength = axisLength
        self.numberOfElements = numberOfElements
    }

    /// Defines the visual effects applied to the view during its transition.
    ///
    /// This method applies three key animations:
    /// - Offset (horizontal or vertical), moving the view into position based on its index.
    /// - Opacity, making it fade in smoothly.
    /// - Rotation, giving it a subtle spin effect.
    ///
    /// - Parameters:
    ///   - content: The view view being transitioned.
    ///   - phase: The current state of the transition (appearing, disappearing, etc.).
    /// - Returns: A view with animated offset, opacity, and rotation.
    func body(content: Content, phase: TransitionPhase) -> some View {
        // Calculate the offset (x for horizontal, y for vertical).
        let offsetValue: CGFloat = calculateOffset(
            index: index,
            axisLength: axisLength,
            phase: phase
        )

        return content
            // Fade in or out depending on phase.
            .opacity(phase.isIdentity ? 1 : phase == .didDisappear ? 0 : 0.5)

            // Rotate slightly during the transition for visual flair.
            .rotationEffect(.degrees(phase.isIdentity ? 90 : 0))

            // Apply offset, either in horizontal (x) or vertical (y) direction.
            .offset(
                x: axis == .horizontal ? offsetValue : 0,
                y: axis == .vertical ? offsetValue : 0
            )
    }

    // MARK: - Offset Calculation Logic

    /// Calculates the offset along the specified axis for the view at a given index.
    ///
    /// This function determines how far from the starting position (top/left) each view should appear.
    /// The offset is calculated based on:
    /// - The view's index (first, second, etc.).
    /// - The total available length (width or height depending on axis).
    /// - The total number of views.
    ///
    /// During the animation, the offset gradually transitions from zero to its final position.
    ///
    /// - Parameters:
    ///   - index: The position of the view (0-based).
    ///   - axisLength: Total available length along the chosen axis.
    ///   - phase: Current transition phase (appearing, disappearing, etc.).
    /// - Returns: The offset to apply to the view along the chosen axis.
    private func calculateOffset(
        index: Int,
        axisLength: CGFloat,
        phase: TransitionPhase
    ) -> CGFloat {

        // Dimension (width or height) of each view (assumed fixed for simplicity).
        let viewSize: CGFloat = 40.0

        // Total available spacing along the axis after accounting for view size.
        let totalSpacing: CGFloat = axisLength - viewSize

        // Space between each view along the axis.
        let spacingPerView = totalSpacing / CGFloat(numberOfElements - 1)

        // Final offset to return (either horizontal or vertical depending on axis).
        var offset: CGFloat

        // First view (index 0) does not move (anchors the start).
        if index == 0 {
            offset = 0
        } else {
            // When fully expanded (isIdentity), position the view at calculated offset.
            if phase.isIdentity {
                offset = CGFloat(index) * spacingPerView
            } else {
                // While transitioning, interpolate offset based on phase.value (progress 0 to 1).
                offset = CGFloat(index) * phase.value
            }
        }

        return offset
    }
}
