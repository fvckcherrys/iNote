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
    var contentData: Data
    var creationDate: Date
    
    var folder: Folder?

    init(title: String = "", contentData: Data = Data(), creationDate: Date = Date(), folder: Folder? = nil) {
        self.id = UUID()
        self.title = title
        self.contentData = contentData
        self.creationDate = creationDate
        self.folder = folder
    }

    var previewText: String {
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return title
        }

        if !contentData.isEmpty,
           let attributedString = try? NSAttributedString(data: contentData,
                                                         options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                                         documentAttributes: nil) {
            
            let plainText = attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
            if let firstLine = plainText.components(separatedBy: .newlines).first(where: { !$0.isEmpty }) {
                return firstLine
            }
            var hasAttachment = false
            attributedString.enumerateAttribute(.attachment, in: NSRange(0..<attributedString.length)) { value, range, stop in
                if value != nil {
                    hasAttachment = true
                    stop.pointee = true
                }
            }
            if hasAttachment { return "Nota con disegno" }
        }
        return "Nuova nota"
    }
}
