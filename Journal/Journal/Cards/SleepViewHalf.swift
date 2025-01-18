import SwiftUI

struct SleepViewHalf: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont

    var body: some View {
        VStack {
            Text("Hours Slept")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))

            Text("\(Int(value))")
                .foregroundColor(.darkBrown)
                .modifier(FontStyle(size: 50))
        }
    }
}

struct SleepViewHalf_Previews: PreviewProvider {
    static var previews: some View {
        SleepViewHalfPreview()
    }
}
