import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var selectedEngine: EngineKind = .ollama
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Text("Custom Paths")
                    .font(.headline)

                Spacer(minLength: 16)

                HStack(spacing: 8) {
                    Button {
                        pickFolder()
                    } label: {
                        Label("Add Folder", systemImage: "folder.badge.plus")
                    }
                    .help("Pick a custom model folder in Finder.")

                    Button {
                        viewModel.save()
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    .help("Save the current configuration.")

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .buttonStyle(.borderless)
                    .help("Close settings.")
                }
            }
            .padding([.horizontal, .top])

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(EngineKind.allCases, id: \.self) { engine in
                        engineSection(for: engine)
                    }
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minWidth: 820, minHeight: 560)
    }

    private func engineSection(for engine: EngineKind) -> some View {
        let paths = filteredPaths(for: engine)
        return GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(engine.displayName)
                        .font(.headline)
                    Spacer()
                    Button {
                        selectedEngine = engine
                        pickFolder()
                    } label: {
                        Label("Add", systemImage: "folder.badge.plus")
                    }
                    .help("Pick a custom model folder for this engine.")
                }

                if paths.isEmpty {
                    Text("No custom paths.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(paths, id: \.self) { path in
                        HStack {
                            Text(path)
                                .textSelection(.enabled)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Button(role: .destructive) {
                                removePath(path, for: engine)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                            .help("Remove this custom path.")
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        } label: {
            EmptyView()
        }
    }

    private func filteredPaths(for engine: EngineKind) -> [String] {
        viewModel.customPaths(for: engine)
    }

    private func pickFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.showsHiddenFiles = true
        panel.prompt = "Choose"
        panel.message = "Choose a custom model folder for \(selectedEngine.displayName)."

        guard panel.runModal() == .OK, let url = panel.url else { return }
        var paths = viewModel.customPaths(for: selectedEngine)
        paths.append(url.path)
        paths = Array(Set(paths)).sorted()
        viewModel.setCustomPaths(paths, for: selectedEngine)
    }

    private func removePath(_ path: String, for engine: EngineKind) {
        let paths = viewModel.customPaths(for: engine).filter { $0 != path }
        viewModel.setCustomPaths(paths, for: engine)
    }
}
