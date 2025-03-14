import Foundation
import SwiftUI

/// A view that draws two rotating lines originating from the center of the screen.
/// The primary line rotates continuously, while the secondary line rotates relative
/// to the endpoint of the primary line. The positions of the rotating lines are traced
/// and drawn on the screen, forming a continuously evolving path.
/// The lines never overlap because the primary and secondary lines rotate at different
/// rates, causing them to trace distinct paths. The secondary line also rotates relative
/// to the endpoint of the primary line, which ensures that they do not align.
struct RotatingLinesView: View {

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)   // Background color, black

            GeometryReader { geo in
                // GeometryReader allows us to access the size of the container
                // and calculate the center dynamically.
                Color.clear.onAppear {
                    // Once the GeometryReader is available, calculate the center
                    // point of the screen based on its size.
                    center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                }

                // Calculate the endpoint of the primary line by rotating from the center
                let primaryEnd = rotatingPoint(
                    center: center,
                    angle: time,
                    length: min(geo.size.width, geo.size.height) * 0.4
                )

                // The secondary line rotates from the primary line's endpoint, with its rotation
                // angle being `pi * time` to ensure the secondary line rotates at a different rate.
                let secondaryEnd = rotatingPoint(
                    center: primaryEnd,
                    angle: .pi * time,
                    length:  min(geo.size.width, geo.size.height) * 0.3
                )

                // Draw the path traced by the rotating secondary line
                Path { path in
                    if !tracePoints.isEmpty {
                        path.move(to: tracePoints.first!)  // Start from the first trace point
                        for point in tracePoints {         // Draw lines to all trace points
                            path.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.green, lineWidth: 0.5)  // Green trace path

                // Draw the two rotating lines: primary and secondary
                Path { path in
                    path.move(to: center)          // Start from the center
                    path.addLine(to: primaryEnd)   // Draw the primary rotating line
                    path.move(to: primaryEnd)      // Start from the endpoint of the primary line
                    path.addLine(to: secondaryEnd) // Draw the secondary rotating line
                }
                .stroke(Color.clear, lineWidth: 2)  // White rotating lines
            }

            // Text view to show the current time at the top edge of the screen
            VStack(alignment: .trailing) {
                Spacer()

                Text(currentTime)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 50) // Add some padding to the top edge of the screen
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                    .padding(.trailing, 16)
                    .padding(.bottom, 8)
            }
        }
        .onReceive(timer) { _ in
            if isReversing {
                tracePoints.removeLast()
            } else {
                // Update the time and calculate the new points every cycle
                let primaryEnd = rotatingPoint(center: center, angle: time, length: 100)
                let secondaryEnd = rotatingPoint(center: primaryEnd, angle: .pi * time, length: 80)

                // Append the new secondary endpoint to the tracePoints array to visualize the path
                tracePoints.append(secondaryEnd)
            }

            // Increment time to update the rotation angle and progress the animation
            time += timeIncrement
            tickCount += 1

            if tickCount % 10 == 0 {
                // Update the current time every second
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"  // Time format (24-hour format)
                currentTime = formatter.string(from: Date.now)
            }

            // Reverse after 7 minutes.
            if tickCount >= Int(420 / 0.05) {
                isReversing.toggle()
                tickCount = 0
            }
        }
    }

    /// The time variable that controls the rotation speed of the lines.
    /// It is incremented periodically to drive the rotation over time.
    @State private var time: Double = 0.0

    /// An array of points that represent the traced path of the rotating secondary line.
    /// This array is used to visualize the path formed by the secondary line as it rotates.
    @State private var tracePoints: [CGPoint] = []

    /// The center point of the screen, around which the lines will rotate.
    /// This is calculated dynamically using GeometryReader when the view appears.
    @State private var center: CGPoint = .zero

    /// String representation of the current timestamp
    @State private var currentTime: String = ""

    /// Number of times the timer as ticked
    @State private var tickCount: Int = 0

    /// Flag that determines if we are drawing forward or backward.
    @State private var isReversing: Bool = false

    /// A timer that triggers every 0.02 seconds to update the rotation and trace the points.
    /// The timer is used to create the animation effect by changing the `time` value periodically.
    private let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    /// value we update time by to advance the animation.
    private let timeIncrement: Double = 0.05

    /// Calculates the point in a circle's perimeter based on the center, rotation angle, and length.
    /// The point is calculated using basic trigonometry: x = center.x + cos(angle) * length,
    /// y = center.y + sin(angle) * length.
    ///
    /// - Parameters:
    ///   - center: The origin point (center) of the circle.
    ///   - angle: The angle (in radians) to rotate from the center.
    ///   - length: The distance from the center to the point on the perimeter of the circle.
    ///
    /// - Returns: A new point at the calculated position.
    private func rotatingPoint(center: CGPoint, angle: Double, length: CGFloat) -> CGPoint {
        // Use trigonometry (cosine and sine) to calculate the new point's x and y coordinates
        return CGPoint(
            x: center.x + cos(CGFloat(angle)) * length,  // Calculate x using cosine of the angle
            y: center.y + sin(CGFloat(angle)) * length   // Calculate y using sine of the angle
        )
    }
}

#Preview {
    RotatingLinesView()
}
