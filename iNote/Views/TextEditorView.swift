
import Foundation
import SwiftUI
import PencilKit



struct TextEditorView: UIViewRepresentable {
    @Binding var noteData: Data
    @Binding var textView: UITextView?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 18)
        textView.textColor = UIColor.label
        textView.delegate = context.coordinator
        textView.textContainerInset = UIEdgeInsets(top: 80, left: 12, bottom: 50, right: 12)
        
        loadInitialData(into: textView, context: context)
        
        DispatchQueue.main.async {
            self.textView = textView
        }
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let currentData = context.coordinator.currentData, currentData != noteData {
            loadInitialData(into: uiView, context: context)
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
        
        context.coordinator.currentData = noteData
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextEditorView
        var currentData: Data?

        init(_ parent: TextEditorView) {
            self.parent = parent
            self.currentData = parent.noteData
        }

        func textViewDidChange(_ textView: UITextView) {
            saveText(textView: textView)
        }
        
        private func saveText(textView: UITextView) {
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
    }
}
