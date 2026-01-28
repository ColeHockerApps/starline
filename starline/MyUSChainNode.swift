import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSChainNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var position: CGPoint
    @Published var angle: CGFloat
    @Published var length: CGFloat

    @Published var isActive: Bool = true
    @Published var isLocked: Bool = false

    init(
        position: CGPoint = .zero,
        angle: CGFloat = 0,
        length: CGFloat = 1.0
    ) {
        self.position = position
        self.angle = angle
        self.length = max(0.001, length)
    }

    // MARK: - State

    func activate() {
        isActive = true
    }

    func deactivate() {
        isActive = false
    }

    func lock() {
        isLocked = true
    }

    func unlock() {
        isLocked = false
    }

    // MARK: - Transform

    func setPosition(_ value: CGPoint) {
        guard isLocked == false else { return }
        position = value
    }

    func setAngle(_ value: CGFloat) {
        guard isLocked == false else { return }
        angle = value
    }

    func setLength(_ value: CGFloat) {
        guard isLocked == false else { return }
        length = max(0.001, value)
    }

    // MARK: - Helpers

    func endPoint() -> CGPoint {
        CGPoint(
            x: position.x + cos(angle) * length,
            y: position.y + sin(angle) * length
        )
    }
}
