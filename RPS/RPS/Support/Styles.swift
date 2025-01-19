import SwiftUI

struct CellStyle: ViewModifier {
    var cornerRadius: CGFloat = 15.0
    var padding: CGFloat = 15.0
    var disabled: Bool = false

    func body(content: Content) -> some View {
        content
            .foregroundColor(disabled ? Color.gray : .black)
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(disabled ? Color.gray : Color.accent)
                    .brightness(disabled ? 0.3 : 0.5)
            }
    }
}

struct ChartViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 250, height: 250)
            .padding()
            .cornerRadius(10)
            .padding()
    }
}

struct GameLabelBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .environment(\.colorScheme, .light)
    }
}

struct CapsuleButton: ButtonStyle {
    var backgroundColor: Color = .white
    var foregroundColor: Color = .accentColor
    var disabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .foregroundColor(foregroundColor.opacity(disabled ? 0.7 : 1.0))
            .background(backgroundColor.opacity(disabled ? 0.5 : 1.0))
            .clipShape(Capsule())
    }
}

enum Constants {
    static let photoSpacing = 12.0
    static let photoCornerRadius = 10.0
    static let photoSize = CGSize(width: 104, height: 104)
}
