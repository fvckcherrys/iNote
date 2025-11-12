//
//  FolderModel.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import Foundation
import SwiftData

@Model
class Folder {
    public var id: UUID
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \Note.folder)
    var notes: [Note] = []

    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
