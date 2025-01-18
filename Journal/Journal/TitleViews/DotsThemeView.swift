import SwiftUI

struct DotThemeView: View {
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.dotGreen)
                        .offset(x: -5, y: -5)
                    Circle()
                        .frame(width: 15)
                        .foregroundColor(.dotBrown)
                        .offset(x: 5, y: 5)
                }
                ZStack {
                    Circle()
                        .frame(width: 25)
                        .foregroundColor(.dotGreen)
                        .offset(x: 5, y: 5)
                    Circle()
                        .frame(width: 20)
                        .foregroundColor(.dotYellow)
                        .offset(x: -5, y: -5)
                }
            }
            Spacer()
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 40)
                        .foregroundColor(.dotGreen)
                        .offset(x: 5, y: 12)
                    Circle()
                        .frame(width: 30)
                        .foregroundColor(.dotBrown)
                        .offset(x: 7, y: -3)
                    Circle()
                        .frame(width: 18)
                        .foregroundColor(.dotYellow)
                        .offset(x: 2, y: -20)
                }
            }
        }
    }
}

struct DotThemeView_Previews: PreviewProvider {
    static var previews: some View {
        DotThemeView()
            .modifier(EntryBannerStyle(theme: .dot))
    }
}
