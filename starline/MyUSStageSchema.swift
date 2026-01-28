import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSStageSchema: ObservableObject {

    struct Stage: Identifiable, Equatable {
        let id: Int
        var nodes: [NodeSpec]
        var goal: GoalSpec
    }

    struct NodeSpec: Identifiable, Equatable {
        let id: Int
        var position: CGPoint
        var kind: Kind

        enum Kind: Equatable {
            case chain
            case pin
            case orb
            case sliceZone
        }
    }

    struct GoalSpec: Equatable {
        var targetArea: CGRect
        var requiredCount: Int
    }

    @Published private(set) var currentStage: Stage?

    init() {}

    func loadStage(id: Int) {
        currentStage = makePlaceholderStage(id: id)
    }

    func reset() {
        currentStage = nil
    }

    private func makePlaceholderStage(id: Int) -> Stage {
        let nodes: [NodeSpec] = [
            NodeSpec(id: 1, position: CGPoint(x: 0.3, y: 0.2), kind: .chain),
            NodeSpec(id: 2, position: CGPoint(x: 0.7, y: 0.2), kind: .pin),
            NodeSpec(id: 3, position: CGPoint(x: 0.5, y: 0.5), kind: .orb),
            NodeSpec(id: 4, position: CGPoint(x: 0.5, y: 0.8), kind: .sliceZone)
        ]

        let goal = GoalSpec(
            targetArea: CGRect(x: 0.4, y: 0.85, width: 0.2, height: 0.1),
            requiredCount: 1
        )

        return Stage(
            id: id,
            nodes: nodes,
            goal: goal
        )
    }
}
