import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
        @Query(sort: \Folder.name) private var folders: [Folder]
        @Binding var selectedFolder: Folder?

        var body: some View {
            List(selection: $selectedFolder) {
                Section("Le mie Cartelle") {
                    ForEach(folders) { folder in
                        HStack {
                            Image(systemName: "folder")
                            Text(folder.name)
                            Spacer()
                            // Mostra il conteggio delle note
                            Text("\(folder.notes.count)")
                                .foregroundColor(.secondary)
                        }
                        .tag(folder) // Necessario per la selezione
                    }
                    .onDelete(perform: deleteFolder)
                }
            }
            .navigationTitle("Cartelle")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: addFolder) {
                        Label("Nuova Cartella", systemImage: "folder.badge.plus")
                    }
                }
            }
            .onAppear {
                // Gestione iniziale: crea una cartella se non ne esistono
                if folders.isEmpty {
                    let defaultFolder = Folder(name: "Note")
                    modelContext.insert(defaultFolder)
                    selectedFolder = defaultFolder
                } else if selectedFolder == nil {
                    // Seleziona la prima cartella all'avvio
                    selectedFolder = folders.first
                }
            }
        }

        private func addFolder() {
            // Puoi chiedere il nome all'utente, per ora è fisso
            let newFolder = Folder(name: "Nuova Cartella")
            modelContext.insert(newFolder)
            selectedFolder = newFolder
        }

        private func deleteFolder(at offsets: IndexSet) {
            for index in offsets {
                let folder = folders[index]
                modelContext.delete(folder)
            }
        }
}
