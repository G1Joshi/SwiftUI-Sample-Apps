import SwiftUI

struct MLGameView: View {
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        RPSGameView(isMLGame: true)
            .environmentObject(appModel)
    }
}
