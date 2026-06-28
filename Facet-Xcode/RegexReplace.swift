//
//  SourceEditorCommand.swift
//  Facet-Xcode
//
//  Created by Mia Koring on 28.06.26.
//

import Foundation
import AppKit
import XcodeKit

class RegexReplace: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let fileContents = invocation.buffer.completeBuffer
        
        // 2. Save to Shared App Group
        let sharedDefaults = UserDefaults(suiteName: "group.amethyst-facet.xcode")
        sharedDefaults?.set(fileContents, forKey: "rawCode")
        
        // 3. Open companion app via URL Scheme
        let url = URL(string: "amethyst-facet://open")!
        NSWorkspace.shared.open(url)
        
        completionHandler(nil)
    }
    
}
