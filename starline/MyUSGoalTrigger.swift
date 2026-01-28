import SwiftUI
import Combine
import CoreGraphics

@MainActor
final class MyUSGoalTrigger: ObservableObject {

    enum State {
        case idle
        case armed
        case triggered
        case completed
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var progress: Int = 0

    private var requiredCount: Int = 1
    private var targetArea: CGRect = .zero

    init() {}

    func configure(targetArea: CGRect, requiredCount: Int) {
        self.targetArea = targetArea
        self.requiredCount = max(1, requiredCount)
        reset()
    }

    func reset() {
        state = .idle
        progress = 0
    }

    func arm() {
        guard state == .idle else { return }
        state = .armed
    }

    func registerHit(at point: CGPoint) {
        guard state == .armed else { return }
        guard targetArea.contains(point) else { return }

        progress += 1

        if progress >= requiredCount {
            state = .completed
        } else {
            state = .triggered
        }
    }

    func isCompleted() -> Bool {
        state == .completed
    }
}
