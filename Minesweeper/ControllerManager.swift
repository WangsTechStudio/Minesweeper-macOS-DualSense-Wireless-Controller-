import Foundation
import GameController
import Combine

/// 手柄输入管理器，负责手柄连接生命周期与按键事件分发
class ControllerManager: ObservableObject {
    /// 手柄输入动作枚举
    enum InputAction {
        case moveUp
        case moveDown
        case moveLeft
        case moveRight
        case confirm    // 确认/翻开格子
        case flag       // 插旗/取消
        case restart    // 重新开始
        case prevDifficulty // 上一个难度
        case nextDifficulty // 下一个难度
    }
    
    /// 输入事件发布者，View 层订阅即可响应手柄操作
    let inputPublisher = PassthroughSubject<InputAction, Never>()
    
    private var connectedController: GCController?
    
    init() {
        // 注册手柄连接/断开系统通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleControllerConnect),
            name: NSNotification.Name.GCControllerDidConnect,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleControllerDisconnect),
            name: NSNotification.Name.GCControllerDidDisconnect,
            object: nil
        )
        
        // 启动蓝牙手柄扫描发现
        GCController.startWirelessControllerDiscovery()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        GCController.stopWirelessControllerDiscovery()
    }
    
    // MARK: - 手柄连接处理
    @objc private func handleControllerConnect(notification: Notification) {
        guard let controller = notification.object as? GCController else { return }
        connectedController = controller
        bindButtonEvents(for: controller)
    }
    
    @objc private func handleControllerDisconnect(notification: Notification) {
        connectedController = nil
    }
    
    // MARK: - 按键事件绑定
    private func bindButtonEvents(for controller: GCController) {
        // PS5 DualSense 属于标准扩展手柄，使用 extendedGamepad 配置文件
        guard let gamepad = controller.extendedGamepad else { return }
        
        // 方向键 - 上
        gamepad.dpad.up.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.moveUp)
        }
        
        // 方向键 - 下
        gamepad.dpad.down.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.moveDown)
        }
        
        // 方向键 - 左
        gamepad.dpad.left.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.moveLeft)
        }
        
        // 方向键 - 右
        gamepad.dpad.right.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.moveRight)
        }
        
        // × 键（对应标准手柄A键）：翻开格子
        gamepad.buttonA.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.confirm)
        }
        
        // ○ 键（对应标准手柄B键）：插旗
        gamepad.buttonB.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.flag)
        }
        
        // Options 键（对应菜单键）：重新开始
        gamepad.buttonMenu.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.restart)
        }
        
        // L1 左肩键：上一个难度
        gamepad.leftShoulder.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.prevDifficulty)
        }
        
        // R1 右肩键：下一个难度
        gamepad.rightShoulder.valueChangedHandler = { [weak self] _, _, isPressed in
            guard isPressed else { return }
            self?.inputPublisher.send(.nextDifficulty)
        }
    }
}

