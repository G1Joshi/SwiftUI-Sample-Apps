import SwiftUI

struct EntryList: View {
    @ObservedObject var journalData: JournalData
    @State private var newEntry = Entry()
    @State private var selection: Entry?

    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading) {
                JournalAppTitle()
                List(selection: $selection) {
                    NewEntryLabel()
                        .tag(newEntry)
                        .modifier(ListRowStyle())

                    ForEach($journalData.entries) { $entry in
                        TitleView(entry: $entry)
                            .tag(entry)
                            .modifier(ListRowStyle())
                    }
                    .onDelete(perform: { indexSet in
                        journalData.entries.remove(atOffsets: indexSet)
                    })
                }
                .modifier(EntryListStyle())
            }
            .navigationTitle("Journal")
            .toolbar(.hidden)
            .background(
                Image("MenuBackground")
                    .resizable()
                    .modifier(BackgroundStyle())
            )

        } detail: {
            ZStack {
                if let entry = selection, let entryBinding = journalData.getBindingToEntry(entry) {
                    EntryDetail(entries: $journalData.entries, entry: entryBinding, isNew: entry == newEntry)
                } else {
                    SelectEntryView()
                }
            }
        }
    }
}

struct EntryList_Previews: PreviewProvider {
    static var previews: some View {
        EntryList(journalData: JournalData())
    }
}

struct JournalAppTitle: View {
    var body: some View {
        Text("Journal")
            .modifier(FontStyle(size: 50))
            .padding()
            .padding(.top)
    }
}

struct SelectEntryView: View {
    var body: some View {
        Text("Select An Entry")
            .modifier(FontStyle(size: 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.tanBackground)
            .ignoresSafeArea()
    }
}
