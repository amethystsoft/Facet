import SwiftUI
import HighlightSwift
import DebouncedOnChange

struct ContentView: View {
    @AppStorage("rawCode", store: UserDefaults(suiteName: "group.amethyst-facet.xcode")) var code: String?
    @State var uiError: String?
    @State var attributedCode: AttributedString?
    @State var pattern: String = #"\s*(\w+)\.self"#
    @State var replacement: String = ""
    var body: some View {
        VStack {
            if let uiError {
                ScrollView {
                    Text(uiError.description)
                }
            }
            if let code {
                Button("Prepare for pasting") {
                    UserDefaults(suiteName: "group.amethyst-facet.xcode")?.set("Lol", forKey: "updatedCode")
                }
                TextField("Pattern", text: $pattern)
                TextField("Replacement", text: $replacement)
                ScrollView {
                    HStack {
                        Text(attributedCode ?? "")
                            .font(.system(size: 13).monospaced())
                            .frame(minWidth: 100, alignment: .leading)
                        Divider()
                        CodeText(editedCode(code))
                            .frame(minWidth: 100, alignment: .leading)
                    }
                }
            } else {
                ContentUnavailableView("No code", image: "xmark")
            }
        }
        .padding()
        .onChange(of: code, initial: true) {
            Task {
                guard let code else { return }
                attributedCode = await regexHighlightedString(code)
            }
        }
        .onChange(of: pattern, debounceTime: .milliseconds(300)) {
            Task {
                guard let code else { return }
                attributedCode = await regexHighlightedString(code)
            }
        }
    }
    
    func editedCode(_ code: String) -> String {
        code
    }
    
    func regexHighlightedString(_ code: String) async -> AttributedString? {
        do {
            var attributedText = try await Highlight().attributedText(code, colors: .dark(.xcode))
            attributedText.overlayRegexMatches(pattern: pattern)
            return attributedText
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}

#Preview {
    ContentView()
}

extension AttributedString {
    /// Overlays alternating background highlights for regex matches and capture groups.
    mutating func overlayRegexMatches(
        pattern: String,
        groupColors: [Color] = [
            .gray.opacity(0.15),   // Full match
            .green.opacity(0.25),  // Capture 1
            .yellow.opacity(0.25), // Capture 2
            .purple.opacity(0.25)  // Capture 3
        ]
    ) {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        ) else { return }
        
        let nsString = String(self.characters) as NSString
        let matches = regex.matches(
            in: String(self.characters),
            options: [],
            range: NSRange(location: 0, length: nsString.length)
        )
        
        for match in matches {
            // Apply distinct colors to each capture group range
            for groupIndex in 0..<match.numberOfRanges {
                let nsRange = match.range(at: groupIndex)
                guard nsRange.location != NSNotFound,
                      let range = Range(nsRange, in: self) else { continue }
                
                let color = groupColors[groupIndex % groupColors.count]
                self[range].backgroundColor = color
            }
        }
    }
}
