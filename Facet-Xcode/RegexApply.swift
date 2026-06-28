//
//  SourceEditorCommand.swift
//  Facet-Xcode
//
//  Created by Mia Koring on 28.06.26.
//

import Foundation
import AppKit
import XcodeKit

class RegexApply: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let sharedDefaults = UserDefaults(suiteName: "group.amethyst-facet.xcode")
        if let updatedCode = sharedDefaults?.string(forKey: "updatedCode") {
            // Overwrite Xcode's editor buffer directly
            invocation.buffer.completeBuffer = updatedCode
        } else { print("failed ")}
        
        completionHandler(nil)
    }
    
}
