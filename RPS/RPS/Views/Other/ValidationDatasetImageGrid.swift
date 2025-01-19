import PhotosUI
import SwiftUI

struct ValidationDatasetImageGrid: View {
    @Environment(\.displayScale) private var displayScale
    private let columns = [
        GridItem(.adaptive(minimum: Constants.photoSize.width, maximum: Constants.photoSize.height), spacing: Constants.photoSpacing),
    ]

    var dataset: Dataset
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(dataset.moves, id: \.self) { move in
                    Text(move)
                        .font(.subheadline)
                        .padding(.leading)
                    LazyVGrid(columns: columns, spacing: Constants.photoSpacing) {
                        let images = dataset.getImages(from: move)
                        ForEach(images, id: \.self) { url in
                            DatasetImage(url: url)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
        }
        .navigationTitle(dataset.name)
        .tint(.accent)
    }
}
