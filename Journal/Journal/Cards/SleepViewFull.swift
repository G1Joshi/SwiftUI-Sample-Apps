import SwiftUI

struct SleepViewFull: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        VStack(alignment: .leading) {
            Text(isEditing ? "How many hours did you sleep?" : "Hours Slept: \(Int(value))")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))

            if isEditing {
                HStack(spacing: 10) {
                    Text("\(Int(value))")
                        .foregroundColor(.darkBrown)

                    ZStack(alignment: .center) {
                        Slider(value: $value, in: 0 ... 12, step: 1)
                            .padding(.horizontal)
                            .accentColor(Color(UIColor.systemTeal))
                    }
                    Text("12")
                        .foregroundColor(.darkBrown)
                }
                .frame(maxHeight: .infinity)

            } else {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .foregroundColor(.darkBrown)
                        .font(.system(size: 30))
                    Grid(horizontalSpacing: 0) {
                        GridRow {
                            ForEach(0 ..< 12) { column in
                                Rectangle()
                                    .frame(height: 15)
                                    .foregroundColor(column < Int(value) ? .themeBlue : .darkBrown.opacity(0.5))
                            }
                        }
                    }
                    .cornerRadius(45.0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 100, maxHeight: 300)
        .padding()
    }
}

struct SleepViewFull_Previews: PreviewProvider {
    static var previews: some View {
        SleepViewFullPreview()
    }
}
