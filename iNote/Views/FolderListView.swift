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
                               Label("Delete", systemImage: "trash")
                           }
                           Button {
                               showRenameAlert(for: folder)
                           } label: {
                               Label("Rename", systemImage: "pencil")
                           }
                           .tint(.blue)
                       }
                   }
               } header: {
                   Text("My Folders")
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
                       Label("New Folder", systemImage: "folder.badge.plus")
                   }
               }
           }
           .onAppear {
               if folders.isEmpty {
                   let defaultFolder = Folder(name: "Notes")
                   modelContext.insert(defaultFolder)
                   selectedFolder = defaultFolder
               } else if selectedFolder == nil {
                   selectedFolder = folders.first
               }
           }
           .alert("New Folder", isPresented: $isShowingAddFolderAlert) {
               TextField("Name", text: $newFolderName)
               Button("Cancel", role: .cancel) { newFolderName = "" }
               Button("Save") {
                   commitAddFolder()
               }
           } message: {
               Text("Insert a name for the new folder.")
           }
           .alert("Rename Folder", isPresented: $isShowingRenameAlert) {
               TextField("New name", text: $renamedFolderName)
               Button("Cancel", role: .cancel) { resetRenameState() }
               Button("Save") {
                   commitRename()
               }
           } message: {
               Text("Insert a new name for the folder '\(folderToRename?.name ?? "")'.")
           }
           .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                       Button("Cancel", role: .cancel) { folderToDelete = nil }
                       Button("Delete", role: .destructive) {
                           commitDelete()
                       }
                   } message: {
                       Text("Deleting the folder \"\(folderToDelete?.name ?? "")\" all the notes inside will be deleted.")
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
