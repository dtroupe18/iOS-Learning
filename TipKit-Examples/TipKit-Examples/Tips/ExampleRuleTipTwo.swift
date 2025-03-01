import TipKit

struct ExampleRuleTipTwo: Tip {

    // Define a custom value type to store a list of plant names.
    struct FavoriteCars: Codable, Sendable {
        var cars: Set<String> = []

        var arrayValue: [String] {
            Array(cars)
        }

        mutating func setCars(_ newValue: [String]) {
            cars = Set(newValue)
        }
    }

    // The Tips.Parameter property wrapper also support types that conforms to the Codable
    // and Sendable protocol. In this example, the tip displays if the tip has more than two
    // favorites, and one of the favorites is a string with the value “Viper”.
    @Parameter(.transient)
    static var favoriteCars: FavoriteCars = FavoriteCars(cars: ["Corvette", "IS500"])

    var title: Text {
        Text("Explore Favorite Cars")
    }

    var message: Text? {
        Text("Discover your favorite Cars.")
    }

    var image: Image? {
        Image(systemName: "car.side")
    }

    // Tip will only display when there are 3 or more favorite cars and Viper has been favorited.
    var rules: [Rule] {
        // Display if more than two favorite cars are added.
        #Rule(ExampleRuleTipTwo.$favoriteCars) {
            $0.cars.count >= 3
        }


        // Display if "Viper" is added as a favorite.
        #Rule(ExampleRuleTipTwo.$favoriteCars) {
            $0.cars.contains("Viper")
        }
    }
}

