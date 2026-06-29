import SwiftUI
import HighlightSwift
import DebouncedOnChange

struct ContentView: View {
    @AppStorage("rawCode", store: UserDefaults(suiteName: "group.amethyst-facet.xcode")) var code: String?
    @AppStorage("codeLanguage", store: UserDefaults(suiteName: "group.amethyst-facet.xcode")) var language: String?
    @State var uiError: String?
    @State var attributedCode: AttributedString?
    @State var attributedReplacement: AttributedString?
    @State var pattern: String = ""
    @State var replacement: String = ""
    @State var updateTask: Task<Void, Never>?
    @State var showCopiedInfo: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            if let uiError {
                ScrollView {
                    Text(uiError.description)
                }
            }
            if code != nil {
                HStack {
                    Button("Copy ⌘⏎") {
                        guard let attributedReplacement else { return }
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(String(attributedReplacement.characters), forType: .string)
                        showCopiedInfo = true
                        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { timer in
                            withAnimation {
                                showCopiedInfo = false
                            }
                            timer.invalidate()
                        }
                    }
                    .keyboardShortcut(.init(.return, modifiers: .command))
                    Button("Copy and close ⌘⇧⏎") {
                        guard let attributedReplacement else { return }
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(String(attributedReplacement.characters), forType: .string)
                        dismiss()
                    }
                    .keyboardShortcut(.init(.return, modifiers: [.command, .shift]))
                Spacer()
                    
                    Link("GitHub", destination: URL(string: "https://github.com/amethystsoft/Facet")!)
                        .buttonStyle(.bordered)
                    Link("Feedback & Feature Requests", destination: URL(string: "https://amethystfacet.featurebase.app")!)
                    .buttonStyle(.bordered)
                }
                HStack {
                    Text("Replacement")
                        .hidden()
                        .overlay(alignment: .leading) {
                            Text("Pattern")
                        }
                    
                    TextField("Regular Expression", text: $pattern)
                }
                HStack {
                    Text("Replacement")
                    TextField("... use $1, $2, etc. for capture groups", text: $replacement)
                }
                ScrollView {
                    HStack {
                        Text(attributedCode ?? "")
                            .textSelection(.enabled)
                            .font(.system(size: 13).monospaced())
                            .frame(minWidth: 100, alignment: .leading)
                        Spacer()
                        Divider()
                        Text(attributedReplacement ?? "")
                            .textSelection(.enabled)
                            .font(.system(size: 13).monospaced())
                            .frame(minWidth: 100, alignment: .leading)
                        Spacer()
                    }
                    .padding(.bottom)
                }
            } else {
                ContentUnavailableView("No code", image: "xmark")
            }
        }
        .padding(.horizontal)
        .overlay {
            if showCopiedInfo {
                Text("Copied to clipboard")
                    .font(.largeTitle)
                    .padding(30)
                    .glassEffect()
                    .transition(.opacity)
            }
        }
        .onChange(of: code, initial: true) {
            updateText()
        }
        .onChange(of: colorScheme) {
            updateText()
        }
        .onChange(of: pattern, debounceTime: .milliseconds(500)) {
            updateText()
        }
        .onChange(of: replacement, debounceTime: .milliseconds(500)) {
            updateText()
        }
    }
    
    func updateText() {
        updateTask?.cancel()
        updateTask = Task {
            guard let code else { return }
            async let attrCode = await regexHighlightedString(code)
            async let attrReplacement = await regexEditedString(code)
            attributedCode = await attrCode
            attributedReplacement = await attrReplacement
        }
    }
    
    func regexEditedString(_ code: String) async -> AttributedString? {
        do {
            let highlightColor = Color.yellow.opacity(0.2)
            
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return try await Highlight().attributedText(
                    code,
                    language: .init(rawValue: language ?? "swift") ?? HighlightLanguage.swift,
                    colors: colorScheme == .dark ? .dark(.xcode) : .light(.xcode)
                )
            }
            
            let matches = regex.matches(
                in: code,
                options: [],
                range: NSRange(location: 0, length: code.utf16.count)
            )
            
            var workingString = code
            var accumulatedOffset = 0
            var finalNSRanges: [NSRange] = []
            
            // Process replacements on raw String (moving forward)
            for match in matches {
                let replacement = regex.replacementString(
                    for: match,
                    in: code,
                    offset: 0,
                    template: replacement
                )
                
                let currentLoc = match.range.location + accumulatedOffset
                let currentLen = match.range.length
                
                // Map UTF-16 offsets of regular expression to Character indices.
                let startUTF16 = workingString.utf16.index(
                    workingString.utf16.startIndex,
                    offsetBy: currentLoc
                )
                let endUTF16 = workingString.utf16.index(
                    startUTF16,
                    offsetBy: currentLen
                )
                
                guard
                    let startIdx = String.Index(startUTF16, within: workingString),
                    let endIdx = String.Index(endUTF16, within: workingString)
                else { continue }
                
                workingString.replaceSubrange(startIdx..<endIdx, with: replacement)
                
                // Record where the new string range landed in the final output.
                let newRange = NSRange(
                    location: currentLoc,
                    length: replacement.utf16.count
                )
                finalNSRanges.append(newRange)
                
                // Shift the tracking offset by the delta of replacement vs target length.
                accumulatedOffset += (replacement.utf16.count - currentLen)
            }
            
            // Syntax-highlight the entire finished string.
            var finalAttributedString = try await Highlight().attributedText(
                workingString,
                language: .init(rawValue: language ?? "swift") ?? HighlightLanguage.swift,
                colors: colorScheme == .dark ? .dark(.xcode) : .light(.xcode)
            )
            
            // Apply the background highlights to the tracked ranges.
            for nsRange in finalNSRanges {
                guard
                    let stringRange = Range(nsRange, in: workingString),
                    let startIdx = AttributedString.Index(
                        stringRange.lowerBound,
                        within: finalAttributedString
                    ),
                    let endIdx = AttributedString.Index(
                        stringRange.upperBound,
                        within: finalAttributedString
                    )
                else { continue }
                
                finalAttributedString[startIdx..<endIdx].backgroundColor =
                highlightColor
            }
            
            return finalAttributedString
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func regexHighlightedString(_ code: String) async -> AttributedString? {
        do {
            var attributedString = try await Highlight().attributedText(
                code,
                language: .init(rawValue: language ?? "swift") ?? HighlightLanguage.swift,
                colors: colorScheme == .dark ? .dark(.xcode): .light(.xcode)
            )
            attributedString.overlayRegexMatches(pattern: pattern)
            return attributedString
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
