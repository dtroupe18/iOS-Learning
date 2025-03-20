import WatchConnectivity
import Foundation

final class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {

    enum ConnectionState {
        case notConnected
        case connected
    }

    enum WatchConnectivityError: Error {
        case notSupported
        case notConnected
        case encodingFailed
        case sendFailed(String)
    }

    // MARK: - Properties

    @Published private(set) var connectionState: ConnectionState = .notConnected
    @Published private(set) var workouts: [IntervalWorkout] = []

    // MARK: - Initializer

    init(dataService: DataService) {
        self.session = WCSession.default
        self.dataService = dataService
        super.init()
        setupSession()
    }

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
                    if let reply = response[WatchMessageConstants.replyKey] as? Bool, reply == true {
                        // Success
                        continuation.resume()
                    } else {
                        // Failure
                        continuation.resume(throwing: WatchConnectivityError.sendFailed("Watch failed to process workouts"))
                    }
                }, errorHandler: { error in
                    continuation.resume(throwing: WatchConnectivityError.sendFailed(error.localizedDescription))
                })
            }
        } catch {
            throw WatchConnectivityError.encodingFailed
        }
    }

    // MARK: - Receive Workouts from iPhone

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let data = message["workouts"] as? Data {
            do {
                let receivedWorkouts = try JSONDecoder().decode([IntervalWorkout].self, from: data)
                DispatchQueue.main.async {
                    self.workouts = receivedWorkouts
                    self.save(receivedWorkouts)
                }
            } catch {
                print("Failed to decode workouts: \(error.localizedDescription)")
            }
        }
    }

    // MARK: Private

    private let session: WCSession
    private let dataService: DataService

    private func save(_ workouts: [IntervalWorkout]) {
        dataService.add(workouts)
    }

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

extension WatchConnectivityManager {
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
