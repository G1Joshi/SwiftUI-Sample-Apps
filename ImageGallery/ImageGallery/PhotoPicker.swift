import PhotosUI
import SwiftUI

struct PhotoPicker: UIViewControllerRepresentable {
    @EnvironmentObject var dataModel: DataModel

    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotoPicker>) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current

        let photoPickerViewController = PHPickerViewController(configuration: configuration)
        photoPickerViewController.delegate = context.coordinator
        return photoPickerViewController
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIViewController(_: PHPickerViewController, context _: UIViewControllerRepresentableContext<PhotoPicker>) {}
}

class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    let parent: PhotoPicker

    func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        parent.dismiss()

        guard
            let result = results.first,
            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier)
        else { return }

        result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
            if let error = error {
                print("Error loading file representation: \(error.localizedDescription)")
            } else if let url = url {
                if let savedUrl = FileManager.default.copyItemToDocumentDirectory(from: url) {
                    Task { @MainActor [dataModel = self.parent.dataModel] in
                        withAnimation {
                            let item = Item(url: savedUrl)
                            dataModel.addItem(item)
                        }
                    }
                }
            }
        }
    }

    init(_ parent: PhotoPicker) {
        self.parent = parent
    }
}
