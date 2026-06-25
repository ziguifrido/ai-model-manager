import SwiftUI

struct DeletionPreviewView: View {
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        let dirs = viewModel.pendingDeletionDirectories
        VStack(spacing: 16) {
            Text("Delete selected models?")
                .font(.title2)

            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(dirs.count) director\(dirs.count == 1 ? "y" : "ies") will be permanently deleted:")
                        .font(.headline)
                    Divider()
                    ForEach(dirs, id: \.path) { url in
                        Text(url.path)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
            }

            Text("Total space reclaimed: \(Formatting.byteCount(viewModel.selectedModelsSize))")
                .font(.subheadline)

            HStack {
                Button("Cancel", role: .cancel) { viewModel.cancelDeletion() }
                Button("Delete \(viewModel.selectedModelIDs.count) model(s)", role: .destructive) {
                    viewModel.executeDeletion()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 520, height: 400)
    }
}
