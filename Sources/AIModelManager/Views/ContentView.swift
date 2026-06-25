import SwiftUI

public struct ContentView: View {
    @StateObject public var viewModel: LibraryViewModel
    @ObservedObject private var settingsViewModel: SettingsViewModel
    @AppStorage("sidebarWidth") private var sidebarWidth: Double = 240
    @AppStorage("detailWidth") private var detailWidth: Double = 360
    @AppStorage("showDetailPane") private var showDetailPane: Bool = false
    @State private var showSettings: Bool = false

    public init(viewModel: LibraryViewModel, settingsViewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _settingsViewModel = ObservedObject(wrappedValue: settingsViewModel)
    }

    public var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let sidebar = CGFloat(sidebarWidth)
            let detail = CGFloat(detailWidth)
            let availableMainWidth = max(320, totalWidth - sidebar - (showDetailPane && viewModel.selectedModel != nil ? detail : 0) - dividerCount * dividerWidth)
            HStack(spacing: 0) {
                sidebarView
                    .frame(width: sidebar)

                splitDivider { delta in
                    sidebarWidth = clamped(sidebarWidth + Double(delta), min: 180, max: Double(min(420, totalWidth - 500)))
                }

                ModelTableView(viewModel: viewModel) { selection in
                    viewModel.selectedModelIDs = Set(selection)
                    viewModel.selectedModel = viewModel.models.first(where: { selection.contains($0.id) })
                    Task { await viewModel.prepareDeletion() }
                }
                    .frame(width: availableMainWidth, alignment: .leading)

                if showDetailPane, let model = viewModel.selectedModel {
                    splitDivider { delta in
                        detailWidth = clamped(detailWidth - Double(delta), min: 260, max: Double(min(560, totalWidth - 500)))
                    }

                    ModelDetailView(model: model)
                        .frame(width: detail)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
        }
        .onChange(of: viewModel.selectedModelIDs) { _, newValue in
            viewModel.selectedModel = viewModel.models.first(where: { newValue.contains($0.id) })
        }
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search models", text: $viewModel.searchText)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: 320)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(minWidth: 280)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            ToolbarItemGroup(placement: .automatic) {
                Button {
                    viewModel.openSelectedInFinder()
                } label: {
                    Image(systemName: "folder")
                }
                .help("Open the selected model folder or file in Finder.")
                .disabled(viewModel.selectedModelIDs.isEmpty)

                Button {
                    showDetailPane.toggle()
                } label: {
                    Image(systemName: showDetailPane ? "sidebar.right" : "sidebar.left")
                }
                .help(showDetailPane ? "Hide the detail pane." : "Show the detail pane.")

                Button {
                    viewModel.scanNow()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Scan the configured locations again.")

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Configure custom model paths per engine.")

                Button(role: .destructive) {
                    Task { await viewModel.prepareDeletion() }
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete the selected model or models.")
                .disabled(viewModel.selectedModelIDs.isEmpty)
            }
        }
        .sheet(isPresented: $viewModel.showDeletionPreview) {
            DeletionPreviewView(viewModel: viewModel)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(viewModel: settingsViewModel)
        }
        .task { if viewModel.inventoryStore.models.isEmpty { viewModel.scanNow() } }
    }

    private var sidebarView: some View {
        VStack(spacing: 0) {
            List(selection: $viewModel.selectedEngine) {
                Text("All").tag(String?.none)
                ForEach(viewModel.engines, id: \.self) { engine in
                    Text(engine).tag(String?.some(engine))
                }
            }
        }
    }

    private var dividerCount: CGFloat {
        (showDetailPane && viewModel.selectedModel != nil) ? 2 : 1
    }

    private let dividerWidth: CGFloat = 1

    @ViewBuilder
    private func splitDivider(onDrag: @escaping (CGFloat) -> Void) -> some View {
        Rectangle()
            .fill(Color(nsColor: .separatorColor))
            .frame(width: dividerWidth)
            .gesture(
                DragGesture(minimumDistance: 1)
                    .onChanged { value in onDrag(value.translation.width) }
            )
    }

    private func clamped(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}

private struct DeletionPreviewView: View {
    @ObservedObject var viewModel: LibraryViewModel

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
