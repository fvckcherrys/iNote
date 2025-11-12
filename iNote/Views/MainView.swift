import SwiftUI
import SwiftData

struct MainView: View {
    @State private var selectedFolder: Folder?
        @State private var selectedNote: Note?

        var body: some View {
            NavigationSplitView {
                FolderListView(selectedFolder: $selectedFolder)
            } content: {
                if let folder = selectedFolder {
                    NoteListView(folder: folder, selectedNote: $selectedNote)
                } else {
                    Text("Seleziona una cartella")
                        .foregroundColor(.secondary)
                }
            } detail: {
                if let note = selectedNote {
                    NoteEditorView(note: note)
                } else {
                    Text("Seleziona una nota o creane una nuova")
                        .foregroundColor(.secondary)
                }
            }
        }
}
