import SwiftUI

struct ContentView: View {
    @State private var viewModel: LibraryViewModel
    @State private var showSettings = false

    init(container: AppContainer) {
        _viewModel = State(initialValue: LibraryViewModel(
            scannerService: container.scannerService,
            inventoryStore: container.inventoryStore,
            configurationStore: container.configurationStore
        ))
    }

    var body: some View {
        @Bindable var vm = viewModel

        splitView(using: vm)
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup {
                Button {
                    vm.openSelectedInFinder()
                } label: {
                    Image(systemName: "folder")
                }
                .help("Open in Finder")
                .disabled(vm.selectedModelIDs.isEmpty)

                Button {
                    vm.scanNow()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Scan configured locations")

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .help("Settings")

                Button(role: .destructive) {
                    Task { await vm.prepareDeletion() }
                } label: {
                    Image(systemName: "trash")
                }
                .help("Delete selected models")
                .disabled(vm.selectedModelIDs.isEmpty)
            }
        }
        .sheet(isPresented: $vm.showDeletionPreview) {
            DeletionPreviewView(viewModel: vm)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task { if vm.inventoryStore.models.isEmpty { vm.scanNow() } }
    }

    @ViewBuilder
    private func splitView(using vm: LibraryViewModel) -> some View {
        let browser = ModelBrowserView(viewModel: vm)
            .searchable(text: $viewModel.searchText, prompt: "Search models")

        if let model = vm.selectedModels.first {
            NavigationSplitView {
                SidebarView(selectedEngine: $viewModel.selectedEngine, engines: vm.engines)
            } content: {
                browser
            } detail: {
                ModelInspectorView(model: model)
                    .navigationSplitViewColumnWidth(min: 280, ideal: 340, max: 420)
            }
        } else {
            NavigationSplitView {
                SidebarView(selectedEngine: $viewModel.selectedEngine, engines: vm.engines)
            } detail: {
                browser
            }
        }
    }
}
