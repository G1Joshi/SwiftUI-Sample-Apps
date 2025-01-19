import PhotosUI
import SwiftUI

struct TrainingDatasetImageGrid: View {
    @Environment(\.displayScale) private var displayScale
    private let columns = [
        GridItem(.adaptive(minimum: Constants.photoSize.width, maximum: Constants.photoSize.height), spacing: Constants.photoSpacing),
    ]

    private var directory: URL? {
        dataset.directory?.appending(path: label, directoryHint: .isDirectory)
    }

    private var toolBarItemText: String {
        isInEditMode ? "Done" : "Edit"
    }

    @ObservedObject var trainerDataModel: TrainerDataModel
    @StateObject private var photoPickerDataModel = PhotoPickerDataModel()
    @State private var isInEditMode: Bool = false
    @State private var images: [URL] = []

    var dataset: Dataset

    var label: String

    var body: some View {
        ScrollView {
            VStack {
                LazyVGrid(columns: columns, spacing: Constants.photoSpacing) {
                    PhotosPicker(selection: $photoPickerDataModel.selection,
                                 matching: .images,
                                 photoLibrary: .shared())
                    {
                        addPhotoButton()
                    }
                    .disabled(isInEditMode)
                    .onChange(of: photoPickerDataModel.selection) { _ in
                        addNewPhotos()
                    }
                    ForEach(images, id: \.self) { url in
                        image(url)
                    }
                }
                Spacer()
            }
        }
        .navigationTitle(label)
        .toolbar {
            editModeButton()
        }
        .onAppear {
            updateImages()
        }
    }

    private func addPhotoButton() -> some View {
        Label("Add more photos", systemImage: "plus")
            .font(.title)
            .labelStyle(.iconOnly)
            .frame(width: Constants.photoSize.width, height: Constants.photoSize.height)
            .modifier(CellStyle(cornerRadius: Constants.photoCornerRadius, padding: 0.0, disabled: isInEditMode))
    }

    private func image(_ url: URL) -> some View {
        Button {
            if isInEditMode {
                deletePhoto(url)
            }
        } label: {
            DatasetImage(url: url)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            if isInEditMode {
                Image(systemName: "x.square.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
                    .offset(x: 7, y: -7)
            }
        }
    }

    private func editModeButton() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                isInEditMode.toggle()
            } label: {
                Text(toolBarItemText)
            }
        }
    }

    private func addNewPhotos() {
        Task {
            guard let directory = directory else { return }
            for photo in photoPickerDataModel.selection {
                await photoPickerDataModel.addImageFromPickerItem(photo, to: directory)
            }
            photoPickerDataModel.selection = []
            updateImages()
        }
    }

    private func deletePhoto(_ url: URL) {
        do {
            try FileManager.default.delete(url)
            updateImages()
        } catch {
            print("Couldn't delete photo: \(error.localizedDescription)")
        }
    }

    private func updateImages() {
        images = dataset.getImages(from: label)
    }
}
