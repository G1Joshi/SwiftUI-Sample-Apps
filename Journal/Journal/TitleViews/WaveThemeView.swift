import SwiftUI

struct WaveThemeView: View {
    var body: some View {
        HStack {
            Image("wave-orange")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: -10)
            Image("wave-peach")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: -28)
            Spacer()
            Image("wave-copper")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: 28)
            Image("wave-brown")
                .resizable()
                .scaledToFill()
                .frame(width: 20)
                .offset(x: 10)
        }
    }
}

struct WaveThemeView_Previews: PreviewProvider {
    static var previews: some View {
        WaveThemeView()
            .modifier(EntryBannerStyle(theme: .wave))
    }
}
