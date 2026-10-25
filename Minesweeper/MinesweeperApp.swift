//
//  MinesweeperApp.swift
//  Minesweeper

import SwiftUI

@main
struct MinesweeperApp: App {
    var body: some Scene {
        WindowGroup("扫雷") {
            ContentView()
  
        }
        .windowStyle(.titleBar)
        // 窗口大小严格由内容决定，禁止用户手动拖动缩放
        .windowResizability(.contentSize)
    }
}
