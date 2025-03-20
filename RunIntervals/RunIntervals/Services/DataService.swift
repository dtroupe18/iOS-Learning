import Foundation

protocol Cacheable: Codable, Identifiable {
    static var fileName: String { get }
}

protocol DataService {
    func load<T: Cacheable>() -> [T]
    func add<T: Cacheable>(_ item: T)
    func add<T: Cacheable>(_ items: [T])
    func update<T: Cacheable>(_ item: T)
    func delete<T: Cacheable>(_ item: T)
    func deleteAll<T: Cacheable>(_ type: T.Type)
}

/// A service for managing CRUD operations on `Cacheable` objects using the file system.
final class CacheableDataService: DataService {

    /// Initializes the data service with a directory name.
    /// - Parameter directoryName: The name of the directory inside the app's documents folder.
    init(directoryName: String) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.directory = documentsDirectory.appendingPathComponent(directoryName)

        // Create the directory if it doesn't exist
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    /// Loads an array of `Cacheable` objects.
    /// - Returns: An array of decoded objects, or an empty array if loading fails.
    func load<T: Cacheable>() -> [T] {
        let fileURL = fileURL(for: T.self)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([T].self, from: data)
        } catch {
            print("Failed to load data from \(T.fileName): \(error)")
            return []
        }
    }

    func add<T: Cacheable>(_ items: [T]) {
        var loadedItems: [T] = load()
        loadedItems.append(contentsOf: items)
        save(loadedItems)
    }

    /// Adds a new `Cacheable` object.
    /// - Parameter item: The item to add.
    func add<T: Cacheable>(_ item: T) {
        var items: [T] = load()
        items.append(item)
        save(items)
    }

    /// Updates an existing object.
    /// - Parameter item: The updated object.
    func update<T: Cacheable>(_ item: T) {
        var items: [T] = load()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            save(items)
        }
    }

    /// Deletes an object from storage based on its ID.
    /// - Parameter item: The object to delete.
    func delete<T: Cacheable>(_ item: T) {
        var items: [T] = load()
        items.removeAll { $0.id == item.id }
        save(items)
    }

    /// Deletes all objects of a given type.
    /// - Parameter type: The type of objects to delete (used to infer `T`).
    func deleteAll<T: Cacheable>(_ type: T.Type) {
        let fileURL = fileURL(for: T.self)
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Failed to delete \(T.fileName): \(error)")
        }
    }

    /// The directory where data will be stored.
    private let directory: URL

    /// Returns the full file URL for a given model type.
    private func fileURL<T: Cacheable>(for type: T.Type) -> URL {
        return directory.appendingPathComponent(T.fileName)
    }

    /// Saves an array of `Cacheable` objects.
    /// - Parameter items: The array of objects to save.
    private func save<T: Cacheable>(_ items: [T]) {
        let fileURL = fileURL(for: T.self)
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save data to \(T.fileName): \(error)")
        }
    }
}
