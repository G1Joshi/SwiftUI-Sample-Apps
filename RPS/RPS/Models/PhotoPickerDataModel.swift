import PhotosUI
import SwiftUI

class PhotoPickerDataModel: ObservableObject {
    @Published var selection: [PhotosPickerItem] = []

    func addImageFromPickerItem(_ pickerItem: PhotosPickerItem, to directory: URL) async {
        do {
            guard let imageFile = try await pickerItem.loadTransferable(type: PhotoFile.self) else { return }
            let destURL = directory.appending(path: imageFile.name, directoryHint: .notDirectory)
            try FileManager.default.moveItem(at: imageFile.url, to: destURL)
        } catch {
            print("Error creating item from picked photo: \(error.localizedDescription)")
        }
    }
}

struct PhotoFile: Transferable {
    let name: String
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .image, shouldAttemptToOpenInPlace: false) { data in
            SentTransferredFile(data.url, allowAccessingOriginalFile: true)
        } importing: { received in
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = received.file.lastPathComponent
            let destinationURL = tempDirectory.appendingPathComponent(fileName)
            try FileManager.default.copyItem(at: received.file, to: destinationURL)
            return Self(name: fileName, url: destinationURL)
        }
    }
}
