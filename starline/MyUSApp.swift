import SwiftUI
import Combine

@main
struct MyUSApp: App {

    @UIApplicationDelegateAdaptor(MyUSFlowDelegate.self) private var flow

    @StateObject private var router = MyUSRouter()
    @StateObject private var launch = MyUSLaunchStore()
    @StateObject private var session = MyUSSessionState()
    @StateObject private var orientation = MyUSOrientationManager()

    var body: some Scene {
        WindowGroup {
            MyUSEntryScreen()
                .environmentObject(router)
                .environmentObject(launch)
                .environmentObject(session)
                .environmentObject(orientation)
        }
    }
}
