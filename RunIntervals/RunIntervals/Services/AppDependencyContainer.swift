import Foundation

protocol DependencyContainer {
    var dataService: DataService { get }
    var watchConnectivityManager: WatchConnectivityManager { get }
}

final class AppDependencyContainer: DependencyContainer {

    init() {}

    let dataService: DataService = CacheableDataService(directoryName: "interval-workouts")
    lazy var watchConnectivityManager: WatchConnectivityManager = {
        WatchConnectivityManager(dataService: dataService)
    }()
}

#if DEBUG
class PreviewDependencyContainer: DependencyContainer {
    init() {}

    let dataService: DataService = CacheableDataService(directoryName: "preview")

    lazy var watchConnectivityManager: WatchConnectivityManager = {
        WatchConnectivityManager(dataService: dataService)
    }()
}
#endif
