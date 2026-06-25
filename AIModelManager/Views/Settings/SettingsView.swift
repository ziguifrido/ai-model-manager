import SwiftUI
import AppKit

struct SettingsView: View {
    @Environment(AppContainer.self) private var container
    @State private var selectedEngine: EngineKind = .ollama
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = container.configurationStore

        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Custom Paths")
                    .font(.headline)
                Spacer(minLength: 16)
                HStack(spacing: 8) {
                    Button { pickFolder() } label: {
                        Label("Add Folder", systemImage: "folder.badge.plus")
                    }
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding([.horizontal, .top])

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(EngineKind.allCases, id: \.self) { engine in
                        engineSection(for: engine, store: store)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 820, minHeight: 560)
    }

    private func engineSection(for engine: EngineKind, store: ConfigurationStore) -> some View {
        let paths = store.config.engines[engine]?.customPaths ?? []
        return GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(engine.displayName).font(.headline)
                    Spacer()
                    Button {
                        selectedEngine = engine
                        pickFolder(store: store)
                    } label: {
                        Label("Add", systemImage: "folder.badge.plus")
                    }
                }

                if paths.isEmpty {
                    Text("No custom paths.").foregroundStyle(.secondary)
                } else {
                    ForEach(paths, id: \.self) { path in
                        HStack {
                            Text(path)
                                .textSelection(.enabled)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(role: .destructive) {
                                var updated = store.config
                                updated.engines[engine]?.customPaths.removeAll { $0 == path }
                                store.save(updated)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func pickFolder(store: ConfigurationStore? = nil) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.showsHiddenFiles = true
        panel.prompt = "Choose"
        panel.message = "Choose a custom model folder for \(selectedEngine.displayName)."
        guard panel.runModal() == .OK, let url = panel.url else { return }
        let path = url.path

        var updated = container.configurationStore.config
        var engineConfig = updated.engines[selectedEngine] ?? EngineScanConfiguration()
        engineConfig.customPaths.append(path)
        engineConfig.customPaths = Array(Set(engineConfig.customPaths)).sorted()
        updated.engines[selectedEngine] = engineConfig
        container.configurationStore.save(updated)
    }
}
