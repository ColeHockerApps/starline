import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSSliceNode: ObservableObject, Identifiable {

    let id: UUID = UUID()

    @Published var start: CGPoint
    @Published var end: CGPoint
    @Published var thickness: CGFloat
    @Published var isActive: Bool = true
    @Published var didTrigger: Bool = false

    init(
        start: CGPoint = .zero,
        end: CGPoint = .zero,
        thickness: CGFloat = 6.0
    ) {
        self.start = start
        self.end = end
        self.thickness = max(1.0, thickness)
    }

    // MARK: - State

    func activate() {
        isActive = true
    }

    func deactivate() {
        isActive = false
    }

    func resetTrigger() {
        didTrigger = false
    }

    // MARK: - Update

    func update(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }

    func markTriggered() {
        didTrigger = true
    }

    // MARK: - Geometry

    func length() -> CGFloat {
        hypot(end.x - start.x, end.y - start.y)
    }

    func direction() -> CGVector {
        CGVector(dx: end.x - start.x, dy: end.y - start.y)
    }

    func intersectsSegment(_ a: CGPoint, _ b: CGPoint) -> Bool {
        guard isActive else { return false }
        return segmentsIntersect(start, end, a, b)
    }

    // MARK: - Math

    private func segmentsIntersect(
        _ p1: CGPoint,
        _ p2: CGPoint,
        _ p3: CGPoint,
        _ p4: CGPoint
    ) -> Bool {
        let d1 = directionValue(p3, p4, p1)
        let d2 = directionValue(p3, p4, p2)
        let d3 = directionValue(p1, p2, p3)
        let d4 = directionValue(p1, p2, p4)

        if d1 * d2 < 0 && d3 * d4 < 0 { return true }

        if d1 == 0 && onSegment(p3, p4, p1) { return true }
        if d2 == 0 && onSegment(p3, p4, p2) { return true }
        if d3 == 0 && onSegment(p1, p2, p3) { return true }
        if d4 == 0 && onSegment(p1, p2, p4) { return true }

        return false
    }

    private func directionValue(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGFloat {
        (c.x - a.x) * (b.y - a.y) - (c.y - a.y) * (b.x - a.x)
    }

    private func onSegment(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
        min(a.x, b.x) <= c.x && c.x <= max(a.x, b.x) &&
        min(a.y, b.y) <= c.y && c.y <= max(a.y, b.y)
    }
}
