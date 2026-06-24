import SwiftUI

@main
struct OtsariaReaderApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootSplitView()
                .environmentObject(container)
                .environment(\.layoutDirection, .rightToLeft)
                .task {
                    await container.restoreDatabaseIfPossible()
                }
        }
    }
}
