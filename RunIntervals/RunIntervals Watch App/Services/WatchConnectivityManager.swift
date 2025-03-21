import Foundation
import WatchConnectivity

final class WatchConnectivityManager: NSObject, WCSessionDelegate {

    init(workoutsHandler: (([IntervalWorkout]) -> Void)? = nil) {
        self.workoutsHandler = workoutsHandler
        super.init()
        setupSession()
    }

    var workoutsHandler: (([IntervalWorkout]) -> Void)?

    // MARK: - Receive Workouts from iPhone

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        if let data = message[WatchMessageConstants.workoutsKey] as? Data {
            do {
                let receivedWorkouts = try JSONDecoder().decode([IntervalWorkout].self, from: data)
                DispatchQueue.main.async {
                    self.workoutsHandler?(receivedWorkouts)
                }
                // Reply with success
                replyHandler([WatchMessageConstants.replyKey: true])
            } catch {
                // Reply with failure
                replyHandler([WatchMessageConstants.replyKey: false])
            }
        } else {
            // Reply with failure
            replyHandler([WatchMessageConstants.replyKey: false])
        }
    }

    // MARK: - Required WCSessionDelegate Methods

    func session(
        _ session: WCSession,
        activationDidCompleteWith state: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch session reachability changed: \(session.isReachable)")
    }

    private func setupSession() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}
