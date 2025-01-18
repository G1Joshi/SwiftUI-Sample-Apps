import SwiftUI

struct MoodView: View {
    @Binding var value: String
    var isEditing: Bool
    var fontStyle: JournalFont
    var size: CardSize

    static var disableMoodViewFull = false

    var body: some View {
        if size == .small {
            MoodViewHalf(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        } else {
            MoodViewFull(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        }
    }
}
