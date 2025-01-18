import SwiftUI

struct RayThemeView: View {
    private var lineColor = ["ray-yellow", "ray-peach", "ray-orange", "ray-mauve"]
    var body: some View {
        HStack {
            ZStack {
                ForEach(0 ..< lineColor.count, id: \.self) { index in
                    AngledLine()
                        .rotation(Angle(degrees: 15))
                        .foregroundColor(Color(lineColor[index]))
                        .frame(width: 15, height: 150)
                        .offset(x: CGFloat(8 * index - 31))
                }
            }
            Spacer()
            ZStack {
                ForEach(0 ..< lineColor.count, id: \.self) { index in
                    AngledLine()
                        .rotation(Angle(degrees: -15))
                        .foregroundColor(Color(lineColor[index]))
                        .frame(width: 15, height: 150)
                        .offset(x: CGFloat(8 * index) + 2)
                }
            }
        }
    }
}

struct AngledLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
}

struct RayThemeView_Previews: PreviewProvider {
    static var previews: some View {
        RayThemeView()
            .modifier(EntryBannerStyle(theme: .ray))
    }
}
