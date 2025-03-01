import SwiftUI
import TipKit

struct EventBasedTipView: View {

    let tip = EventBasedTip()

    var body: some View {
        VStack {
            Text("Welcome to the Event Based Tip View!")
                .font(.title)
                .multilineTextAlignment(.center)

            Button(
                action: {
                    // Donate to the event each time the view appears.
                    EventBasedTip.buttonPressed.sendDonation()
                },
                label: {
                    Text("Press button to track tip event")
                }
            )
            .padding(.top, 16)

            // Display the tip if it meets the criteria (user has tapped button 3 times)
            TipView(tip)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    EventBasedTipView()
}
