import SwiftUI

struct SleepView: View {
    @Binding var value: Double
    var isEditing: Bool
    var fontStyle: JournalFont
    var size: CardSize

    static var disableSleepViewHalf = false

    var body: some View {
        if size == .small {
            SleepViewHalf(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        } else {
            SleepViewFull(value: $value, isEditing: isEditing, fontStyle: fontStyle)
        }
    }
}
