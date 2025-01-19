import SwiftUI

struct GameView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        RPSGameView(isMLGame: false)
            .environmentObject(appModel)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(showNodes: true)
            .environmentObject(AppModel())
    }
}
