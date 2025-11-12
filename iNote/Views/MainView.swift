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
                    Text("Select a folder")
                        .foregroundColor(.secondary)
                }
            } detail: {
                if let note = selectedNote {
                    NoteEditorView(note: note)
                } else {
                    Text("Select a note or create a new one")
                        .foregroundColor(.secondary)
                }
            }
        }
}
