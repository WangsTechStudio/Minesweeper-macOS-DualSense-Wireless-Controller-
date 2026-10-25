import SwiftUI
import Combine
import GameController

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel(difficulty: .medium)
    @StateObject private var controllerManager = ControllerManager()
    
    // 难度列表（按顺序排列，用于循环切换）
    private let difficulties: [GameDifficulty] = [.easy, .medium, .hard]
    // 当前难度索引，默认中级（索引1）
    @State private var currentDifficultyIndex: Int = 1
    // 手柄光标当前坐标
    @State private var selectedRow: Int = 0
    @State private var selectedCol: Int = 0
    
    // 格子固定尺寸
    private let cellSize: CGFloat = 22
    // 全局内边距
    private let padding: CGFloat = 20
    // 顶部控制区总高度
    private let controlAreaHeight: CGFloat = 110
    // 窗口最小宽度（保障顶部控件完整显示）
    private let minWindowWidth: CGFloat = 360
    
    // 当前难度（计算属性，由索引派生）
    private var currentDifficulty: GameDifficulty {
        difficulties[currentDifficultyIndex]
    }
    
    // 经典扫雷数字配色
    private let numberColors: [Color] = [
        .clear, .blue, .green, .red, .purple,
        .brown, .cyan, .black, .gray
    ]
    
    // 动态计算窗口尺寸
    private var windowWidth: CGFloat {
        let boardTotalWidth = CGFloat(viewModel.cols) * cellSize + padding * 2
        return max(boardTotalWidth, minWindowWidth)
    }
    
    private var windowHeight: CGFloat {
        CGFloat(viewModel.rows) * cellSize + controlAreaHeight + padding * 2
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 顶部状态栏
            HStack(spacing: 16) {
                Text("💣 \(viewModel.totalMines - viewModel.flagCount)")
                    .font(.system(size: 18, weight: .bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize()
                
                Spacer()
                
                Text(statusText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                Button("重新开始") {
                    viewModel.resetGame()
                }
                .buttonStyle(PrimaryButtonStyle())
                .fixedSize()
            }
            
            // 难度选择栏
            HStack(spacing: 12) {
                Button("初级") {
                    switchDifficulty(to: 0)
                }
                .buttonStyle(DifficultyButtonStyle(isSelected: currentDifficultyIndex == 0))
                
                Button("中级") {
                    switchDifficulty(to: 1)
                }
                .buttonStyle(DifficultyButtonStyle(isSelected: currentDifficultyIndex == 1))
                
                Button("高级") {
                    switchDifficulty(to: 2)
                }
                .buttonStyle(DifficultyButtonStyle(isSelected: currentDifficultyIndex == 2))
            }
            
            // 游戏棋盘（水平居中）
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    ForEach(0..<viewModel.rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<viewModel.cols, id: \.self) { col in
                                cellView(
                                    for: viewModel.board[row][col],
                                    isSelected: row == selectedRow && col == selectedCol
                                )
                                .onTapGesture {
                                    // 鼠标点击同步更新光标位置
                                    selectedRow = row
                                    selectedCol = col
                                    viewModel.revealCell(at: row, col)
                                }
                                .contextMenu {
                                    Button("插旗 / 取消") {
                                        viewModel.toggleFlag(at: row, col)
                                    }
                                }
                            }
                        }
                    }
                }
                .border(Color.gray.opacity(0.6), width: 2)
                Spacer()
            }
            
            Spacer(minLength: 0)
        }
        .padding(padding)
        .frame(width: windowWidth, height: windowHeight)
        .background(Color(nsColor: .windowBackgroundColor))
        // 订阅手柄输入事件
        .onReceive(controllerManager.inputPublisher) { action in
            handleControllerAction(action)
        }
    }
    
    // MARK: - 单个格子视图
    @ViewBuilder
    private func cellView(for cell: Cell, isSelected: Bool) -> some View {
        ZStack {
            Rectangle()
                .fill(cellBackground(for: cell.state))
                .frame(width: cellSize, height: cellSize)
            
            // 选中高亮：黄色粗边框
            if isSelected {
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: cellSize, height: cellSize)
            } else {
                Rectangle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    .frame(width: cellSize, height: cellSize)
            }
            
            switch cell.state {
            case .flagged:
                Text("🚩")
                    .font(.system(size: 14))
            case .revealed:
                if cell.isMine {
                    Text("💣")
                        .font(.system(size: 14))
                } else if cell.neighborMineCount > 0 {
                    Text("\(cell.neighborMineCount)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(numberColors[cell.neighborMineCount])
                }
            case .hidden:
                EmptyView()
            }
        }
    }
    
    // MARK: - 手柄输入事件处理
    private func handleControllerAction(_ action: ControllerManager.InputAction) {
        switch action {
        case .moveUp:
            guard selectedRow > 0 else { return }
            selectedRow -= 1
        case .moveDown:
            guard selectedRow < viewModel.rows - 1 else { return }
            selectedRow += 1
        case .moveLeft:
            guard selectedCol > 0 else { return }
            selectedCol -= 1
        case .moveRight:
            guard selectedCol < viewModel.cols - 1 else { return }
            selectedCol += 1
        case .confirm:
            viewModel.revealCell(at: selectedRow, selectedCol)
        case .flag:
            viewModel.toggleFlag(at: selectedRow, selectedCol)
        case .restart:
            viewModel.resetGame()
        case .prevDifficulty:
            // 循环切到上一个难度
            let newIndex = (currentDifficultyIndex - 1 + difficulties.count) % difficulties.count
            switchDifficulty(to: newIndex)
        case .nextDifficulty:
            // 循环切到下一个难度
            let newIndex = (currentDifficultyIndex + 1) % difficulties.count
            switchDifficulty(to: newIndex)
        }
    }
    
    // MARK: - 统一难度切换逻辑
    private func switchDifficulty(to index: Int) {
        currentDifficultyIndex = index
        // 切换难度时重置光标到左上角，避免数组越界
        selectedRow = 0
        selectedCol = 0
        viewModel.resetGame(difficulty: difficulties[index])
    }
    
    private func cellBackground(for state: CellState) -> Color {
        switch state {
        case .revealed:
            return Color(nsColor: .lightGray)
        case .hidden, .flagged:
            return Color(nsColor: .controlColor)
        }
    }
    
    private var statusText: String {
        switch viewModel.gameStatus {
        case .playing: return "🎮 游戏中"
        case .lost: return "💥 游戏失败"
        case .won: return "🎉 恭喜胜利"
        }
    }
}

// MARK: - 自定义按钮样式（全版本 macOS 兼容）
/// 主按钮样式：蓝底白字
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(6)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

/// 难度按钮样式：选中时蓝底白字，未选中时灰色边框
struct DifficultyButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.clear)
            .foregroundColor(isSelected ? .white : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
            .cornerRadius(6)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

#Preview {
    ContentView()
}

