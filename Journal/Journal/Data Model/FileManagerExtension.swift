import Foundation

extension FileManager {
    var documentDirectory: URL {
        do {
            return try url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        } catch {
            fatalError("Unable to get the local documents url. Error: \(error)")
        }
    }

    func copyItemToDocumentDirectory(from sourceURL: URL) throws -> URL? {
        let fileName = sourceURL.lastPathComponent
        let destinationURL = documentDirectory.appendingPathComponent(fileName)
        if fileExists(atPath: destinationURL.path) {
            return destinationURL
        } else {
            try copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        }
    }

    func removeItemFromDocumentDirectory(url: URL) {
        let fileName = url.lastPathComponent
        let fileUrl = documentDirectory.appendingPathComponent(fileName)
        if fileExists(atPath: fileUrl.path) {
            do {
                try removeItem(at: url)
            } catch {
                print("Unable to remove file: \(error.localizedDescription)")
            }
        }
    }
}
