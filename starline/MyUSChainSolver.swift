import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSChainSolver: ObservableObject {

    struct Segment: Equatable {
        var a: CGPoint
        var b: CGPoint
        var radius: CGFloat
    }

    @Published private(set) var segments: [Segment] = []
    @Published var iterations: Int = 8
    @Published var stiffness: CGFloat = 0.85
    @Published var damping: CGFloat = 0.92
    @Published var gravity: CGVector = .init(dx: 0, dy: 820)

    private var lastStamp: TimeInterval = 0

    init() {}

    func reset() {
        segments.removeAll()
        lastStamp = 0
    }

    func build(from nodes: [MyUSChainNode]) {
        segments.removeAll()
        if nodes.count < 2 { return }

        var out: [Segment] = []
        out.reserveCapacity(nodes.count - 1)

//        for i in 0..<(nodes.count - 1) {
//            let a = nodes[i].center
//            let b = nodes[i + 1].center
//            let r = max(0.5, min(nodes[i].radius, nodes[i + 1].radius))
//            out.append(Segment(a: a, b: b, radius: r))
//        }

        segments = out
    }

    func step(
        now: TimeInterval,
        orbs: [MyUSOrbNode],
        pins: [MyUSPinNode],
        bounds: CGRect
    ) {
        let dt = computeDt(now)
        if dt <= 0 { return }

        applyForces(dt: dt, bounds: bounds)
        applyConstraints(bounds: bounds)
        resolveOrbContacts(orbs: orbs)
        resolvePinContacts(pins: pins)
        applyDamping()
    }

    // MARK: - Internals

    private func computeDt(_ now: TimeInterval) -> CGFloat {
        if lastStamp == 0 {
            lastStamp = now
            return 0
        }
        let raw = now - lastStamp
        lastStamp = now
        let clamped = max(0.0, min(1.0 / 20.0, raw))
        return CGFloat(clamped)
    }

    private func applyForces(dt: CGFloat, bounds: CGRect) {
        guard segments.isEmpty == false else { return }

        let gx = gravity.dx
        let gy = gravity.dy

        for i in segments.indices {
            var s = segments[i]

            // simple verlet-like drift (apply gravity to endpoints)
            s.a = CGPoint(x: s.a.x + gx * dt * dt, y: s.a.y + gy * dt * dt)
            s.b = CGPoint(x: s.b.x + gx * dt * dt, y: s.b.y + gy * dt * dt)

            // keep in bounds (soft)
            s.a = clampPoint(s.a, inside: bounds, pad: s.radius)
            s.b = clampPoint(s.b, inside: bounds, pad: s.radius)

            segments[i] = s
        }
    }

    private func applyConstraints(bounds: CGRect) {
        guard segments.count > 0 else { return }

        let it = max(1, min(32, iterations))
        let k = max(0.0, min(1.0, stiffness))

        // enforce connectivity: end of seg i == start of seg i+1 (softly)
        for _ in 0..<it {
            for i in 0..<(segments.count - 1) {
                var s0 = segments[i]
                var s1 = segments[i + 1]

                let mid = CGPoint(
                    x: (s0.b.x + s1.a.x) * 0.5,
                    y: (s0.b.y + s1.a.y) * 0.5
                )

                s0.b = lerp(s0.b, mid, t: k)
                s1.a = lerp(s1.a, mid, t: k)

                s0.a = clampPoint(s0.a, inside: bounds, pad: s0.radius)
                s0.b = clampPoint(s0.b, inside: bounds, pad: s0.radius)
                s1.a = clampPoint(s1.a, inside: bounds, pad: s1.radius)
                s1.b = clampPoint(s1.b, inside: bounds, pad: s1.radius)

                segments[i] = s0
                segments[i + 1] = s1
            }
        }
    }

    private func resolveOrbContacts(orbs: [MyUSOrbNode]) {
        guard segments.isEmpty == false else { return }
        guard orbs.isEmpty == false else { return }

        for i in segments.indices {
            var s = segments[i]
            for orb in orbs where orb.isActive {
                s = pushSegmentOutOfCircle(seg: s, center: orb.center, radius: orb.radius)
            }
            segments[i] = s
        }
    }

    private func resolvePinContacts(pins: [MyUSPinNode]) {
        guard segments.isEmpty == false else { return }
        guard pins.isEmpty == false else { return }

        for i in segments.indices {
            var s = segments[i]
            for p in pins where p.isActive {
              //  s = pushSegmentOutOfCircle(seg: s, center: p.center, radius: p.radius)
            }
            segments[i] = s
        }
    }

    private func applyDamping() {
        let d = max(0.0, min(0.999, damping))
        guard segments.isEmpty == false else { return }

        for i in segments.indices {
            // gentle shrink towards midpoint to avoid exploding jitter
            var s = segments[i]
            let mid = CGPoint(x: (s.a.x + s.b.x) * 0.5, y: (s.a.y + s.b.y) * 0.5)
            s.a = lerp(mid, s.a, t: d)
            s.b = lerp(mid, s.b, t: d)
            segments[i] = s
        }
    }

    // MARK: - Geometry helpers

    private func clampPoint(_ p: CGPoint, inside r: CGRect, pad: CGFloat) -> CGPoint {
        CGPoint(
            x: min(max(p.x, r.minX + pad), r.maxX - pad),
            y: min(max(p.y, r.minY + pad), r.maxY - pad)
        )
    }

    private func lerp(_ a: CGPoint, _ b: CGPoint, t: CGFloat) -> CGPoint {
        let tt = max(0.0, min(1.0, t))
        return CGPoint(x: a.x + (b.x - a.x) * tt, y: a.y + (b.y - a.y) * tt)
    }

    private func pushSegmentOutOfCircle(seg: Segment, center: CGPoint, radius: CGFloat) -> Segment {
        var s = seg
        let r = max(0.0, radius + seg.radius)

        // push endpoints if inside circle
        s.a = pushPointOutOfCircle(p: s.a, c: center, r: r)
        s.b = pushPointOutOfCircle(p: s.b, c: center, r: r)

        return s
    }

    private func pushPointOutOfCircle(p: CGPoint, c: CGPoint, r: CGFloat) -> CGPoint {
        let dx = p.x - c.x
        let dy = p.y - c.y
        let d = hypot(dx, dy)
        if d <= 0.0001 { return CGPoint(x: c.x + r, y: c.y) }
        if d >= r { return p }
        let nx = dx / d
        let ny = dy / d
        return CGPoint(x: c.x + nx * r, y: c.y + ny * r)
    }
}
