import SwiftUI

struct ModelBrowserView: View {
    @Bindable var viewModel: LibraryViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(ModelSortOption.allCases) { option in
                        Text(option.rawValue.capitalized).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()

            Table(viewModel.models, selection: $viewModel.selectedModelIDs) {
                TableColumn("Name", value: \.name)
                TableColumn("Engine", value: \.engine)
                TableColumn("Size") { Text(Formatting.byteCount($0.size)) }
                TableColumn("Path") { Text($0.location.path).lineLimit(1) }
            }
            .contextMenu(forSelectionType: UUID.self) { selection in
                if let model = viewModel.models.first(where: { selection.contains($0.id) }) {
                    Button {
                        viewModel.openInFinder(model)
                    } label: {
                        Label("Show in Finder", systemImage: "folder")
                    }
                    Button(role: .destructive) {
                        Task { await viewModel.prepareDeletion() }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}
