import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSSliceResolver: ObservableObject {

    struct CutResult: Equatable {
        var didCut: Bool
        var affectedSegmentIndices: [Int]
        var cutPoint: CGPoint?
    }

    @Published private(set) var lastResult: CutResult = .init(didCut: false, affectedSegmentIndices: [], cutPoint: nil)

    init() {}

    func reset() {
        lastResult = .init(didCut: false, affectedSegmentIndices: [], cutPoint: nil)
    }

    func resolveCut(
        blade: MyUSSliceNode,
        solver: MyUSChainSolver,
        maxCuts: Int = 2
    ) -> CutResult {
//        let bladeA = blade.a
//        let bladeB = blade.b
        let bladeRadius = max(0.0, blade.thickness * 0.5)

        var hit: [Int] = []
        var pickedPoint: CGPoint? = nil

        let segs = solver.segments
        if segs.isEmpty {
            let res = CutResult(didCut: false, affectedSegmentIndices: [], cutPoint: nil)
            lastResult = res
            return res
        }

        for i in segs.indices {
            if hit.count >= maxCuts { break }
            let s = segs[i]

            let expanded = max(bladeRadius, s.radius)
//            if segmentIntersectsThickSegment(
////                a0: bladeA,
////                a1: bladeB,
//                b0: s.a,
//                b1: s.b,
//                thickness: expanded
//            ) {
//                hit.append(i)
//
//                if pickedPoint == nil {
//                    pickedPoint = approximateIntersectionPoint(
////                        a0: bladeA,
////                        a1: bladeB,
//                        b0: s.a,
//                        b1: s.b
//                    )
//                }
//            }
        }

        let res = CutResult(didCut: hit.isEmpty == false, affectedSegmentIndices: hit, cutPoint: pickedPoint)
        lastResult = res
        return res
    }

    // MARK: - Geometry

    private func segmentIntersectsThickSegment(
        a0: CGPoint,
        a1: CGPoint,
        b0: CGPoint,
        b1: CGPoint,
        thickness: CGFloat
    ) -> Bool {
        let t = max(0.0, thickness)

        // quick reject: distance from each endpoint to other segment
        if distancePointToSegment(p: a0, s0: b0, s1: b1) <= t { return true }
        if distancePointToSegment(p: a1, s0: b0, s1: b1) <= t { return true }
        if distancePointToSegment(p: b0, s0: a0, s1: a1) <= t { return true }
        if distancePointToSegment(p: b1, s0: a0, s1: a1) <= t { return true }

        // also check true segment intersection (thickness 0)
        return segmentsIntersect(a0, a1, b0, b1)
    }

    private func distancePointToSegment(p: CGPoint, s0: CGPoint, s1: CGPoint) -> CGFloat {
        let vx = s1.x - s0.x
        let vy = s1.y - s0.y
        let wx = p.x - s0.x
        let wy = p.y - s0.y

        let vv = vx * vx + vy * vy
        if vv <= 0.000001 {
            return hypot(p.x - s0.x, p.y - s0.y)
        }

        var t = (wx * vx + wy * vy) / vv
        t = min(max(t, 0), 1)

        let px = s0.x + t * vx
        let py = s0.y + t * vy
        return hypot(p.x - px, p.y - py)
    }

    private func segmentsIntersect(_ p1: CGPoint, _ p2: CGPoint, _ q1: CGPoint, _ q2: CGPoint) -> Bool {
        func orient(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> CGFloat {
            (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        }

        func onSeg(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Bool {
            min(a.x, b.x) - 0.0001 <= c.x && c.x <= max(a.x, b.x) + 0.0001 &&
            min(a.y, b.y) - 0.0001 <= c.y && c.y <= max(a.y, b.y) + 0.0001
        }

        let o1 = orient(p1, p2, q1)
        let o2 = orient(p1, p2, q2)
        let o3 = orient(q1, q2, p1)
        let o4 = orient(q1, q2, p2)

        if (o1 > 0 && o2 < 0 || o1 < 0 && o2 > 0) && (o3 > 0 && o4 < 0 || o3 < 0 && o4 > 0) {
            return true
        }

        if abs(o1) < 0.0001 && onSeg(p1, p2, q1) { return true }
        if abs(o2) < 0.0001 && onSeg(p1, p2, q2) { return true }
        if abs(o3) < 0.0001 && onSeg(q1, q2, p1) { return true }
        if abs(o4) < 0.0001 && onSeg(q1, q2, p2) { return true }

        return false
    }

    private func approximateIntersectionPoint(
        a0: CGPoint,
        a1: CGPoint,
        b0: CGPoint,
        b1: CGPoint
    ) -> CGPoint? {
        // line-line intersection (infinite), then clamp to segments
        let x1 = a0.x, y1 = a0.y
        let x2 = a1.x, y2 = a1.y
        let x3 = b0.x, y3 = b0.y
        let x4 = b1.x, y4 = b1.y

        let den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
        if abs(den) < 0.000001 { return nil }

        let px = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / den
        let py = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / den

        let p = CGPoint(x: px, y: py)

        // clamp to closest point on blade segment (more stable)
        return closestPointOnSegment(p: p, a: a0, b: a1)
    }

    private func closestPointOnSegment(p: CGPoint, a: CGPoint, b: CGPoint) -> CGPoint {
        let vx = b.x - a.x
        let vy = b.y - a.y
        let vv = vx * vx + vy * vy
        if vv <= 0.000001 { return a }
        let wx = p.x - a.x
        let wy = p.y - a.y
        var t = (wx * vx + wy * vy) / vv
        t = min(max(t, 0), 1)
        return CGPoint(x: a.x + t * vx, y: a.y + t * vy)
    }
}
