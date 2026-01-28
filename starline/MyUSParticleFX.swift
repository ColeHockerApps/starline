import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSParticleFX: ObservableObject {

    struct Particle: Identifiable {
        let id = UUID()
        var position: CGPoint
        var velocity: CGVector
        var life: Double
        var size: CGFloat
        var opacity: Double
    }

    @Published private(set) var particles: [Particle] = []

    private var isRunning: Bool = false
    private var timer: AnyCancellable?

    init() {}

    deinit {
       // stop()
    }

    func start() {
        guard isRunning == false else { return }
        isRunning = true

        timer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timer?.cancel()
        timer = nil
        isRunning = false
        particles.removeAll()
    }

    func emit(at point: CGPoint, count: Int = 8) {
        guard isRunning else { return }

        for _ in 0..<count {
            let angle = Double.random(in: 0..<Double.pi * 2)
            let speed = CGFloat.random(in: 20...80)

            let velocity = CGVector(
                dx: cos(angle) * speed,
                dy: sin(angle) * speed
            )

            let p = Particle(
                position: point,
                velocity: velocity,
                life: Double.random(in: 0.6...1.4),
                size: CGFloat.random(in: 4...10),
                opacity: 1.0
            )

            particles.append(p)
        }
    }

    private func tick() {
        let dt = 1.0 / 60.0
        var alive: [Particle] = []

        for var p in particles {
            p.life -= dt
            if p.life <= 0 { continue }

            p.position.x += p.velocity.dx * dt
            p.position.y += p.velocity.dy * dt

            p.velocity.dx *= 0.98
            p.velocity.dy *= 0.98

            p.opacity = max(0, p.life)
            alive.append(p)
        }

        particles = alive
    }
}
