//
//  DrawingCanvasView.swift
//  iNote
//
//  Created by Gianluca Auriemma on 12/11/25.
//

import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var isDrawing: Bool
    @Binding var currentDrawing: PKDrawing
    @Binding var drawingBounds: CGRect
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        canvasView.drawingPolicy = .anyInput
        canvasView.drawing = currentDrawing
        canvasView.delegate = context.coordinator
        context.coordinator.canvasView = canvasView
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if context.coordinator.toolPicker == nil, let window = uiView.window {
            setupToolPicker(for: context, window: window)
        }
        
        if isDrawing != uiView.isUserInteractionEnabled {
            uiView.isUserInteractionEnabled = isDrawing
            if isDrawing {
                uiView.becomeFirstResponder()
            } else {
                uiView.resignFirstResponder()
            }
        }

        if uiView.drawing != currentDrawing {
            uiView.drawing = currentDrawing
        }
    }
    
    private func setupToolPicker(for context: Context, window: UIWindow) {
        guard let canvasView = context.coordinator.canvasView else { return }
        
        if let toolPicker = PKToolPicker.shared(for: window) {
            print("DEBUG: PKToolPicker inizializzato per DrawingCanvasView.")
            context.coordinator.toolPicker = toolPicker
            toolPicker.addObserver(canvasView)
            toolPicker.addObserver(context.coordinator)
            toolPicker.setVisible(isDrawing, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        } else {
            print("Errore: Impossibile creare PKToolPicker per la window.")
        }
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
        var parent: DrawingCanvasView
        weak var toolPicker: PKToolPicker?
        weak var canvasView: PKCanvasView?
        
        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.currentDrawing = canvasView.drawing
            parent.drawingBounds = canvasView.drawing.bounds
        }
        
        func toolPickerIsVisibleDidChange(_ toolPicker: PKToolPicker) {
            if !toolPicker.isVisible && parent.isDrawing {
                parent.isDrawing = false
            }
        }
    }
}
