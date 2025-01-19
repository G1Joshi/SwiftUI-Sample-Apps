import SwiftUI

struct TapView: View {
    @State private var color: Color = .primary

    var tapGesture: some Gesture {
        TapGesture()
            .onEnded {
                withAnimation {
                    color = Color.random()
                }
            }
    }

    var body: some View {
        VStack {
            Text("Tap the rectangle to change its color")
            Spacer()
            Rectangle()
                .foregroundColor(color)
                .frame(width: 250, height: 450)
                .gesture(tapGesture)
            Spacer()
        }
        .navigationTitle("Tap")
        .padding()
        .toolbar {
            Button("Reset") {
                color = Color.primary
            }
        }
    }
}

struct TapView_Previews: PreviewProvider {
    static var previews: some View {
        TapView()
    }
}

extension Color {
    static func random() -> Color {
        return Color(red: Double.random(in: 0 ... 1), green: Double.random(in: 0 ... 1), blue: Double.random(in: 0 ... 1))
    }
}
