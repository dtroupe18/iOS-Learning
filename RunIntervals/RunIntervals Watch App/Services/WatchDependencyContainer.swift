import Foundation
import os

protocol WatchDependencyContainer {
    var dataService: DataService { get }
    var watchConnectivityManager: WatchConnectivityManager { get }
    var logger: Logger { get }
    var healthKitService: HealthKitService { get }
    var healthKitWorkoutService: HealthKitWorkoutService { get }
}

final class DependencyContainer: WatchDependencyContainer {

    init() {}

    let healthKitService: HealthKitService = HealthKitService()
    let healthKitWorkoutService: HealthKitWorkoutService = HealthKitWorkoutService()
    let logger: Logger = Logger(subsystem: Bundle.id, category: "Watch")
    let dataService: DataService = CacheableDataService(directoryName: "interval-workouts")
    let watchConnectivityManager: WatchConnectivityManager = WatchConnectivityManager()
}
