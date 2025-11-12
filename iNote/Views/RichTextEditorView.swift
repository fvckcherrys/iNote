//
//  RichTextEditorView.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import SwiftUI
import SwiftData
import PencilKit

struct RichTextEditorView: UIViewRepresentable {
    @Binding var noteData: Data
        @Binding var isDrawing: Bool

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIView(context: Context) -> UIView {
            let textView = UITextView()
            textView.font = .systemFont(ofSize: 18)
            textView.textColor = UIColor.label
            textView.delegate = context.coordinator
            
            loadInitialData(into: textView, context: context)
            
            let canvasView = PKCanvasView()
            canvasView.isOpaque = false
            canvasView.backgroundColor = .clear
            canvasView.drawingPolicy = .anyInput
            
            let containerView = UIView()
            containerView.addSubview(textView)
            containerView.addSubview(canvasView)
            
            textView.translatesAutoresizingMaskIntoConstraints = false
            canvasView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textView.topAnchor.constraint(equalTo: containerView.topAnchor),
                textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                
                canvasView.topAnchor.constraint(equalTo: containerView.topAnchor),
                canvasView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                canvasView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                canvasView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            ])
            
            context.coordinator.textView = textView
            context.coordinator.canvasView = canvasView

            textView.textContainerInset = UIEdgeInsets(top: 80, left: 12, bottom: 50, right: 12)
            
            canvasView.isUserInteractionEnabled = isDrawing
            
            return containerView
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            
            if context.coordinator.toolPicker == nil, let window = uiView.window {
                setupToolPicker(for: context, window: window)
            }
            
            context.coordinator.setIsDrawing(isDrawing)
            
            if let currentData = context.coordinator.currentData, currentData != noteData {
                if let textView = context.coordinator.textView {
                    loadInitialData(into: textView, context: context)
                }
            }
        }

        private func loadInitialData(into textView: UITextView, context: Context) {
            if !noteData.isEmpty {
                if let attributedString = try? NSAttributedString(data: noteData,
                                                                  options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                                                  documentAttributes: nil) {
                    textView.attributedText = attributedString
                }
            } else {
                textView.attributedText = NSAttributedString(string: "")
            }
            
            if textView.attributedText.length == 0 {
                textView.textColor = UIColor.label
                textView.font = .systemFont(ofSize: 18)
            }
            
            DispatchQueue.main.async {
                let data = (try? textView.attributedText.data(from: NSRange(0..<textView.attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])) ?? Data()
                self.noteData = data
                context.coordinator.currentData = data
            }
        }
        
        private func setupToolPicker(for context: Context, window: UIWindow) {
            guard let canvasView = context.coordinator.canvasView else { return }

            if let toolPicker = PKToolPicker.shared(for: window) {
                print("DEBUG: PKToolPicker inizializzato per la UIWindow.")
                context.coordinator.toolPicker = toolPicker
                toolPicker.addObserver(canvasView)
                toolPicker.addObserver(context.coordinator)
                
                canvasView.isUserInteractionEnabled = self.isDrawing
                
                if self.isDrawing {
                    canvasView.becomeFirstResponder()
                }
            } else {
                print("Errore: Impossibile creare PKToolPicker per la window.")
            }
        }
    
        class Coordinator: NSObject, UITextViewDelegate, PKToolPickerObserver {
            var parent: RichTextEditorView
            
            weak var textView: UITextView?
            weak var canvasView: PKCanvasView?
            weak var toolPicker: PKToolPicker?
            
            var currentData: Data?

            init(_ parent: RichTextEditorView) {
                self.parent = parent
                self.currentData = parent.noteData
            }

            func textViewDidChange(_ textView: UITextView) {
                saveText()
            }
            
            private func saveText() {
                guard let textView = textView else { return }
                
                do {
                    let data = try textView.attributedText.data(
                        from: NSRange(location: 0, length: textView.attributedText.length),
                        documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
                    )
                    
                    self.parent.noteData = data
                    self.currentData = data
                } catch {
                    print("Errore durante il salvataggio dei dati RTFD: \(error)")
                }
            }
            
            func setIsDrawing(_ isDrawing: Bool) {
                guard let textView = textView, let canvasView = canvasView else { return }
                
                guard isDrawing != canvasView.isUserInteractionEnabled else { return }
                
                canvasView.isUserInteractionEnabled = isDrawing

                if isDrawing {
                    print("DEBUG: Passaggio a modalità disegno (canvas.becomeFirstResponder)")
                    canvasView.becomeFirstResponder()
                } else {
                    print("DEBUG: Passaggio a modalità testo (textView.becomeFirstResponder)")
                    textView.becomeFirstResponder()

                    DispatchQueue.main.async {
                        self.commitDrawing()
                    }
                }
            }
            
            @objc private func commitDrawing() {
                guard let textView = self.textView, let canvasView = self.canvasView else {
                    print("DEBUG: commitDrawing() fallito, textView o canvasView nil")
                    return
                }
                
                let drawing = canvasView.drawing
                
                guard !drawing.bounds.isEmpty else {
                    print("DEBUG: commitDrawing() chiamato ma drawing.bounds è vuoto.")
                    return
                }
                
                print("DEBUG: commitDrawing() in corso...")

                let image = drawing.image(from: drawing.bounds, scale: 2.0)
                
                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                
                // Usiamo la larghezza del text container, non della vista,
                // per un calcolo più preciso
                let availableWidth = textView.textContainer.size.width - 10
                let drawingSize = drawing.bounds.size
                
                guard availableWidth > 0, drawingSize.width > 0 else {
                    print("DEBUG: commitDrawing() fallito, larghezza non valida. availableWidth: \(availableWidth), drawingSize.width: \(drawingSize.width)")
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
                
                saveText()

                canvasView.drawing = PKDrawing()
            }
            
            func toolPickerIsVisibleDidChange(_ toolPicker: PKToolPicker) {
                print("DEBUG: toolPickerIsVisibleDidChange: \(toolPicker.isVisible)")
                if !toolPicker.isVisible {
                    if self.parent.isDrawing {
                        self.parent.isDrawing = false
                    }
                }
            }
        }
}
