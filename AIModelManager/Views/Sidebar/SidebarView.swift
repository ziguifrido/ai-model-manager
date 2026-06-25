import SwiftUI

struct SidebarView: View {
    @Binding var selectedEngine: String
    let engines: [String]

    var body: some View {
        List(selection: $selectedEngine) {
            Text("All").tag("")
            ForEach(engines, id: \.self) { engine in
                Text(engine).tag(engine)
            }
        }
        .listStyle(.sidebar)
    }
}
