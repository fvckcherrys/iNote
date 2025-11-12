import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var folder: Folder
    @Binding var selectedNote: Note?
    @State private var isShowingDeleteAlert = false
    @State private var noteToDelete: Note? = nil
    
    private var notes: [Note] {
        folder.notes.sorted { $0.creationDate > $1.creationDate }
    }
    
    var body: some View {
        List(selection: $selectedNote) {
            ForEach(notes) { note in
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(note.previewText)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(note.creationDate.formatted(date: .numeric, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                }
                .tag(note)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        noteToDelete = note
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(folder.name)
        .toolbar {
            ToolbarItem {
                Button(action: addNote) {
                    Label("New Note", systemImage: "square.and.pencil")
                }
            }
        }
        .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                    Button("Cancel", role: .cancel) { noteToDelete = nil }
                    Button("Delete", role: .destructive) {
                        commitDeleteNote()
                    }
                } message: {
                    Text("The note \"\(noteToDelete?.previewText ?? "")\" will be deleted.")
                }
    }
    
    private func addNote() {
        let newNote = Note(title: "", folder: folder)
        modelContext.insert(newNote)
        folder.notes.append(newNote)
        selectedNote = newNote
    }
    
    private func commitDeleteNote() {
            guard let note = noteToDelete else { return }
            
            if note == selectedNote {
                selectedNote = nil
            }
            modelContext.delete(note)
            noteToDelete = nil
        }
}
