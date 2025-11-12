//
//  NoteEditorView.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import SwiftUI
import PencilKit

struct NoteEditorView: View {
    @Bindable var note: Note
    @State private var isDrawing: Bool = false
    @State private var editorTextView: UITextView? = nil
    @State private var currentDrawing: PKDrawing = PKDrawing()
    @State private var drawingBounds: CGRect = .zero

    var body: some View {
        ZStack(alignment: .top) {
            
            TextEditorView(noteData: $note.contentData, textView: $editorTextView)
                .ignoresSafeArea(.container, edges: .bottom)

            DrawingCanvasView(isDrawing: $isDrawing, currentDrawing: $currentDrawing, drawingBounds: $drawingBounds)
                .allowsHitTesting(isDrawing)
                .ignoresSafeArea(.container)
            
            TextField("Title", text: $note.title, axis: .vertical)
                .font(.largeTitle.weight(.bold))
                .padding(.horizontal)
                .padding(.top, 8)
                .allowsHitTesting(!isDrawing)
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
        .onChange(of: isDrawing) { _, newValue in
            if !newValue {
                commitDrawing()
            }
        }
    }
    
    private func commitDrawing() {
        
        guard !currentDrawing.bounds.isEmpty, let textView = editorTextView else { return }
        
        print("DEBUG: Convalida disegno...")

        let image = currentDrawing.image(from: drawingBounds, scale: 2.0)
        let textAttachment = NSTextAttachment()
        textAttachment.image = image
        
        let availableWidth = textView.textContainer.size.width - 10
        let drawingSize = drawingBounds.size
        
        guard availableWidth > 0, drawingSize.width > 0 else {
            print("DEBUG: commitDrawing fallito, larghezza non valida.")
            return
        }
        
        let finalWidth = min(drawingSize.width, availableWidth)
        let aspectRatio = drawingSize.height / drawingSize.width
        let finalHeight = finalWidth * aspectRatio
        
        textAttachment.bounds = CGRect(x: 0, y: 0, width: finalWidth, height: finalHeight)

        let currentTypingAttributes = textView.typingAttributes
        let attributedString = NSAttributedString(attachment: textAttachment)
        let lineBreak = NSAttributedString(string: "\n", attributes: currentTypingAttributes)
        let insertionRange = textView.selectedRange
        let mutableText = textView.attributedText.mutableCopy() as! NSMutableAttributedString

        mutableText.insert(lineBreak, at: insertionRange.location)
        mutableText.insert(attributedString, at: insertionRange.location + lineBreak.length)
        mutableText.insert(lineBreak, at: insertionRange.location + lineBreak.length + attributedString.length)
        
        let newCursorLocation = insertionRange.location + (lineBreak.length * 2) + attributedString.length
        
        textView.attributedText = mutableText
        textView.selectedRange = NSRange(location: newCursorLocation, length: 0)
        
        textView.typingAttributes = currentTypingAttributes
        
        if let data = try? textView.attributedText.data(from: NSRange(0..<textView.attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]) {
            note.contentData = data
        }
        
        currentDrawing = PKDrawing()
    }
}
