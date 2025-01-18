import SwiftUI

struct SketchView: View {
    @Binding var value: [Line]
    var isEditing: Bool
    var fontStyle: JournalFont

    var size: CardSize
    @State private var penColor = Color.darkBrown

    private var penColors: [Color] {
        if size == .small {
            return [Color.darkBrown]
        } else {
            return
                [.themePink,
                 .themeRed,
                 .themeOrange,
                 .themeGreen,
                 .themeBlue,
                 .themeTeal,
                 .darkBrown]
        }
    }

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0) {
                if isEditing {
                    Text("Draw a sketch")
                        .foregroundColor(.darkBrown)
                        .font(fontStyle.uiFont(15))
                }

                Canvas { context, _ in
                    for line in value {
                        var path = Path()
                        path.addLines(line.points)
                        context.stroke(path, with: .color(line.color), lineWidth: line.lineWidth)
                    }
                }
                .frame(minHeight: size == .small ? 100 : 250, maxHeight: 250)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onChanged { line in
                    let newPoint = line.location
                    if line.translation.width + line.translation.height == 0 {
                        value.append(Line(points: [newPoint], color: penColor, lineWidth: 5))
                    } else {
                        let index = value.count - 1
                        value[index].points.append(newPoint)
                    }
                })
                .disabled(!isEditing)

                if isEditing {
                    HStack {
                        ForEach(penColors, id: \.self) { color in
                            Button {
                                penColor = color
                            } label: {
                                Image(systemName: penColor == color ? "circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(color)
                            }
                        }
                        Spacer()
                        Button {
                            value.removeLast()
                            while let lastLine = value.last {
                                if lastLine.points.count <= 1 {
                                    value.removeLast()
                                } else {
                                    break
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(.darkBrown)
                                .font(.system(size: 20, weight: .bold))
                                .opacity(value.isEmpty ? 0.3 : 1)
                        }
                        .disabled(value.isEmpty)
                    }
                }
            }
            .padding()
        }
    }
}

struct SketchView_Previews: PreviewProvider {
    static var previews: some View {
        SketchView(value: .constant([Line(points: [CGPoint(), CGPoint()], color: Color.black, lineWidth: 5)]), isEditing: true, fontStyle: .font1, size: .large)
            .background(CardBackground())
    }
}
