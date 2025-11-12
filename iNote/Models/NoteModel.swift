//
//  NoteModel.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import Foundation
import SwiftData
import UIKit

@Model
class Note {
    public var id: UUID
    var title: String
    
    // Questo ora è solo il *corpo* della nota
    var contentData: Data
    var creationDate: Date
    
    var folder: Folder?

    // --- *** MODIFICA *** ---
    // Aggiornato init
    init(title: String = "", contentData: Data = Data(), creationDate: Date = Date(), folder: Folder? = nil) {
        self.id = UUID()
        self.title = title
        self.contentData = contentData
        self.creationDate = creationDate
        self.folder = folder
    }
    
    // --- *** MODIFICA *** ---
    // Logica di previewText aggiornata
    var previewText: String {
        // 1. Se il titolo esiste, usalo.
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }
        
        // 2. Se il titolo è vuoto, prova a usare la prima riga del corpo
        if !contentData.isEmpty,
           let attributedString = try? NSAttributedString(data: contentData,
                                                         options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                                         documentAttributes: nil) {
            
            let plainText = attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Prendi la prima riga non vuota
            if let firstLine = plainText.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) {
                return firstLine
            }
            
            // 3. Se il testo è vuoto ma c'è un disegno
            var hasAttachment = false
            attributedString.enumerateAttribute(.attachment, in: NSRange(0..<attributedString.length)) { value, range, stop in
                if value != nil {
                    hasAttachment = true
                    stop.pointee = true
                }
            }
            if hasAttachment { return "Nota con disegno" }
        }
        
        // 4. Fallback finale
        return "Nuova nota"
    }
}
