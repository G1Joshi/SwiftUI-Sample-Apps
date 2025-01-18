import SwiftUI

struct SettingsView: View {
    @Binding var entry: Entry
    @Binding var showingSheet: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Font")
                    .modifier(FontStyle(size: 20))
                    .padding(.top)
                ForEach(JournalFont.allCases, id: \.self) { font in
                    FontButton(entry: $entry, font: font)
                }
                Text("Theme")
                    .modifier(FontStyle(size: 20))
                    .padding(.top)
                Grid(horizontalSpacing: 5, verticalSpacing: 10) {
                    GridRow {
                        getBackgroundButton(theme: .line)
                        getBackgroundButton(theme: .curve)
                        getBackgroundButton(theme: .wave)
                    }
                    GridRow {
                        getBackgroundButton(theme: .dot)
                        getBackgroundButton(theme: .ray)
                    }
                }
            }
        }
        .frame(maxWidth: 500)
        .padding(30)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            Button {
                showingSheet.toggle()
            } label: {
                Text("Done")
                    .modifier(FontStyle(size: 20))
                    .padding()
            }
        }
        .background(Color.paleOrange)
    }

    @ViewBuilder
    func getBackgroundButton(theme: JournalTheme) -> some View {
        Button {
            entry.theme = theme
        } label: {
            VStack(spacing: 5) {
                BackgroundIcon(forTheme: theme)
                    .scaledToFill()
                    .cornerRadius(10.0)
                    .shadow(color: Color.shadow, radius: 4)
                    .padding(5)

                Image(systemName: entry.theme == theme ? "circle.fill" : "circle")
                    .font(.callout)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(entry: .constant(Entry()), showingSheet: .constant(true))
    }
}
