//
//  iNoteApp.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import SwiftUI
import SwiftData

@main
struct iNoteApp: App {

    let container: ModelContainer
        
        init() {
            do {
                container = try ModelContainer(for: Folder.self, Note.self)
            } catch {
                fatalError("Impossibile inizializzare il ModelContainer: \(error)")
            }
        }

        var body: some Scene {
            WindowGroup {
                MainView()
            }
            .modelContainer(container)
        }
}
