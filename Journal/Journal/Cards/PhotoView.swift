
import PhotosUI
import SwiftUI

struct PhotoView: View {
    @Binding var value: ImageModel
    @State private var imageState: ImageState = .empty
    @State private var imageSelection: PhotosPickerItem?
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: 10)
                    .frame(minHeight: 100, maxHeight: 200)
                    .foregroundColor(.clear)

                Image(systemName: "photo.fill")
                    .foregroundColor(.darkBrown)
                    .font(.system(size: 30))
            }
            .opacity(isEditing ? 0 : 1)
            VStack {
                PhotosPicker(selection: $imageSelection, matching: .images, photoLibrary: .shared()) {
                    if isEditing {
                        getImg(imageState: imageState)
                            .scaledToFill()
                            .frame(minWidth: 20, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                    }
                }
                .onChange(of: imageSelection) { newItem in
                    updateImageState(newItem: newItem)
                }
                .task {
                    initializeImageState()
                }
            }

            if !isEditing, let url = value.url {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 20, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                } placeholder: {
                    Text("Loading Image...")
                        .modifier(FontStyle(size: 12))
                }
            }
            Image(systemName: "photo.fill")
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding()
                .opacity(isEditing ? 1 : 0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func getImg(imageState: ImageState) -> some View {
        switch imageState {
        case let .success(url):
            AsyncImage(url: url) { image in
                image
                    .resizable()
            } placeholder: {
                Text("Loading Image...")
                    .modifier(FontStyle(size: 12))
            }
        case .loading:
            Text("Loading Image...")
                .modifier(FontStyle(size: 12))
        case .empty:
            Image(systemName: "plus")
                .font(.system(size: 30))
        case .failure:
            Image("errorloadingimage")
                .resizable()
                .scaledToFit()
                .frame(height: 35)
        }
    }

    private func initializeImageState() {
        if let url = value.url {
            imageState = .success(url)
        }
    }

    private func updateImageState(newItem: PhotosPickerItem?) {
        Task {
            do {
                imageState = .loading
                guard let photoFile = try await newItem?.loadTransferable(type: PhotoFile.self),
                      let url = try FileManager.default.copyItemToDocumentDirectory(from: photoFile.url)
                else {
                    imageState = .empty
                    return
                }
                print("image saved to: \(url)")
                value.fileName = url.lastPathComponent
                print("image file name: \(url.lastPathComponent)")
                imageState = .success(url)

            } catch {
                print("Image download failed with error \(error.localizedDescription)")
                imageState = .failure(error)
            }
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoView(value: .constant(ImageModel()), isEditing: true, fontStyle: .font1)
            .background(CardBackground())
    }
}
