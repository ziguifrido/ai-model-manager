import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .appInfo) {
            Button("About AI Model Manager") {
                NSApplication.shared.orderFrontStandardAboutPanel(
                    options: [.applicationName: "AI Model Manager",
                              .version: appVersion]
                )
            }
        }
    }
}
