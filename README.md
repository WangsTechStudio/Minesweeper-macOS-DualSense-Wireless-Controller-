# Minesweeper for macOS

<img width="128" height="128" alt="mac256" src="https://github.com/user-attachments/assets/4a9e17c7-5580-4819-a427-e3c702104904" />

一款基于 SwiftUI 开发的原生 macOS 扫雷游戏，完美适配 macOS 26 系统，支持鼠标与 PS5 DualSense 手柄双操控模式，包含初级、中级、高级三档经典难度。

## ✨ 功能特性

- **三档经典难度**：初级（9×9 / 10雷）、中级（16×16 / 40雷）、高级（16×30 / 99雷）
- **原生 SwiftUI 架构**：分层设计，运行流畅，适配 macOS 深色/浅色模式
- **PS5 手柄原生支持**：系统级蓝牙连接，无需第三方驱动
- **黄色光标追踪**：手柄操控时黄色高亮框实时定位当前选中格子
- **固定窗口尺寸**：各难度自动适配窗口大小，禁止手动缩放
- **实时状态显示**：剩余地雷数、游戏状态、难度选中高亮

## 🎮 游戏截图

### 初级难度主界面
<img alt="初级难度主界面" width="356" height="375" alt="截屏2026-10-26 01 35 29" src="https://github.com/user-attachments/assets/b7a80d77-aff6-4939-9b6f-9bce5aa4db7a" />

### 中级难度主界面
<img alt="中级难度主界面" width="388" height="529" alt="截屏2026-10-26 01 35 39" src="https://github.com/user-attachments/assets/71cc91cc-a387-4cbd-be43-6fdf38c42390" />

### 高级难度主界面
<img alt="高级难度主界面" width="699" height="529" alt="截屏2026-10-26 01 35 47" src="https://github.com/user-attachments/assets/dfb2d04a-e9c7-4b97-aacb-8596b6c0955f" />


## 🖱️ 鼠标操作

| 操作 | 功能 |
|------|------|
| 鼠标左键 | 翻开格子 |
| 鼠标右键 | 插旗 / 取消标记地雷 |
| 点击难度按钮 | 切换初级 / 中级 / 高级 |
| 重新开始按钮 | 重置当前难度对局 |

## 🎮 PS5 手柄操作

macOS 11.3+ 系统原生支持 PS5 DualSense 手柄，蓝牙配对即可使用，无需安装任何驱动。

| PS5 手柄按键 | 对应功能 |
|--------------|----------|
| 方向键 ↑ ↓ ← → | 移动黄色选中光标 |
| × 键（Cross） | 翻开当前格子（确认） |
| ○ 键（Circle） | 插旗 / 取消标记 |
| Options 键 | 重新开始当前对局 |
| L1 左肩键 | 切换到上一个难度（循环） |
| R1 右肩键 | 切换到下一个难度（循环） |

### 手柄配对方法
1.  按住手柄 **创建键（Create） + PS 键**，直到灯条快速闪烁进入配对模式
2.  打开 Mac「系统设置 → 蓝牙」，连接 `DualSense Wireless Controller`
3.  启动游戏即可自动识别，无需额外配置

## 🟡 黄色光标追踪

手柄操控模式下，棋盘上会显示**黄色粗边框光标**，实时标记当前选中的格子：

- 方向键控制光标上下左右移动，支持边界限制，不会越界
- 鼠标点击任意格子时，光标自动同步到对应位置
- 切换难度后，光标自动重置到棋盘左上角
- 鼠标与手柄可无缝切换，两种操作方式并行不冲突

## 🖥️ 运行环境

- **系统要求**：macOS 13.0 及以上（兼容 macOS 26 Sequoia）
- **开发环境**：Xcode 15.0+
- **开发语言**：Swift 5.9+
- **UI 框架**：SwiftUI
- **手柄框架**：GameController

## 🚀 编译运行

1.  克隆仓库到本地
    ```bash
    git clone [https://github.com/](https://github.com/)你的用户名/Minesweeper-macOS.git
    ```
2.  使用 Xcode 打开 `Minesweeper.xcodeproj`
3.  选择 Scheme 为 Minesweeper，目标设备为 `My Mac`
4.  按下 `⌘R` 编译运行

## 📁 项目结构

```
Minesweeper/
├── MinesweeperApp.swift      # 程序入口
├── ContentView.swift         # 主界面与视图层
├── GameModel.swift           # 数据模型层
├── GameViewModel.swift       # 业务逻辑层
└── ControllerManager.swift   # 手柄输入管理
```

采用 MVVM 分层架构，数据模型、业务逻辑与视图层完全解耦，便于扩展与维护。


