import AVFoundation
import Foundation

final class AudioManager: NSObject, AVAudioPlayerDelegate {

    // TODO: If the phone is connected we need to play the sound there not on the watch.

    func prepare() {
        audioPlayer = try? AVAudioPlayer(contentsOf: self.soundURL)
        audioPlayer?.delegate = self
    }

    func playBellSound() {
        do {
            // Set up audio session with ducking enabled
            try AVAudioSession.sharedInstance()
                .setCategory(.soloAmbient, options: [])

            try AVAudioSession.sharedInstance()
                .setActive(true)

            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    // Restore normal audio levels when sound finishes
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private var audioPlayer: AVAudioPlayer?
    private let soundURL = Bundle.main.url(forResource: "boxing-bell", withExtension: "mp3")!
}
