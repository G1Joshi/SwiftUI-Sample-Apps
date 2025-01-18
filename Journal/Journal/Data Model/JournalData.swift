import SwiftUI

class JournalData: ObservableObject {
    @Published var entries: [Entry] = [
        Entry(
            title: "Home Garden",
            font: .font2,
            theme: .dot,
            entryRows:
            [
                EntryRow(count: 2,
                         cards: [
                             CardData(card: .photo(value: ImageModel(fileName: "Peony", location: .resources)), size: .small),
                             CardData(card: .text(value: TextData(text: "Some lovely pink Peonies I found in the garden today.")), size: .small),
                         ]),
                EntryRow(count: 2,
                         cards: [
                             CardData(card: .photo(value: ImageModel(fileName: "Daisy", location: .resources)), size: .small),
                             CardData(card: .text(value: TextData(text: "I’m going to bring some of these dasies to the neighbors as a housewarming present.")), size: .small),
                         ]),
                EntryRow(count: 1,
                         cards: [
                             CardData(card: .photo(value: ImageModel(fileName: "WhiteRose", location: .resources)), size: .large),
                         ]),
                EntryRow(count: 1,
                         cards: [
                             CardData(card: .text(value: TextData(text: "I need a little help identifying some of these flowers. I think steve has a coffee table book on flowers I might be able to borrow.")), size: .large),
                         ]),
                EntryRow(count: 2,
                         cards: [
                             CardData(card: .photo(value: ImageModel(fileName: "LemonBloom", location: .resources)), size: .small),
                             CardData(card: .mood(value: "😁"), size: .small),
                         ]),
            ]
        ),
        Entry(
            title: "Japan Trip",
            font: .font3,
            theme: .curve,
            entryRows:
            [
                EntryRow(count: 1,
                         cards: [
                             CardData(card: .text(value: TextData(text: "I spent the day packing for the trip and making sure I have everything! Less than a week until we leave and I'm super excited for it!")), size: .large),
                         ]),
                EntryRow(count: 2,
                         cards: [
                             CardData(card: .text(value: TextData(text: "Booked a cabin up north and I’m going to go Skiing for the first time!")), size: .small),
                             CardData(card: .photo(value: ImageModel(fileName: "Mountain", location: .resources)), size: .small),
                         ]),
                EntryRow(count: 1,
                         cards: [
                             CardData(card: .sleep(value: 7), size: .large),
                         ]),
            ]
        ),
    ]

    init() {
        setup()
    }

    func getBindingToEntry(_ entry: Entry) -> Binding<Entry>? {
        Binding<Entry>(
            get: {
                guard let index = self.entries.firstIndex(where: { $0.id == entry.id }) else { return Entry() }
                return self.entries[index]
            },
            set: { entry in
                guard let index = self.entries.firstIndex(where: { $0.id == entry.id }) else { return }
                self.entries[index] = entry
            }
        )
    }

    private static func getDataFileURL() throws -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("entries.data")
    }

    func load() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([Entry].self, from: data)
            print("Entry loaded: \(entries.count)")
        } catch {
            print("Failed to load from file. Backup data used")
        }
    }

    func save() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save")
        }
    }

    func setup() {
        do {
            let fileURL = try JournalData.getDataFileURL()
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([Entry].self, from: data)
        } catch {
            save()
        }
    }
}
