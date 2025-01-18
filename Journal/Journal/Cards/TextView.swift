import SwiftUI

struct TextView: View {
    @Binding var value: TextData
    var isEditing: Bool
    var fontStyle: JournalFont = .font1

    var placeHolderText = "Write Something"
    var containsPlaceHolderText: Bool {
        value.text == placeHolderText
    }

    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextEditor(text: $value.text)
                    .font(fontStyle.uiFont(value.fontSize.rawValue))
                    .foregroundColor(
                        Color("dark-brown")
                            .opacity(containsPlaceHolderText ? 0.7 : 1)
                    )
                    .onTapGesture {
                        if containsPlaceHolderText {
                            value.text = ""
                        }
                    }
                    .padding(.top)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 50, maxHeight: .infinity)
                HStack {
                    ForEach(FontSize.allCases, id: \.self) { fs in
                        Button {
                            value.fontSize = fs
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .foregroundColor(value.fontSize == fs ? .darkBrown : .clear)
                                    .frame(width: 20, height: 24)
                                Text("A")
                                    .foregroundColor(value.fontSize == fs ? .paleOrange : .darkBrown)
                                    .font(.system(size: fs.rawValue, weight: .medium, design: .rounded))
                                    .frame(width: 20, height: 24, alignment: .center)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

            } else {
                Text(value.text)
                    .font(fontStyle.uiFont(value.fontSize.rawValue))
                    .foregroundColor(
                        Color("dark-brown")
                            .opacity(containsPlaceHolderText ? 0 : 1)
                    )
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView(value: .constant(TextData()), isEditing: true)
            .background(CardBackground())
    }
}
