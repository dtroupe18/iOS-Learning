import Foundation
import os

protocol DependencyContainer {
    var dataService: DataService { get }
    var watchConnectivityManager: AppWatchConnectivityManager { get }
    var logger: Logger { get }
    var healthKitService: HealthKitService { get }
}

final class AppDependencyContainer: DependencyContainer {

    init() {}

    let logger: Logger = Logger(subsystem: Bundle.id, category: "Phone")
    let dataService: DataService = CacheableDataService(directoryName: "interval-workouts")
    let watchConnectivityManager: AppWatchConnectivityManager = AppWatchConnectivityManager()
    private(set) lazy var healthKitService: HealthKitService = HealthKitService(logger: logger)
}

#if DEBUG
class PreviewDependencyContainer: DependencyContainer {
    init() {}

    let logger: Logger = Logger(subsystem: "\(Bundle.id)-debug", category: "Phone")
    let dataService: DataService = CacheableDataService(directoryName: "preview")
    let watchConnectivityManager: AppWatchConnectivityManager = AppWatchConnectivityManager()
    private(set) lazy var healthKitService: HealthKitService = HealthKitService(logger: logger)
}
#endif
