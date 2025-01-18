import SwiftUI

struct MoodViewHalf: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    private let emojis = ["😢", "😴", "😁", "😡", "😐"]
    @State private var emojiIndex = 2

    var body: some View {
        VStack(alignment: .leading) {
            Text("Mood")
                .foregroundColor(.darkBrown)
                .font(fontStyle.uiFont(15))
                .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                if isEditing {
                    Button {
                        emojiIndex -= 1
                        value = emojis[emojiIndex]
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.darkBrown)
                            .font(.system(size: 17))
                    }
                    .disabled(emojiIndex - 1 < 0)
                    .opacity(emojiIndex - 1 < 0 ? 0.5 : 1)
                }

                Text(value)
                    .font(.system(size: isEditing ? 40 : 60))

                if isEditing {
                    Button {
                        emojiIndex += 1
                        value = emojis[emojiIndex]
                    } label: {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.darkBrown)
                            .font(.system(size: 17))
                    }
                    .disabled(emojiIndex + 1 > 4)
                    .opacity(emojiIndex + 1 > 4 ? 0.5 : 1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 100, maxHeight: 200)
        .padding()
    }
}

struct MoodViewHalf_Previews: PreviewProvider {
    static var previews: some View {
        MoodViewHalfPreview()
    }
}
