import SwiftUI

struct ContentView: View {
    @State private var viewModel: LibraryViewModel
    @State private var showSettings = false

    init(container: AppContainer) {
        _viewModel = State(initialValue: LibraryViewModel(
            scannerService: container.scannerService,
            inventoryStore: container.inventoryStore
        ))
    }

    var body: some View {
        @Bindable var vm = viewModel

        NavigationSplitView {
            SidebarView(selectedEngine: $vm.selectedEngine, engines: vm.engines)
        } content: {
            ModelBrowserView(viewModel: vm)
                .searchable(text: $vm.searchText, prompt: "Search models")
        } detail: {
            if let model = vm.selectedModels.first {
                ModelInspectorView(model: model)
            } else {
                ContentUnavailableView("No model selected", systemImage: "internaldrive")
            }
        }
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
        .task {
            if vm.inventoryStore.models.isEmpty { vm.scanNow() }
        }
    }
}
