import SwiftUI
import SwiftData

struct FolderListView: View {
    @Environment(\.modelContext) private var modelContext
       @Query(sort: \Folder.name) private var folders: [Folder]
       @Binding var selectedFolder: Folder?

       @State private var isShowingAddFolderAlert = false
       @State private var newFolderName = ""
       @State private var isShowingRenameAlert = false
       @State private var folderToRename: Folder? = nil
       @State private var renamedFolderName = ""
       @State private var isShowingDeleteAlert = false
       @State private var folderToDelete: Folder? = nil

       var body: some View {
           List(selection: $selectedFolder) {
               Section {
                   ForEach(folders) { folder in
                       HStack {
                           Image(systemName: "folder")
                           Text(folder.name)
                           Spacer()
                           Text("\(folder.notes.count)")
                               .foregroundColor(.secondary)
                       }
                       .tag(folder)
                       .swipeActions(edge: .trailing) {
                           Button(role: .destructive) {
                               folderToDelete = folder
                               isShowingDeleteAlert = true
                           } label: {
                               Label("Elimina", systemImage: "trash")
                           }
                           Button {
                               showRenameAlert(for: folder)
                           } label: {
                               Label("Rinomina", systemImage: "pencil")
                           }
                           .tint(.blue)
                       }
                   }
               } header: {
                   Text("Le mie Cartelle")
                       .font(.headline)
                       .foregroundColor(.secondary)
                       .textCase(nil)
               }
           }
           .toolbar {
               ToolbarItem(placement: .navigationBarTrailing) {
                   Button(action: {
                       isShowingAddFolderAlert = true
                   }) {
                       Label("Nuova Cartella", systemImage: "folder.badge.plus")
                   }
               }
           }
           .onAppear {
               if folders.isEmpty {
                   let defaultFolder = Folder(name: "Note")
                   modelContext.insert(defaultFolder)
                   selectedFolder = defaultFolder
               } else if selectedFolder == nil {
                   selectedFolder = folders.first
               }
           }
           .alert("Nuova Cartella", isPresented: $isShowingAddFolderAlert) {
               TextField("Nome", text: $newFolderName)
               Button("Annulla", role: .cancel) { newFolderName = "" }
               Button("Salva") {
                   commitAddFolder()
               }
           } message: {
               Text("Inserisci un nome per la nuova cartella.")
           }
           .alert("Rinomina Cartella", isPresented: $isShowingRenameAlert) {
               TextField("Nuovo nome", text: $renamedFolderName)
               Button("Annulla", role: .cancel) { resetRenameState() }
               Button("Salva") {
                   commitRename()
               }
           } message: {
               Text("Inserisci un nuovo nome per la cartella '\(folderToRename?.name ?? "")'.")
           }
           .alert("Sei sicuro?", isPresented: $isShowingDeleteAlert) {
                       Button("Annulla", role: .cancel) { folderToDelete = nil }
                       Button("Elimina", role: .destructive) {
                           commitDelete()
                       }
                   } message: {
                       Text("Eliminando la cartella \"\(folderToDelete?.name ?? "")\" verranno eliminate anche tutte le note al suo interno.")
                   }
       }
    
       private func commitAddFolder() {
           let trimmedName = newFolderName.trimmingCharacters(in: .whitespaces)
           guard !trimmedName.isEmpty else { return }
           
           let newFolder = Folder(name: trimmedName)
           modelContext.insert(newFolder)
           selectedFolder = newFolder
           
           newFolderName = ""
       }
       
       private func showRenameAlert(for folder: Folder) {
           folderToRename = folder
           renamedFolderName = folder.name
           isShowingRenameAlert = true
       }

       private func commitRename() {
           guard let folder = folderToRename else { return }
           let trimmedName = renamedFolderName.trimmingCharacters(in: .whitespaces)
           guard !trimmedName.isEmpty else { return }
           
           folder.name = trimmedName
           resetRenameState()
       }
       
       private func resetRenameState() {
           folderToRename = nil
           renamedFolderName = ""
       }
    
    private func commitDelete() {
            guard let folder = folderToDelete else { return }
            
            if folder == selectedFolder {
                selectedFolder = nil
            }
            modelContext.delete(folder)
            folderToDelete = nil
        }
}
