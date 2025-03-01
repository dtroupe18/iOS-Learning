import SwiftUI

struct ColorView: View {
    let index: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(colorForIndex(index))
            .overlay(
                Text("Item \(index + 1)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            )
    }

    func colorForIndex(_ index: Int) -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .teal, .cyan, .brown,
        ]
        return colors[index % colors.count]
    }
}

#Preview {
    ColorView(index: 3)
}
