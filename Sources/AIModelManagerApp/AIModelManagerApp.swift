import SwiftUI
import AppKit
import AIModelManager

@main
struct AIModelManagerAppMain: App {
    @StateObject private var container = AppContainer.live()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: container.makeLibraryViewModel(), settingsViewModel: container.makeSettingsViewModel())
        }
        .defaultSize(width: 1440, height: 900)
    }

    init() {
        DispatchQueue.main.async {
            NSApplication.shared.windows.first?.title = "My AI Models"
        }
    }
}
