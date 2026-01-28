import SwiftUI
import Combine

struct MyUSEntryScreen: View {

    @EnvironmentObject private var router: MyUSRouter
    @EnvironmentObject private var launch: MyUSLaunchStore
    @EnvironmentObject private var session: MyUSSessionState
    @EnvironmentObject private var orientation: MyUSOrientationManager

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false
    @State private var pendingPoint: URL? = nil
    @State private var didApplyRotationRule: Bool = false

    var body: some View {
        ZStack {
            MyUSPlayContainer {
                surfaceReady = true
                applyRotationIfPossible()
                tryFinishLoading()
            }
            .opacity(showLoading ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showLoading)

            if showLoading {
                MyUSLoadingScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            orientation.allowFlexible()

            showLoading = true
            minTimePassed = false
            surfaceReady = false
            pendingPoint = nil
            didApplyRotationRule = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                minTimePassed = true
                applyRotationIfPossible()
                tryFinishLoading()
            }
        }
        .onReceive(orientation.$activeValue) { next in
            pendingPoint = next
            applyRotationIfPossible()
        }
    }

    private func applyRotationIfPossible() {
        guard didApplyRotationRule == false else { return }
        guard minTimePassed && surfaceReady else { return }
        guard let next = pendingPoint else { return }

        if isSame(next, launch.mainPoint) {
            MyUSFlowDelegate.shared?.lockPortrait()
        } else {
            MyUSFlowDelegate.shared?.allowFlexible()
        }

        didApplyRotationRule = true
    }

    private func tryFinishLoading() {
        guard minTimePassed && surfaceReady else { return }
        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }

    private func isSame(_ a: URL, _ b: URL) -> Bool {
        normalize(a) == normalize(b)
    }

    private func normalize(_ u: URL) -> String {
        var s = u.absoluteString
        while s.count > 1, s.hasSuffix("/") { s.removeLast() }
        return s
    }
}
