import SwiftUI

struct Entry: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()
    var title = ""
    var font: JournalFont = .font1
    var theme: JournalTheme = .line
    var entryRows: [EntryRow] = [
        EntryRow(count: 1, cards: [CardData(card: .text(value: TextData()), size: .large)]),
    ]

    mutating func addCard(card: CardData) {
        if entryRows.count == 0 {
            entryRows.append(EntryRow(count: 1, cards: [card]))
        } else {
            if var entryRow = entryRows.last {
                if card.size == .small && entryRow.cards[0].size == card.size {
                    if entryRow.count == 2 {
                        entryRows.append(EntryRow(count: 1, cards: [card]))
                    } else {
                        entryRow.cards.append(card)
                        let card = EntryRow(count: entryRow.count + 1, cards: entryRow.cards)
                        entryRows.removeLast()
                        entryRows.append(card)
                    }
                } else {
                    entryRows.append(EntryRow(count: 1, cards: [card]))
                }
            }
        }
    }

    mutating func update(from entry: Entry) {
        title = entry.title
        font = entry.font
        theme = entry.theme
        entryRows = entry.entryRows
    }

    mutating func removeCard(cards: [CardData], row: Int, index: Int) {
        if cards.count == 1 {
            entryRows.remove(at: row)
        } else {
            entryRows[row].cards.remove(at: index)
            entryRows[row].count = entryRows[row].count - 1
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EntryRow: Equatable, Codable {
    var count: Int
    var cards: [CardData]
}

enum JournalFont: String, CaseIterable, Codable {
    case font1 = "SF Pro Rounded"
    case font2 = "Bradley Hand"
    case font3 = "Times New Roman"
}

enum JournalTheme: String, CaseIterable, Codable {
    case line
    case curve
    case dot
    case ray
    case wave
}
