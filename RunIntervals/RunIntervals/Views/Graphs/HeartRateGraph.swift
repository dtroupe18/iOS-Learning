import SwiftUI
import Charts

struct HeartRateGraphView: View {

    init(
        heartRateReadings: [HeartRateReading],
        completedIntervals: [CompletedInterval],
        avgHeartRate: Double
    ) {
        self.heartRateReadings = heartRateReadings
        self.completedIntervals = completedIntervals
        self.avgHeartRate = avgHeartRate
    }

    var body: some View {
        VStack {
            Text("Heart Rate")
                .font(.headline)
                .padding(.top)

            ScrollView(.horizontal) {
                VStack {
                    // Create the chart
                    createChart()
                        .frame(width: 1000, height: 250)
                        .padding()
                }
            }
            .frame(height: 300)
        }
        .padding()
    }

    private let heartRateReadings: [HeartRateReading]
    private let completedIntervals: [CompletedInterval]
    private let avgHeartRate: Double

    // Function to create the chart
    private func createChart() -> some View {
        return Chart {
            // Create interval background and markers
            createIntervalMarkers()

            // Create the heart rate line graph
            createHeartRateLineGraph()
        }
        .chartYScale(domain: 60...200)
    }

    // Function to create interval markers and background
    private func createIntervalMarkers() -> some ChartContent {
        ForEach(completedIntervals) { interval in
            // Background color for the interval
            createIntervalBackground(interval: interval)

            // Start marker with label
            createStartMarker(interval: interval)

            // End marker
            createEndMarker(interval: interval)
        }
    }

    // Function to create the interval background
    private func createIntervalBackground(interval: CompletedInterval) -> some ChartContent {
        RectangleMark(
            xStart: .value("Start", interval.startDate),
            xEnd: .value("End", interval.endDate),
            yStart: .value("Min HR", 60),
            yEnd: .value("Max HR", 200)
        )
        .foregroundStyle(interval.color.opacity(0.2))
    }

    // Function to create the start marker with a label
    private func createStartMarker(interval: CompletedInterval) -> some ChartContent {
        RuleMark(x: .value("Start", interval.startDate))
            .foregroundStyle(.white)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
    }

    // Function to create the end marker
    private func createEndMarker(interval: CompletedInterval) -> some ChartContent {
        RuleMark(x: .value("End", interval.endDate))
            .foregroundStyle(.white)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
    }

    // Function to create the heart rate line graph
    private func createHeartRateLineGraph() -> some ChartContent {
        ForEach(heartRateReadings) { reading in
            LineMark(
                x: .value("Time", reading.timestamp),
                y: .value("Heart Rate", reading.heartRate)
            )
            .foregroundStyle(.red)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
    }
}
