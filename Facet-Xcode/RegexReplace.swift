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
    private static let utiToLanguageMap: [String: String] = [
        // Compiled Languages
        "public.swift-source": "Swift",
        "public.objective-c-source": "Objective-C",
        "public.objective-c-plus-plus-source": "Objective-C++",
        "public.c-source": "C",
        "public.c-plus-plus-source": "C++",
        "public.c-header": "C Header",
        "public.c-plus-plus-header": "C++ Header",
        "public.java-source": "Java",
        "public.assembly-source": "Assembly",
        "com.sun.java-web-archive": "JSP",
        
        // Scripts & Web
        "com.netscape.javascript-source": "JavaScript",
        "public.python-script": "Python",
        "public.ruby-script": "Ruby",
        "public.php-script": "PHP",
        "public.perl-script": "Perl",
        "public.shell-script": "Shell Script",
        "com.apple.applescript.text": "AppleScript",
        "public.css": "CSS",
        
        // Data & Markup
        "public.html": "HTML",
        "public.xml": "XML",
        "public.json": "JSON",
        "public.yaml": "YAML",
        "public.make-script": "Makefile",
        "public.to-do-list": "Task Paper",
        
        // Common 3rd party or newer formats often found in modern IDEs
        "org.rust-lang.rust-source": "Rust",
        "org.go-lang.go-source": "Go",
        "com.microsoft.typescript": "TypeScript",
        "org.kotlin-lang.kotlin-source": "Kotlin",
        "com.visualstudio.csharp-source": "C#"
    ]
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let uti = invocation.buffer.contentUTI
        
        let sharedDefaults = UserDefaults(suiteName: "group.amethyst-facet.xcode")
        if let language = RegexReplace.utiToLanguageMap[uti] {
            sharedDefaults?.set(language, forKey: "codeLanguage")
        }
        
        let fileContents = invocation.buffer.completeBuffer
        
        sharedDefaults?.set(fileContents, forKey: "rawCode")
        
        let url = URL(string: "amethyst-facet://open")!
        NSWorkspace.shared.open(url)
        
        completionHandler(nil)
    }
    
}
