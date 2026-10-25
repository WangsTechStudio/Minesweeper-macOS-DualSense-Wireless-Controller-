import Foundation

enum CellState {
    case hidden
    case revealed
    case flagged
}

struct Cell: Identifiable {
    let id = UUID()
    let row: Int
    let col: Int
    var isMine: Bool
    var state: CellState = .hidden
    var neighborMineCount: Int = 0
}

// 新增 Equatable 协议，自动支持 == 比较
struct GameDifficulty: Equatable {
    let rows: Int
    let cols: Int
    let mineCount: Int
    
    static let easy = GameDifficulty(rows: 9, cols: 9, mineCount: 10)
    static let medium = GameDifficulty(rows: 16, cols: 16, mineCount: 40)
    static let hard = GameDifficulty(rows: 16, cols: 30, mineCount: 99)
}

