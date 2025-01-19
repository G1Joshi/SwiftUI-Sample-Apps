import SwiftUI

final class Dataset: ObservableObject, Identifiable {
    @Published var name: String
    @Published var isNew: Bool
    let type: DatasetType
    let moves: [String]

    var resourceDirectory: URL?

    var directory: URL? {
        return baseDirectory?.appendingPathComponent(name, isDirectory: true)
    }

    var hasEnoughImages: Bool {
        guard !subDirectories.isEmpty else { return false }
        let subDirectoryImageCounts = subDirectories.map { getImageCount(for: $0) }
        return !subDirectoryImageCounts.contains { $0 < 7 }
    }

    private var baseDirectory: URL? {
        switch type {
        case .training:
            return URL.trainingDirectoryinDoc
        case .validation:
            return URL.validationDirectoryinDoc
        }
    }

    private var subDirectories: [URL] {
        guard let directory = directory else { return [] }
        var subDirs: [URL] = []
        for move in moves {
            subDirs.append(directory.appendingPathComponent(move.capitalized, isDirectory: true))
        }
        return subDirs
    }

    init(name: String? = nil, type: DatasetType, moves: [String], resourceDirectory: URL? = nil, isNew: Bool = false) {
        self.name = name ?? "New Dataset"
        self.type = type
        self.moves = moves
        self.isNew = isNew

        if let dir = resourceDirectory {
            copyToDocumentDirectory(dir)
        } else {
            createDirectories()
        }
    }

    func getTotalImageCount() -> Int {
        return directory?.getTotalFilesInDataset() ?? 0
    }

    func getImageCount(for subDirectory: URL) -> Int {
        return subDirectory.directoryContents.count
    }

    func getImages(from subDirectory: URL) -> [URL] {
        let directory = subDirectories.first(where: { $0.lastPathComponent == subDirectory.lastPathComponent })
        return directory?.directoryContents ?? []
    }

    func getImages(from subDirectoryName: String) -> [URL] {
        let directory = subDirectories.first(where: { $0.lastPathComponent == subDirectoryName })
        return directory?.directoryContents ?? []
    }

    private func createDirectories() {
        guard let baseDirectory = baseDirectory, let directory = directory else { return }
        do {
            try FileManager.default.createDirectory(at: baseDirectory)
            try FileManager.default.createDirectory(at: directory)
            for subDirectory in subDirectories {
                try FileManager.default.createDirectory(at: subDirectory)
            }
        } catch {
            print("Error creating directories: \(error.localizedDescription)")
        }
    }

    private func copyToDocumentDirectory(_ resourcesFolder: URL) {
        let subDirectories = resourcesFolder.subDirectories
        for subDirectory in subDirectories {
            let subDir = subDirectory.lastPathComponent.capitalized
            let contents = subDirectory.directoryContents
            for content in contents {
                let fileName = content.lastPathComponent
                guard let newSubDirectory = directory?.appending(path: subDir, directoryHint: .isDirectory) else { return }
                do {
                    try FileManager.default.createDirectory(at: newSubDirectory)
                    let url = newSubDirectory.appending(path: fileName)
                    guard !url.fileExists else { continue }
                    Task {
                        do {
                            try FileManager.default.copyItem(at: content, to: url)
                        } catch {
                            print("Error copying url \(error)")
                        }
                    }
                } catch {
                    print("Error creating directory \(error)")
                }
            }
        }
    }

    func moveDirectoryTo(_ newName: String) {
        guard let originalDirectory = directory else { return }
        guard let newDirectory = baseDirectory?.appendingPathComponent(newName, isDirectory: true) else { return }
        do {
            try FileManager.default.moveItem(at: originalDirectory, to: newDirectory)
            name = newName
        } catch {
            print("Could not move directory: \(error.localizedDescription)")
        }
    }

    func delete() {
        guard let directory = directory else { return }
        do {
            try FileManager.default.deleteDirectory(directory)
        } catch {
            print("Could not delete \(name)'s directory: \(error.localizedDescription)")
        }
    }
}

enum DatasetType: String {
    case training
    case validation
}
