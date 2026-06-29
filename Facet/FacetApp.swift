import SwiftUI

@main
struct FacetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Window("Amethyst Facet", id: "facet") {
            ContentView()
                .background(WindowConfigurator())
        }
        .windowLevel(.floating)
        .handlesExternalEvents(matching: ["open"])
    }
}
/*
var facetWindow = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 500, height: 300), styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        facetWindow.contentView = NSHostingView(rootView: ContentView())
        facetWindow.level = .floating
        facetWindow.collectionBehavior = .canJoinAllSpaces
        facetWindow.title = "Amethyst Facet"
        facetWindow.setIsVisible(true)
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        facetWindow.setIsVisible(true)
        facetWindow.makeKeyAndOrderFront(nil)
    }
}
*/

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = sender.windows.first(where: { $0.isMiniaturized }) {
            window.setIsMiniaturized(false)
            return false
        }
        if !flag {
            let url = URL(string: "amethyst-facet://open")!
            NSWorkspace.shared.open(url)
            return true
        }
        return false
    }
}
