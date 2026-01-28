import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSPhysicsRealm: ObservableObject {

    struct BodyID: Hashable {
        let raw: UUID
        init() { self.raw = UUID() }
    }

    struct Body {
        let id: BodyID
        var position: CGPoint
        var velocity: CGVector
        var mass: CGFloat
        var isStatic: Bool
    }

    @Published private(set) var bodies: [BodyID: Body] = [:]
    @Published var gravity: CGVector = .init(dx: 0, dy: 980)

    private var lastTime: TimeInterval?

    init() {}

    // MARK: - Lifecycle

    func reset() {
        bodies.removeAll()
        lastTime = nil
    }

    // MARK: - Body management

    func createBody(
        position: CGPoint,
        velocity: CGVector = .zero,
        mass: CGFloat = 1.0,
        isStatic: Bool = false
    ) -> BodyID {
        let id = BodyID()
        bodies[id] = Body(
            id: id,
            position: position,
            velocity: velocity,
            mass: max(0.001, mass),
            isStatic: isStatic
        )
        return id
    }

    func removeBody(_ id: BodyID) {
        bodies.removeValue(forKey: id)
    }

    func setPosition(_ id: BodyID, _ value: CGPoint) {
        guard var b = bodies[id] else { return }
        b.position = value
        bodies[id] = b
    }

    func setVelocity(_ id: BodyID, _ value: CGVector) {
        guard var b = bodies[id] else { return }
        b.velocity = value
        bodies[id] = b
    }

    // MARK: - Simulation step

    func step(currentTime: TimeInterval) {
        guard let last = lastTime else {
            lastTime = currentTime
            return
        }

        let dt = max(0, min(1.0 / 30.0, currentTime - last))
        lastTime = currentTime

        for (id, body) in bodies {
            guard body.isStatic == false else { continue }

            var b = body
            b.velocity.dx += gravity.dx * dt
            b.velocity.dy += gravity.dy * dt

            b.position.x += b.velocity.dx * dt
            b.position.y += b.velocity.dy * dt

            bodies[id] = b
        }
    }

    // MARK: - Queries

    func body(_ id: BodyID) -> Body? {
        bodies[id]
    }

    func allBodies() -> [Body] {
        Array(bodies.values)
    }
}
