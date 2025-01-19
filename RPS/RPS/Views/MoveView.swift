import SwiftUI

struct MoveView: View {
    var player: Player

    @EnvironmentObject var gameModel: GameModel
    @Binding var moveName: String

    var hideArrows: Bool = true

    @State private var currentMove: GameMove = .unknown

    @ScaledMetric private var iconPadding: CGFloat = 20
    @ScaledMetric private var viewPadding: CGFloat = 5
    @ScaledMetric private var scaledPadding: CGFloat = 20
    @ScaledMetric private var fontSize: CGFloat = 90
    @ScaledMetric private var arrowFontSize: CGFloat = 55
    @ScaledMetric private var cornerRadius: CGFloat = 15

    private var shouldShowArrows: Bool {
        player == .you
    }

    var body: some View {
        HStack {
            if shouldShowArrows {
                Button {
                    updateMove(.backward)
                } label: {
                    Label("Back", systemImage: "arrowshape.left.fill")
                        .font(.system(size: arrowFontSize))
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .opacity(hideArrows ? 0.0 : 1.0)
                .animation(.linear, value: hideArrows)
            }

            shape()
                .overlay(alignment: .center) {
                    icon()
                }
                .padding(viewPadding)

            if shouldShowArrows {
                Button {
                    updateMove()
                } label: {
                    Label("Next", systemImage: "arrowshape.right.fill")
                        .font(.system(size: arrowFontSize))
                }
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .opacity(hideArrows ? 0.0 : 1.0)
                .animation(.linear, value: hideArrows)
            }
        }
        .onChange(of: moveName) { _ in
            currentMove = gameModel.validMoves[moveName] ?? GameMove.unknown
        }
        .padding()
    }

    private func shape() -> some View {
        Group {
            if shouldShowArrows {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white)
                    .aspectRatio(contentMode: .fit)
            } else {
                Circle()
                    .fill(.white)
            }
        }
        .shadow(color: .translucentBlack, radius: 3.0)
    }

    private func icon() -> some View {
        Group {
            if currentMove == GameMove.unknown {
                Image(systemName: currentMove.icon)
                    .foregroundColor(.labelAccent)
            } else {
                Text(currentMove.icon)
            }
        }
        .fixedSize()
        .font(.system(size: fontSize))
        .padding(iconPadding)
    }

    private func updateMove(_ direction: RotationDirection = .forward) {
        guard player == .you else { return }
        let newMove = gameModel.rotateThroughValidMoves(currentMove.name, direction: direction)
        gameModel.yourMoveName = newMove.name
    }
}
