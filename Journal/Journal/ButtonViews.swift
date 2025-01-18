import SwiftUI

struct RemoveCardButton: View {
    @Binding var entryCopy: Entry
    var card: Card
    var isEditing: Bool
    var row: Int
    var index: Int
    var action: () -> Void = {}

    var body: some View {
        Button {
            entryCopy.removeCard(cards: entryCopy.entryRows[row].cards, row: row, index: index)
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(card.isPhoto ? .white : .darkBrown)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding([.top, .trailing])
        }
        .opacity(isEditing ? 1 : 0)
    }
}

struct FontButton: View {
    @Binding var entry: Entry
    var font: JournalFont
    var action: () -> Void = {}

    var body: some View {
        Button {
            entry.font = font
        } label: {
            HStack {
                Image(systemName: entry.font == font ? "circle.fill" : "circle")
                    .font(.caption)
                Text(font.rawValue)
                    .font(font.uiFont(18))
                    .padding(.leading, 5)
                    .foregroundColor(.darkBrown)
            }
        }
    }
}

struct EditingButton: View {
    @Binding var entries: [Entry]
    @Binding var entry: Entry
    @Binding var entryCopy: Entry
    @Binding var isNew: Bool
    @Binding var isEditing: Bool
    var action: () -> Void = {}
    var isAdded: Bool {
        entries.filter { $0.id == entryCopy.id }.first != nil
    }

    var body: some View {
        Button {
            if isNew && isEditing {
                if !isAdded {
                    entries.append(entryCopy)
                } else {
                    if let index = entries.firstIndex(where: { $0.id == entryCopy.id }) {
                        entries[index].update(from: entryCopy)
                    }
                }
            } else if !isNew && isEditing {
                entry.update(from: entryCopy)
            } else if !isNew && !isEditing {
                entryCopy = entry
            }
            withAnimation(.spring()) {
                isEditing.toggle()
            }
        } label: {
            if isNew && isEditing {
                if isAdded {
                    Text("Done")
                        .fontWeight(.medium)
                } else {
                    Text("Add")
                        .fontWeight(.medium)
                }
            } else if !isNew && isEditing {
                Text("Done")
                    .fontWeight(.medium)
            } else if !isEditing {
                Text("Edit")
                    .fontWeight(.medium)
            }
        }
    }
}

struct EntryDetail: View {
    @Binding var entries: [Entry]
    @Binding var entry: Entry

    @State private var isNew: Bool
    @State private var isEditing: Bool
    @State private var entryCopy = Entry()

    init(entries: Binding<[Entry]>, entry: Binding<Entry>, isNew: Bool) {
        _entries = entries
        _entry = entry
        _isNew = State(initialValue: isNew)
        _isEditing = State(initialValue: isNew ? true : false)
    }

    var body: some View {
        EntryView(entry: isNew ? $entryCopy : $entry, entryCopy: $entryCopy, isEditing: $isEditing)
            .navigationBarBackButtonHidden(isNew ? false : isEditing)
            .toolbar {
                ToolbarItem {
                    EditingButton(entries: $entries, entry: $entry, entryCopy: $entryCopy, isNew: $isNew, isEditing: $isEditing)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isNew && isEditing {
                        Button("Cancel") {
                            withAnimation(.spring()) {
                                isEditing.toggle()
                            }
                        }
                    }
                }
            }
    }
}

struct SettingsButton: View {
    @Binding var showSettings: Bool
    var currentEntry: Entry = .init()
    var action: () -> Void = {}

    var body: some View {
        Button {
            showSettings.toggle()
            action()
        } label: {
            SettingsButtonView(theme: currentEntry.theme)
        }
    }
}

struct SettingsButtonView: View {
    var theme: JournalTheme

    var body: some View {
        VStack(spacing: 0) {
            BackgroundIcon(forTheme: theme)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            Text("Theme >")
                .modifier(FontStyle(size: 12))
        }
        .padding(.vertical)
    }
}

struct NewEntryLabel: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.tanBackground)
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.darkBrown, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
            Text("+ New Entry")
                .modifier(FontStyle(size: 30))
        }
        .frame(height: 80)
    }
}
