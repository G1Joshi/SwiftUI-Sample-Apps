import SwiftUI

final class GameMove {
    static var unknown = GameMove(name: "unknown", icon: "questionmark")
    var name: String
    var icon: String
    var beatsMoves: [GameMove] = []

    init(name: String, icon: String) {
        self.name = name.capitalized
        self.icon = icon
    }

    func beats(_ moves: [GameMove]) {
        beatsMoves += moves
    }

    func isWinner(comparedTo move: GameMove) -> Bool {
        return beatsMoves.contains { $0 == move }
    }

    func compare(to move: GameMove) -> GameResult {
        if isWinner(comparedTo: move) {
            return .win
        } else if move.isWinner(comparedTo: self) {
            return .lose
        }
        return .tie
    }
}

extension GameMove: Equatable {
    static func == (lhs: GameMove, rhs: GameMove) -> Bool {
        return lhs.name == rhs.name &&
            lhs.icon == rhs.icon &&
            lhs.beatsMoves == rhs.beatsMoves
    }
}

enum Player {
    case you
    case computer
}
