import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published private(set) var board: [[Cell]] = []
    @Published private(set) var gameStatus: GameStatus = .playing
    @Published private(set) var flagCount: Int = 0
    
    private(set) var rows: Int
    private(set) var cols: Int
    private(set) var totalMines: Int
    
    enum GameStatus {
        case playing
        case lost
        case won
    }
    
    init(difficulty: GameDifficulty = .medium) {
        self.rows = difficulty.rows
        self.cols = difficulty.cols
        self.totalMines = difficulty.mineCount
        initializeBoard()
    }
    
    func resetGame(difficulty: GameDifficulty? = nil) {
        if let diff = difficulty {
            rows = diff.rows
            cols = diff.cols
            totalMines = diff.mineCount
        }
        flagCount = 0
        gameStatus = .playing
        initializeBoard()
    }
    
    private func initializeBoard() {
        board = (0..<rows).map { row in
            (0..<cols).map { col in
                Cell(row: row, col: col, isMine: false)
            }
        }
        placeMines()
        calculateNeighborMines()
    }
    
    private func placeMines() {
        var placed = 0
        while placed < totalMines {
            let r = Int.random(in: 0..<rows)
            let c = Int.random(in: 0..<cols)
            if !board[r][c].isMine {
                board[r][c].isMine = true
                placed += 1
            }
        }
    }
    
    private func calculateNeighborMines() {
        for row in 0..<rows {
            for col in 0..<cols {
                guard !board[row][col].isMine else { continue }
                var count = 0
                for dr in -1...1 {
                    for dc in -1...1 {
                        if dr == 0 && dc == 0 { continue }
                        let nr = row + dr
                        let nc = col + dc
                        if isValidIndex(row: nr, col: nc) && board[nr][nc].isMine {
                            count += 1
                        }
                    }
                }
                board[row][col].neighborMineCount = count
            }
        }
    }
    
    private func isValidIndex(row: Int, col: Int) -> Bool {
        return row >= 0 && row < rows && col >= 0 && col < cols
    }
    
    func revealCell(at row: Int, _ col: Int) {
        guard gameStatus == .playing else { return }
        guard board[row][col].state == .hidden else { return }
        
        if board[row][col].isMine {
            gameStatus = .lost
            revealAllMines()
            return
        }
        
        floodReveal(row: row, col: col)
        checkWinCondition()
    }
    
    func toggleFlag(at row: Int, _ col: Int) {
        guard gameStatus == .playing else { return }
        let cell = board[row][col]
        guard cell.state != .revealed else { return }
        
        if cell.state == .flagged {
            board[row][col].state = .hidden
            flagCount -= 1
        } else {
            board[row][col].state = .flagged
            flagCount += 1
        }
    }
    
    private func floodReveal(row: Int, col: Int) {
        guard isValidIndex(row: row, col: col) else { return }
        var cell = board[row][col]
        guard cell.state == .hidden && !cell.isMine else { return }
        
        cell.state = .revealed
        board[row][col] = cell
        
        if cell.neighborMineCount == 0 {
            for dr in -1...1 {
                for dc in -1...1 {
                    floodReveal(row: row + dr, col: col + dc)
                }
            }
        }
    }
    
    private func revealAllMines() {
        for row in 0..<rows {
            for col in 0..<cols {
                if board[row][col].isMine {
                    board[row][col].state = .revealed
                }
            }
        }
    }
    
    private func checkWinCondition() {
        for row in 0..<rows {
            for col in 0..<cols {
                let cell = board[row][col]
                if !cell.isMine && cell.state != .revealed {
                    return
                }
            }
        }
        gameStatus = .won
    }
}

