import SwiftUI

enum ColorOptions {
    static var all: [Color] = [
        .primary,
        .gray,
        .red,
        .orange,
        .yellow,
        .green,
        .mint,
        .cyan,
        .indigo,
        .purple,
    ]

    static var `default`: Color = .primary

    static func random() -> Color {
        if let element = ColorOptions.all.randomElement() {
            return element
        } else {
            return .primary
        }
    }
}
