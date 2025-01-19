import Foundation

extension URL {
    static var documentDirectory: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

    static var modelDirectory: URL? {
        return documentDirectory?.appendingPathComponent("Models", isDirectory: true)
    }

    static var trainingDirectoryinDoc: URL? {
        return documentDirectory?.appendingPathComponent("Training", isDirectory: true)
    }

    static var validationDirectoryinDoc: URL? {
        return documentDirectory?.appendingPathComponent("Validation", isDirectory: true)
    }

    static var datasetDirectory: URL? {
        return resourceDirectory?.appendingPathComponent("Dataset", isDirectory: true)
    }

    static var trainingDirectoryInResources: URL? {
        return datasetDirectory?.appendingPathComponent("Training", isDirectory: true)
    }

    static var validationDirectoryInResources: URL? {
        return datasetDirectory?.appendingPathComponent("Validation", isDirectory: true)
    }

    static var resourceDirectory: URL? = Bundle.main.resourceURL

    static var defaultMLModel: URL? {
        return resourceDirectory?.appendingPathComponent("rockpaperscissors.mlmodel")
    }

    var subDirectories: [URL] {
        guard directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [],
                                                                   options: [.skipsHiddenFiles]).filter(\.hasDirectoryPath)
            return urls.sorted { $0.path < $1.path }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }

    var directoryContents: [URL] {
        guard directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [],
                                                                   options: [.skipsHiddenFiles,
                                                                             .skipsPackageDescendants,
                                                                             .skipsSubdirectoryDescendants])
            return urls.sorted { $0.path < $1.path }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }

    var directoryContentsOrderedByDate: [URL] {
        guard directoryExists else { return [] }
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: self,
                                                                   includingPropertiesForKeys: [.creationDateKey],
                                                                   options: [.skipsHiddenFiles,
                                                                             .skipsPackageDescendants,
                                                                             .skipsSubdirectoryDescendants])
            do {
                return try urls.sorted {
                    try $0.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast > $1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                }
            } catch {
                return urls
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        return []
    }

    var directoryExists: Bool {
        var isDir: ObjCBool = true
        let path = self.path
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }

    var fileExists: Bool {
        var isDir: ObjCBool = false
        let path = self.path
        return FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
    }

    func getTotalFilesInDataset() -> Int {
        let count = subDirectories.map { $0.directoryContents.count }.reduce(0, +)
        return count
    }
}

extension FileManager {
    func createDirectory(at url: URL) throws {
        guard !url.directoryExists else {
            return
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    func delete(_ url: URL) throws {
        if url.fileExists {
            try FileManager.default.removeItem(at: url)
        }
    }

    func deleteDirectory(_ url: URL) throws {
        if url.directoryExists {
            try FileManager.default.removeItem(at: url)
        }
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * 1_000_000_000)
        do {
            try await Task.sleep(nanoseconds: duration)
        } catch {}
    }
}
