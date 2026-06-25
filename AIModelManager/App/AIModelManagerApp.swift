import SwiftUI

@main
struct AIModelManagerApp: App {
    @State private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
                .environment(container)
        }
        .defaultSize(width: 1440, height: 900)
        .commands { AppCommands() }
        .windowResizability(.contentMinSize)
    }
}
