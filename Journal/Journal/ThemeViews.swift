import SwiftUI

struct EntryBannerTheme: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            YourTitleBannerView()
        case .curve:
            CurveThemeView()
        case .dot:
            DotThemeView()
        case .ray:
            RayThemeView()
        case .wave:
            WaveThemeView()
        }
    }
}

struct BackgroundIcon: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            Image("LineIcon")
                .resizable()
        case .curve:
            Image("CurveIcon")
                .resizable()
        case .dot:
            Image("DotIcon")
                .resizable()
        case .ray:
            Image("RayIcon")
                .resizable()
        case .wave:
            Image("WaveIcon")
                .resizable()
        }
    }
}

struct EntryBackground: View {
    var forTheme: JournalTheme
    var body: some View {
        switch forTheme {
        case .line:
            Image("LineBackground")
                .resizable()
        case .curve:
            Image("CurveBackground")
                .resizable()
        case .dot:
            Image("DotBackground")
                .resizable()
        case .ray:
            Image("RayBackground")
                .resizable()
        case .wave:
            Image("WaveBackground")
                .resizable()
        }
    }
}

struct CardBackground: View {
    var theme: JournalTheme = .line
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(getCardBackground(forTheme: theme))
            .shadow(color: Color.shadow, radius: 4)
    }

    func getCardBackground(forTheme: JournalTheme) -> Color {
        switch forTheme {
        case .line:
            return Color.paleOrange
        case .curve:
            return Color.curveCard
        case .dot:
            return Color.dotCard
        case .ray:
            return Color.rayCard
        case .wave:
            return Color.waveCard
        }
    }
}

struct CardStyle: ViewModifier {
    var theme: JournalTheme = .line
    func body(content: Content) -> some View {
        content
            .background(CardBackground(theme: theme))
            .padding(5)
    }
}

extension JournalFont {
    func uiFont(_ size: CGFloat) -> Font {
        switch self {
        case .font1:
            return Font.system(size: size, weight: .medium, design: .rounded)

        case .font2:
            return Font.custom(rawValue, size: size)

        case .font3:
            return Font.custom(rawValue, size: size)
        }
    }
}

struct FontStyle: ViewModifier {
    var size: CGFloat
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .medium, design: .rounded))
            .foregroundColor(.darkBrown)
    }
}

struct EntryBannerStyle: ViewModifier {
    var theme: JournalTheme
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .background(CardBackground(theme: theme))
    }
}

struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

struct EntryListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
    }
}
