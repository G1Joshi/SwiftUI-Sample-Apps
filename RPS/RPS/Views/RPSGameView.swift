import SwiftUI

struct RPSGameView: View {
    @EnvironmentObject var appModel: AppModel
    @StateObject var gameModel: GameModel = .init()

    var isMLGame: Bool = false

    @State private var predictedMove: String = GameMove.unknown.name
    @State private var gameResultText: String = ""

    private var label: String {
        switch gameModel.currentState {
        case .finished: return gameResultText.isEmpty ? "VS" : " "
        case .playing: return String(gameModel.countDown)
        case .notPlaying: return "VS"
        }
    }

    private var shouldDisablePlayButton: Bool {
        guard gameModel.currentState != .playing else { return true }
        if isMLGame {
            return !appModel.isHandInFrame || !appModel.isGatheringObservations || !gameResultText.isEmpty
        } else {
            return !gameResultText.isEmpty
        }
    }

    private let padding: CGFloat = 20

    var body: some View {
        VStack(spacing: 0) {
            computersMoveView()
            labelView()
            yourMoveView()

            if !isMLGame {
                playButton()
                    .modifier(GameLabelBackground())
            }
        }
        .onReceive(gameModel.gameTimer) { _ in
            let resultText = gameModel.updateGameTimer()
            guard !resultText.isEmpty else { return }
            gameResultText = resultText
        }
        .onReceive(gameModel.rotationTimer) { _ in
            gameModel.updateComputersMove()
        }
        .background(gameBackground())
    }

    private func computersMoveView() -> some View {
        MoveView(player: .computer, moveName: $gameModel.computersMoveName)
            .environmentObject(gameModel)
            .frame(maxHeight: isMLGame ? 200 : .infinity, alignment: .center)
    }

    private func labelView() -> some View {
        Text(label)
            .font(.largeTitle)
            .foregroundColor(.labelAccent)
            .animation(.default)
            .transition(.slide)
            .padding(isMLGame ? padding / 2 : padding)
            .frame(maxWidth: .infinity)
            .modifier(GameLabelBackground())
    }

    @ViewBuilder
    private func gameResultView() -> some View {
        if gameModel.currentState == .finished {
            Text(gameResultText)
                .font(.largeTitle)
                .foregroundColor(.labelAccent)
                .padding(padding)
                .modifier(GameLabelBackground())
                .cornerRadius(10.0)
                .opacity(gameResultText.isEmpty ? 0.0 : 1.0)
                .animation(.linear, value: gameResultText.isEmpty)
        }
    }

    @ViewBuilder
    private func yourMoveView() -> some View {
        ZStack {
            if isMLGame {
                camera()
            } else {
                MoveView(player: .you, moveName: $gameModel.yourMoveName, hideArrows: shouldDisablePlayButton)
                    .environmentObject(gameModel)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .onChange(of: gameResultText) { _ in
                        guard !gameResultText.isEmpty else { return }
                        Task {
                            await Task.sleep(seconds: 1.5)
                            gameResultText = ""
                        }
                    }
            }
        }
        .overlay(alignment: .center) {
            gameResultView()
                .padding(.bottom, isMLGame ? padding * 2.5 : 0)
                .animation(.easeIn, value: !gameResultText.isEmpty)
        }
    }

    private func camera() -> some View {
        CameraView()
            .environmentObject(appModel)
            .onChange(of: gameModel.currentState) { _ in
                updateCameraAppearance(currentState: gameModel.currentState)
            }
            .onChange(of: appModel.predictionLabel) { _ in
                guard gameModel.currentState != .finished else { return }
                updateYourMove(with: appModel.predictionLabel)
            }
            .overlay(alignment: .bottom) {
                VStack {
                    PredictionLabelOverlay(label: appModel.predictionLabel)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    playButton()
                        .background(Color.translucentBlack)
                }
            }
    }

    private func playButton() -> some View {
        Button {
            gameModel.updateGameState()
        } label: {
            Text(gameModel.playButtonText)
        }
        .buttonStyle(CapsuleButton(disabled: shouldDisablePlayButton))
        .disabled(shouldDisablePlayButton)
        .padding()
        .frame(maxWidth: .infinity)
    }

    private func gameBackground() -> some View {
        Image("game-background")
            .resizable()
            .scaledToFill()
    }

    private func updateYourMove(with predicationLabel: String) {
        guard !predicationLabel.isEmpty else {
            gameModel.yourMoveName = GameMove.unknown.name
            return
        }
        predictedMove = predicationLabel
        gameModel.yourMoveName = predictedMove
    }

    private func updateCameraAppearance(currentState: GameState) {
        switch currentState {
        case .playing:
            appModel.shouldPauseCamera = true
        case .finished:
            appModel.isGatheringObservations = false
            Task {
                await Task.sleep(seconds: 1.5)
                gameResultText = ""
                appModel.shouldPauseCamera = false
                gameModel.currentState = .notPlaying
            }
        case .notPlaying:
            appModel.shouldPauseCamera = false
        }
    }
}

struct RPSGameView_Previews: PreviewProvider {
    static var previews: some View {
        RPSGameView()
            .environmentObject(AppModel())
    }
}
