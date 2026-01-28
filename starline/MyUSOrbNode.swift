import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSOrbNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var center: CGPoint
    @Published var radius: CGFloat
    @Published var velocity: CGVector
    @Published var isActive: Bool = true
    @Published var isStatic: Bool = false

    init(
        center: CGPoint = .zero,
        radius: CGFloat = 18.0,
        velocity: CGVector = .init(dx: 0, dy: 0)
    ) {
        self.center = center
        self.radius = max(1.0, radius)
        self.velocity = velocity
    }

    // MARK: - State

    func activate() {
        isActive = true
    }

    func deactivate() {
        isActive = false
    }

    func setStatic(_ value: Bool) {
        isStatic = value
        if value {
            velocity = .init(dx: 0, dy: 0)
        }
    }

    // MARK: - Update

    func setCenter(_ value: CGPoint) {
        center = value
    }

    func setVelocity(dx: CGFloat, dy: CGFloat) {
        velocity = .init(dx: dx, dy: dy)
    }

    func addImpulse(dx: CGFloat, dy: CGFloat) {
        velocity = .init(dx: velocity.dx + dx, dy: velocity.dy + dy)
    }

    func damp(_ factor: CGFloat) {
        let f = max(0.0, min(1.0, factor))
        velocity = .init(dx: velocity.dx * f, dy: velocity.dy * f)
    }

    func step(dt: CGFloat) {
        guard isActive else { return }
        guard isStatic == false else { return }
        let t = max(0.0, dt)
        center = CGPoint(x: center.x + velocity.dx * t, y: center.y + velocity.dy * t)
    }

    // MARK: - Bounds / Collisions

    func clampInside(_ rect: CGRect, bounce: CGFloat = 0.75) {
        guard isActive else { return }
        guard isStatic == false else { return }

        let b = max(0.0, min(1.0, bounce))

        var x = center.x
        var y = center.y

        let minX = rect.minX + radius
        let maxX = rect.maxX - radius
        let minY = rect.minY + radius
        let maxY = rect.maxY - radius

        if x < minX {
            x = minX
            velocity = .init(dx: -velocity.dx * b, dy: velocity.dy)
        } else if x > maxX {
            x = maxX
            velocity = .init(dx: -velocity.dx * b, dy: velocity.dy)
        }

        if y < minY {
            y = minY
            velocity = .init(dx: velocity.dx, dy: -velocity.dy * b)
        } else if y > maxY {
            y = maxY
            velocity = .init(dx: velocity.dx, dy: -velocity.dy * b)
        }

        center = CGPoint(x: x, y: y)
    }

    func distance(to point: CGPoint) -> CGFloat {
        hypot(center.x - point.x, center.y - point.y)
    }

    func contains(_ point: CGPoint) -> Bool {
        distance(to: point) <= radius
    }

    func overlaps(with other: MyUSOrbNode) -> Bool {
        let d = hypot(center.x - other.center.x, center.y - other.center.y)
        return d <= (radius + other.radius)
    }

    func resolveOverlap(with other: MyUSOrbNode, push: CGFloat = 0.5) {
        guard isActive, other.isActive else { return }

        let dx = center.x - other.center.x
        let dy = center.y - other.center.y
        let d = hypot(dx, dy)
        let minD = radius + other.radius
        if d <= 0.0001 || d >= minD { return }

        let overlap = (minD - d)
        let k = max(0.0, min(1.0, push))

        let nx = dx / d
        let ny = dy / d

        let move = overlap * k

        if isStatic == false {
            center = CGPoint(x: center.x + nx * move, y: center.y + ny * move)
        }
        if other.isStatic == false {
            other.center = CGPoint(x: other.center.x - nx * move, y: other.center.y - ny * move)
        }
    }
}
