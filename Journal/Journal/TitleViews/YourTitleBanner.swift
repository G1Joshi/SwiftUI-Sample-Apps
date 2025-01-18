import SwiftUI

struct YourTitleBannerView: View {
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.bannerBlue)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.bannerYellow)
                        .offset(x: -10, y: -5)
                }
                ZStack {
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.bannerPink)
                        .offset(x: -5)
                }
            }
            Spacer()
            ZStack {
                Circle()
                    .frame(width: 40)
                    .foregroundColor(.bannerBlue)
                    .offset(x: 5, y: -10)
                Circle()
                    .frame(width: 30)
                    .foregroundColor(.bannerPink)
                    .offset(x: 6, y: 5)
            }
        }
    }
}

struct YourTitleBannerView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBannerPreview()
    }
}
