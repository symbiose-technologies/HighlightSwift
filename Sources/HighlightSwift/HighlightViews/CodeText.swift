import SwiftUI


public struct CodeText: View {
    @Environment(\.colorScheme)
    var colorScheme
    
    @State
    var highlightTask: Task<Void, Never>?
    
    @State
    var highlightResult: HighlightResult?
    
    let text: String
    let language: String?
    let styleName: HighlightStyle.Name
    let onHighlight: ((HighlightResult) -> Void)?
    
    var highlightStyle: HighlightStyle {
        HighlightStyle(
            name: styleName,
            colorScheme: colorScheme
        )
    }
    let ancestorProvidedColorScheme: ColorScheme?

    /// Creates a text view that displays syntax highlighted code.
    /// - Parameters:
    ///   - text: The plain text code to highlight.
    ///   - language: The language to use (default: automatic).
    ///   - style: The highlight style name to use (default: .xcode).
    ///   - onHighlight: Callback with the result of each highlight attempt (default: nil).
    public init(_ text: String,
                language: String? = nil,
                style styleName: HighlightStyle.Name = .xcode,
                ancestorProvidedColorScheme: ColorScheme? = nil,
                cachedHighlightRes: HighlightResult? = nil,
                onHighlight: ((HighlightResult) -> Void)? = nil
            ) {
        self.text = text
        self.language = language
        self.styleName = styleName
        self.onHighlight = onHighlight
        
        self.ancestorProvidedColorScheme = ancestorProvidedColorScheme
        
        if let cached = cachedHighlightRes {
            self._highlightResult = .init(wrappedValue: cached)
        } else {
            self._highlightResult = .init(wrappedValue: nil)

//            let initialHighlightStyle = HighlightStyle(name: styleName, colorScheme: ancestorProvidedColorScheme ?? .light)
//            if let cached = HighlightCache.shared.getCachedFor(text, language: language, style: initialHighlightStyle) {
//                self._highlightResult = .init(wrappedValue: cached)
////                onHighlight?(cached)
//                DispatchQueue.main.async { [cached, onHighlight] in
//                    onHighlight?(cached)
//                }
//                
//            }
        }
        
    }
    
    public var body: some View {
        highlightedText
            .task(priority: .low) {
                if
                    highlightTask == nil,
                    highlightResult == nil {
                    await highlightText()
                }
            }
//            .onAppear {
//                if
//                    highlightTask == nil,
//                    highlightResult == nil {
//                    highlightText()
//                }
//            }
            .onChange(of: styleName) { newStyleName in
                highlightText(styleName: newStyleName)
            }
            .onChange(of: colorScheme) { newColorScheme in
                highlightResult = nil
                highlightText(colorScheme: newColorScheme)
            }
    }
    
    
    private var highlightedText: Text {
        if let highlightResult {
            return Text(highlightResult.text)
        } else {
            return Text(text)
        }
    }
        
    private func highlightText(styleName: HighlightStyle.Name? = nil,
                               colorScheme: ColorScheme? = nil) {
        print("HighlightText sync called")
        
        let highlightStyle = HighlightStyle(
            name: styleName ?? self.styleName,
            colorScheme: colorScheme ?? self.colorScheme
        )
        highlightTask?.cancel()
        highlightTask = Task(priority: .low) {
            await highlightText(highlightStyle)
        }
    }
    
    private func highlightText(_ style: HighlightStyle? = nil) async {
//        print("HighlightText async called")
        do {
            let result = try await HighlightCache.shared.get(
                text,
                language: language,
                style: style ?? highlightStyle
            )
            await handleHighlightResult(result)
            
        } catch {
            print(error)
        }
    }
    
    @MainActor
    private func handleHighlightResult(_ result: HighlightResult) {
        onHighlight?(result)
        if highlightResult == nil {
            highlightResult = result
        } else {
            withAnimation {
                print("[HighlightSwift] highlightResult set WITH ANIMATION")
                highlightResult = result
            }
        }
    }
}

@available(iOS 16.1, *)
@available(tvOS 16.1, *)
struct CodeText_Previews: PreviewProvider {
    static let code: String = """
    import SwiftUI

    struct SwiftUIView: View {
        var body: some View {
            Text("Hello World!")
        }
    }

    struct SwiftUIView_Previews: PreviewProvider {
        static var previews: some View {
            SwiftUIView()
        }
    }
    """
    
    static var previews: some View {
        CodeText(code)
            .padding()
            .font(.caption2)
    }
}
