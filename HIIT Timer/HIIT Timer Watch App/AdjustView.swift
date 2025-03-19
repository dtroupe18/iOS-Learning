import SwiftUI

struct AdjustDetailView: View {

    init(
        value: Binding<Double>,
        type: HIITSettingType
    ) {
        self._value = value
        self.type = type
    }

    var body: some View {
        VStack {
            Text(type.adjustDetailTitle)
                .font(.system(size: 14, weight: .bold))

            if let subtitle = type.adjustDetailSubtitle {
                Text(subtitle)
                    .font(.system(size: 12))
            }

            Text("\(Int(value))")
                .font(.system(size: 12))
                .focusable()
                .digitalCrownRotation(
                    $value,
                    from: 1,
                    through: 500,
                    by: 1,
                    sensitivity: .medium
                )
        }
    }

    // MARK: Private

    @Binding private var value: Double
    private let type: HIITSettingType
}

#Preview {
    struct Preview: View {
        @State private var previewValue: Double = 30

        var body: some View {
            AdjustDetailView(
                value: $previewValue,
                type: .work
            )
        }
    }

    return Preview()
}
