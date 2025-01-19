import SwiftUI

struct DatasetImage: View {
    var url: URL
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: Constants.photoSize.width, height: Constants.photoSize.height)
                .clipped()

        } placeholder: {
            ProgressView()
                .scaleEffect(0.5)
        }
        .cornerRadius(Constants.photoCornerRadius)
    }
}
