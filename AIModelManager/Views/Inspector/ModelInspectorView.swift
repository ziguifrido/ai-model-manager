import SwiftUI

struct ModelInspectorView: View {
    let model: AIModel

    var body: some View {
        Form {
            Text(model.name)
                .font(.title2)
                .textSelection(.enabled)
            LabeledContent("Engine", value: model.engine)
            LabeledContent("Path", value: model.location.path)
            LabeledContent("Size", value: Formatting.byteCount(model.size))
            LabeledContent("Files", value: "\(model.fileCount)")
            if let ext = model.primaryExtension {
                LabeledContent("Extension", value: ext)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
