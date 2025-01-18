import SwiftUI

struct PickCardView: View {
    @Binding var entry: Entry
    @Binding var showingSheet: Bool

    var body: some View {
        VStack {
            Grid(horizontalSpacing: 15, verticalSpacing: 15) {
                GridRow {
                    Color.clear
                        .gridCellUnsizedAxes([.horizontal, .vertical])
                    Text("Half")
                        .modifier(FontStyle(size: 18))
                    Text("Full")
                        .modifier(FontStyle(size: 18))
                }

                ForEach(Card.allCases, id: \.id) { option in
                    GridRow {
                        Text(Card.title(option))
                            .modifier(FontStyle(size: 18))
                            .gridCellAnchor(.trailing)
                        Button {
                            entry.addCard(card: CardData(card: option, size: .small))
                            showingSheet = false
                        } label: {
                            CardOptionView(icon: Card.icon(option))
                                .frame(maxWidth: 60, maxHeight: 60)
                        }
                        .disabled(SleepView.disableSleepViewHalf &&
                            option == .sleep(value: 0))
                        .opacity(option == .sleep(value: 0) && SleepView.disableSleepViewHalf ? 0.5 : 1)

                        Button {
                            entry.addCard(card: CardData(card: option, size: .large))
                            showingSheet = false
                        } label: {
                            CardOptionView(icon: Card.icon(option))
                                .frame(maxWidth: 100, maxHeight: 60)
                        }
                        .disabled(MoodView.disableMoodViewFull &&
                            option == .mood(value: "😁"))
                        .opacity(option == .mood(value: "😁") && MoodView.disableMoodViewFull ? 0.5 : 1)
                    }
                }
            }
        }
        .padding(.top)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paleOrange)
        .overlay(alignment: .topTrailing) {
            Button {
                showingSheet.toggle()
            } label: {
                Image(systemName: "xmark")
                    .modifier(FontStyle(size: 16))
            }
            .padding()
        }
    }
}

struct PickCardView_Previews: PreviewProvider {
    static var previews: some View {
        PickCardView(entry: .constant(Entry()), showingSheet: .constant(true))
    }
}

struct CardOptionView: View {
    var icon: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.darkBrown)
            Image(systemName: icon)
                .foregroundColor(.paleOrange)
                .font(.system(size: 25))
        }
    }
}
