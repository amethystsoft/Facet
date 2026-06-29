import SwiftUI
import AppKit

struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.collectionBehavior = [
                    .canJoinAllSpaces,
                        .fullScreenAuxiliary
                ]
                
                // Optional: Elevate level if .floating is not high enough
                window.level = .statusBar
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
