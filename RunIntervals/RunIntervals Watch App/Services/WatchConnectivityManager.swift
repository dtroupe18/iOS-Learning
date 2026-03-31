import Foundation
import os
import WatchConnectivity

protocol WatchMessagingService {
    var connectionState: WatchConnectionState { get }
    var workoutsHandler: (([IntervalWorkout]) -> Void)? { get set }
}

final class WatchConnectivityManager: NSObject, WatchMessagingService, WCSessionDelegate {

    init(logger: Logger, workoutsHandler: (([IntervalWorkout]) -> Void)? = nil) {
        self.workoutsHandler = workoutsHandler
        self.logger = logger
        self.session = WCSession.default
        super.init()
        setupSession()
    }

    let logger: Logger
    var workoutsHandler: (([IntervalWorkout]) -> Void)?
    private(set) var connectionState: WatchConnectionState = .notConnected

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
    ) {
        logger.error(
            """
            WatchConnectivityManager activationDidCompleteWith: \(String(describing: state), privacy: .public), 
            error: \(String(describing: error), privacy: .public)
            """
        )
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        logger.debug("WatchConnectivityManager session reachability changed: \(session.isReachable)")
    }

    private let session: WCSession

    private func setupSession() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }
}
