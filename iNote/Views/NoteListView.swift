import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var modelContext
     @Bindable var folder: Folder
     @Binding var selectedNote: Note?
     
     private var notes: [Note] {
         folder.notes.sorted { $0.creationDate > $1.creationDate }
     }

     var body: some View {
         List(selection: $selectedNote) {
             ForEach(notes) { note in
                 VStack(alignment: .leading, spacing: 4) {
                     // Questo ora mostrerà il titolo (o il fallback)
                     Text(note.previewText)
                         .font(.headline)
                         .lineLimit(1)
                     Text(note.creationDate.formatted(date: .numeric, time: .shortened))
                         .font(.caption)
                         .foregroundStyle(.secondary)
                 }
                 .tag(note)
             }
             .onDelete(perform: deleteNote)
         }
         .navigationTitle(folder.name)
         .toolbar {
             ToolbarItem {
                 Button(action: addNote) {
                     Label("Nuova Nota", systemImage: "square.and.pencil")
                 }
             }
         }
     }

     private func addNote() {
         // --- *** MODIFICA *** ---
         // Crea la nota con un titolo vuoto
         let newNote = Note(title: "", folder: folder)
         modelContext.insert(newNote)
         folder.notes.append(newNote)
         selectedNote = newNote
     }

     private func deleteNote(at offsets: IndexSet) {
         let notesToDelete = offsets.map { notes[$0] }
         for note in notesToDelete {
             modelContext.delete(note)
         }
         if let selected = selectedNote, notesToDelete.contains(selected) {
             selectedNote = nil
         }
     }
}
