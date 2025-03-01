import SwiftUI
import TipKit

struct RuleTipTwoView: View {

    var body: some View {
        Text("Favorite 3 cars including Viper to see tip")
            .font(.headline)

        TipView(tip)
            .padding(.horizontal, 16)

        List(sportsCars, id: \.self) { car in
            HStack {
                Text(car)
                Spacer()

                Button(action: {
                    toggleFavorite(car: car)
                }) {
                    Image(systemName: favoriteCars.contains(car) ? "heart.fill" : "heart")
                        .foregroundColor(favoriteCars.contains(car) ? .red : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .onAppear {
            // Sync favorites from TipKit on view load
            favoriteCars = ExampleRuleTipTwo.favoriteCars.arrayValue
        }
    }

    private let tip = ExampleRuleTipTwo()

    @State private var favoriteCars: [String] = ExampleRuleTipTwo.favoriteCars.arrayValue

    private let sportsCars = [
        "Corvette",
        "Viper",
        "IS500",
        "911 Turbo",
        "McLaren 720S",
        "Mustang GT",
        "Lamborghini Huracan",
        "Ferrari 488"
    ]

    private func toggleFavorite(car: String) {
        if favoriteCars.contains(car) {
            favoriteCars.removeAll { $0 == car }
        } else {
            favoriteCars.append(car)
        }

        // Update TipKit with new favorites
        ExampleRuleTipTwo.favoriteCars.setCars(favoriteCars)
    }
}

#Preview {
    RuleTipTwoView()
}
