import WatchConnectivity
import Foundation

final class AppWatchConnectivityManager: NSObject, WCSessionDelegate {

    // MARK: - Initializer

    override init() {
        self.session = WCSession.default
        super.init()
        setupSession()
    }

    // MARK: - Properties

    private(set) var connectionState: WatchConnectionState = .notConnected
    private(set) var workouts: [IntervalWorkout] = []

    // MARK: - Sync Workouts to Watch

    func sendWorkoutsToWatch(workouts: [IntervalWorkout]) async throws {
        guard WCSession.isSupported() else {
            throw WatchConnectivityError.notSupported
        }

        // Wait for connection if necessary
        while connectionState == .notConnected {
            try await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5 seconds
        }

        guard session.isReachable else {
            throw WatchConnectivityError.notConnected
        }

        do {
            let data = try JSONEncoder().encode(workouts)
            let payload: [String: Any] = [WatchMessageConstants.workoutsKey: data]

            return try await withCheckedThrowingContinuation { continuation in
                session.sendMessage(payload, replyHandler: { response in
                    // Handle the reply from the watch
                    if let reply = response[WatchMessageConstants.replyKey] as? Bool,
                        reply == true {
                        // Success
                        continuation.resume()
                    } else {
                        // Failure
                        let error = WatchConnectivityError
                            .sendFailed("Watch failed to process workouts")
                        continuation.resume(throwing: error)
                    }
                }, errorHandler: { error in
                    let err = WatchConnectivityError.sendFailed(error.localizedDescription)
                    continuation.resume(throwing: err)
                })
            }
        } catch {
            throw WatchConnectivityError.encodingFailed
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        // TODO: Handle any messages from watch.
    }

    // MARK: Private

    private let session: WCSession

    private func setupSession() {
        guard WCSession.isSupported() else {
            connectionState = .notConnected
            return
        }
        session.delegate = self
        session.activate()
    }
}

// MARK: - WCSessionDelegate Methods

extension AppWatchConnectivityManager {
    func session(
        _ session: WCSession,
        activationDidCompleteWith state: WCSessionActivationState,
        error: Error?
    ) {
        if state == .activated {
            connectionState = session.isReachable ? .connected : .notConnected
        } else {
            connectionState = .notConnected
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        connectionState = session.isReachable ? .connected : .notConnected
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        connectionState = session.isReachable ? .connected : .notConnected
    }

    func sessionDidDeactivate(_ session: WCSession) {
        connectionState = session.isReachable ? .connected : .notConnected
        session.activate()
    }
}
