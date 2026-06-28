import SwiftUI

@main
struct FacetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Window("Amethyst Facet", id: "facet") {
            ContentView()
        }
        .windowLevel(.floating)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        
    }
}
