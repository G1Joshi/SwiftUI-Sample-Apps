import SwiftUI

struct EntryView: View {
    @Binding var entry: Entry
    @Binding var entryCopy: Entry
    @Binding var isEditing: Bool

    @State private var showingCardOptions = false
    @State private var showingSettings = false

    private func isSmallView(for entryRow: EntryRow) -> Bool {
        return entryRow.cards[0].size == .small
    }

    private var currentEntry: Entry {
        isEditing ? entryCopy : entry
    }

    private var currentEntryBinding: Binding<Entry> {
        isEditing ? $entryCopy : $entry
    }

    var body: some View {
        ScrollView {
            Grid(alignment: .top) {
                TitleView(entry: currentEntryBinding, isEditing: isEditing)
                    .padding(5)
                ForEach(0 ..< currentEntry.entryRows.count, id: \.self) { row in
                    if isSmallView(for: currentEntry.entryRows[row]) {
                        GridRow {
                            ForEach(0 ..< currentEntry.entryRows[row].count, id: \.self) { index in
                                getCardView(row: row, index: index)
                            }
                        }
                    } else {
                        getCardView(row: row, index: 0)
                    }
                }
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                }
            }
            .padding()

            Button {
                showingCardOptions.toggle()
            } label: {
                AddNewCardLabel()
            }
            .opacity(isEditing ? 1 : 0)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: 500)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingCardOptions) {
            PickCardView(entry: currentEntryBinding, showingSheet: $showingCardOptions)
                .presentationDetents([.fraction(0.8)])
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if isEditing {
                    SettingsButton(showSettings: $showingSettings, currentEntry: currentEntry)
                        .sheet(isPresented: $showingSettings) {
                            VStack {
                                SettingsView(entry: currentEntryBinding, showingSheet: $showingSettings)
                            }
                        }
                }
            }
        }
        .background(
            EntryBackground(forTheme: currentEntry.theme)
                .modifier(BackgroundStyle())
                .opacity(isEditing ? 0.5 : 1)
        )
    }

    @ViewBuilder
    private func getCardView(row: Int, index: Int) -> some View {
        CardView(cardData: currentEntryBinding.entryRows[row].cards[index], isEditing: isEditing, fontStyle: currentEntry.font)
            .overlay(alignment: .topTrailing) {
                RemoveCardButton(entryCopy: $entryCopy, card: currentEntry.entryRows[row].cards[index].card, isEditing: isEditing, row: row, index: index)
            }
            .modifier(CardStyle(theme: currentEntry.theme))
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        EntryView(entry: .constant(Entry()), entryCopy: .constant(Entry()), isEditing: .constant(true))
    }
}

struct AddNewCardLabel: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.paleOrange)
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.darkBrown)
        }
        .padding(.vertical)
    }
}
