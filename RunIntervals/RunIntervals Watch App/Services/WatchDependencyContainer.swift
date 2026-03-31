import Foundation
import os

protocol WatchDependencyContainer {
    var dataService: DataService { get }
    var watchConnectivityManager: WatchConnectivityManager { get }
    var logger: Logger { get }
    var healthKitService: HealthKitService { get }
    var healthKitWorkoutService: HealthKitWorkoutService { get }
    var audioManager: AudioManager { get }
}

final class DependencyContainer: WatchDependencyContainer {

    init() {}

    let audioManager: AudioManager = AudioManager()

    let logger: Logger = Logger(subsystem: Bundle.id, category: "Watch")
    let dataService: DataService = CacheableDataService(directoryName: "interval-workouts")

    private(set) lazy var healthKitService: HealthKitService = HealthKitService(logger: logger)

    private(set) lazy var watchConnectivityManager: WatchConnectivityManager = {
        WatchConnectivityManager(logger: logger)
    }()

    private(set) lazy var healthKitWorkoutService: HealthKitWorkoutService = {
        HealthKitWorkoutService(logger: logger)
    }()
}
