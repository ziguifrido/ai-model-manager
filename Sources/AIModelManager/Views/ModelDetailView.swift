import SwiftUI

struct ModelDetailView: View {
    let model: AIModel?

    var body: some View {
        Group {
            if let model {
                Form {
                    Text(model.name)
                    LabeledContent("Engine", value: model.engine)
                    LabeledContent("Path", value: model.location.path)
                    LabeledContent("Size", value: Formatting.byteCount(model.size))
                    LabeledContent("Files", value: "\(model.fileCount)")
                }
                .padding()
            } else {
                ContentUnavailableView("No model selected", systemImage: "internaldrive")
            }
        }
    }
}
