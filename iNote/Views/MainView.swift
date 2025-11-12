import SwiftUI
import SwiftData

struct MainView: View {
    @State private var selectedFolder: Folder?
        @State private var selectedNote: Note?

        var body: some View {
            NavigationSplitView {
                // --- COLONNA 1: Sidebar Cartelle ---
                FolderListView(selectedFolder: $selectedFolder)
            } content: {
                // --- COLONNA 2: Lista Note ---
                if let folder = selectedFolder {
                    NoteListView(folder: folder, selectedNote: $selectedNote)
                } else {
                    Text("Seleziona una cartella")
                        .foregroundColor(.secondary)
                }
            } detail: {
                // --- COLONNA 3: Editor Nota ---
                if let note = selectedNote {
                    NoteEditorView(note: note)
                } else {
                    Text("Seleziona una nota o creane una nuova")
                        .foregroundColor(.secondary)
                }
            }
        }
}
