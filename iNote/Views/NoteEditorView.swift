//
//  NoteEditorView.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import SwiftUI

struct NoteEditorView: View {
    @Bindable var note: Note
        @State private var isDrawing: Bool = false

        var body: some View {
            ZStack(alignment: .top) {
                RichTextEditorView(noteData: $note.contentData, isDrawing: $isDrawing)
                    .ignoresSafeArea(.container)

                TextField("Titolo", text: $note.title, axis: .vertical)
                    .font(.largeTitle.weight(.bold))
                    .padding(.horizontal)
                    .padding(.top, 8)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        isDrawing.toggle()
                    } label: {
                        Image(systemName: isDrawing ? "keyboard" : "pencil.tip.crop.circle")
                    }
                }
            }
        }
}
