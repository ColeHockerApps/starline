import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSPinNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var position: CGPoint
    @Published var radius: CGFloat
    @Published var isActive: Bool = true
    @Published var isLocked: Bool = false

    init(
        position: CGPoint = .zero,
        radius: CGFloat = 6.0
    ) {
        self.position = position
        self.radius = max(1.0, radius)
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

    func setRadius(_ value: CGFloat) {
        guard isLocked == false else { return }
        radius = max(1.0, value)
    }

    // MARK: - Helpers

    func contains(_ point: CGPoint) -> Bool {
        let dx = point.x - position.x
        let dy = point.y - position.y
        return (dx * dx + dy * dy) <= (radius * radius)
    }
}
