import SwiftUI


public struct CodeCardConfig {
    
    public var fontSize: CGFloat
    public var applyFontStyle: Bool
    public var displayTopBar: Bool
    public var style: HighlightStyle.Name
    public var horizontalScroll: Bool
    
    public var font: Font {
        Font.system(size: fontSize, design: .monospaced)
    }
    public func fontForSize(_ size: CGFloat) -> Font {
        return Font.system(size: size, design: .monospaced)
    }
    
    public init(
        fontSize: CGFloat = 16,
        applyFontStyle: Bool = true,
        displayTopBar: Bool = true,
        style: HighlightStyle.Name = .stackoverflow,
        horizontalScroll: Bool = true
    ) {
        self.fontSize = fontSize
        self.applyFontStyle = applyFontStyle
        self.displayTopBar = displayTopBar
        self.style = style
        self.horizontalScroll = horizontalScroll
    }
    
    public static func defaultConfig() -> CodeCardConfig {
        #if os(iOS)
        CodeCardConfig(fontSize: 14,
                       horizontalScroll: true)
        #else
        CodeCardConfig(horizontalScroll: false)
        #endif
    }
    
}


public struct CodeCard: View {
    @Environment(\.colorScheme)
    var colorScheme
    
    @State
    var styleName: HighlightStyle.Name
    
    @State
    var font: Font
    
    @State
    var fontSize: CGFloat
    
    @State
    var lineHorizontalWrap: Bool
    
    @State
    var showStyleControls: Bool = false
    
    @State
    var highlightResult: HighlightResult?
    
    let text: String
    
    var initialStyleName: HighlightStyle.Name { config.style }
    
    var applyTextStyle: Bool { config.applyFontStyle }
    
    
    let config: CodeCardConfig
    
    var codeLanguage: String? {
        highlightResult?.language
    }
    
    
    /// Creates a card view that displays syntax highlighted code.
    /// - Parameters:
    ///   - text: The plain text code to highlight.
    ///   - style: The initial highlight color style (default: .xcode).
    ///   - textStyle: The initial font text style (default: .caption2).
    public init(_ text: String,
                config: CodeCardConfig = .defaultConfig()
    ) {
        self.text = text
        
        self.config = config
        
        self._styleName = State(initialValue: config.style)
        self._font = State(initialValue: config.font)
        self._fontSize = State(initialValue: config.fontSize)
        self._lineHorizontalWrap = State(initialValue: !config.horizontalScroll)
        
//        let initialHighlightStyle = HighlightStyle(name: styleName, colorScheme: .light)
//        if let cached = HighlightCache.shared.getCachedFor(text, language: nil, style: initialHighlightStyle) {
//            self._highlightResult = .init(wrappedValue: cached)
//        }
        
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if config.displayTopBar {
                topBarView
            }
            
            contentView
                .padding(12)
        }
        .background {
            ZStack {
                if let highlightResult {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(highlightResult.backgroundColor)
                }
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.thinMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onChange(of: colorScheme) { newValue in
            self.highlightResult = nil
        }
    }
    
    public var topBarView: some View {
        HStack {
            if let highlightResult {
                languageNameTopBar(highlightResult)
            }
            Spacer()
            
            copyButton
            
            styleControlsGroup
        }
        .buttonStyle(.borderless)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .background(
            Material.ultraThick
        )
    }
    
    
    public var contentView: some View  {
        ZStack(alignment: .topTrailing) {
            Color
                .clear
                .contentShape(Rectangle())
                .onTapGesture(count: 2, perform: resetStyle)
                .onTapGesture(perform: toggleShowButtons)
            
            if lineHorizontalWrap {
                textContent
            } else {
                ScrollView(.horizontal) {
                    textContent
                }
            }
            
            if !config.displayTopBar {
                VStack(alignment: .trailing) {
                    if showStyleControls {
                        styleControls
                    }
                    Spacer(minLength: 12)
                    if let highlightResult {
                        languageName(highlightResult)
                    }
                }
            }
        }
    }
    
    
    public var textContent: some View {
        HStack {
            if applyTextStyle {
                codeTextWithFont
            } else {
                codeTextWithFont
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2, perform: resetStyle)
        .onTapGesture(perform: toggleShowButtons)
    }
    
    public var codeTextNoFont: some View {
        CodeText(text, 
                 style: styleName,
                 ancestorProvidedColorScheme: colorScheme,
                 cachedHighlightRes: self.highlightResult) { highlightResult in
            withAnimation {
                self.highlightResult = highlightResult
            }
        }
        .textSelection(.enabled)

    }
    
    public var codeTextWithFont: some View {
        CodeText(text,
                 style: styleName,
                 ancestorProvidedColorScheme: colorScheme,
                 onHighlight: self.handleReceivedHighlightResult)
        
//        CodeText(text,
//                 style: styleName,
//                 ancestorProvidedColorScheme: colorScheme) { highlightResult in
//            self.highlightResult = highlightResult
////            withAnimation {
////                self.highlightResult = highlightResult
////            }
//        }
        .font(self.font)
        .textSelection(.enabled)
    }
    
    
    func handleReceivedHighlightResult(_ highlightResult: HighlightResult) {
        self.highlightResult = highlightResult
    }
    
    
    
    // MARK: - Actions
    
    func resetStyle() {
        withAnimation {
            showStyleControls = false
            font = config.font
            styleName = initialStyleName
        }
    }
    
    func toggleShowButtons() {
        withAnimation {
            showStyleControls.toggle()
        }
    }
    
    func toggleFontSize() {
        withAnimation {
            fontSize += 1
            if fontSize > 20 {
                fontSize = 12
            }
            font = config.fontForSize(fontSize)
        }
    }
    
    
//    func toggleFontTextStyle() {
//        withAnimation {
//            switch textStyle {
//            case .body:
//                let font = Font.system(.caption, design: .monospaced)
//                textStyle = .caption2
//            case .callout:
//                textStyle = .body
//            case .footnote:
//                textStyle = .callout
//            case .caption:
//                textStyle = .footnote
//            case .caption2:
//                textStyle = .caption
//            default:
//                textStyle = .caption2
//            }
//        }
//    }
    
    
    
    
    
    // MARK: - Views
    
    
    
    var styleControls: some View {
        VStack(spacing: 12) {
            styleControlsGroup
        }
    }
    
    @ViewBuilder
    var styleControlsGroup: some View {
        if #available(iOS 16, macOS 13, *) {
            styleControlsGroupBase
                .menuStyle(.button)
        } else {
            styleControlsGroupBase
        }
    }
    
    
    var styleControlsGroupBase: some View {
        Group {
            Button(action: toggleFontSize) {
                systemImage("textformat.size", withBackground: !config.displayTopBar)
            }
            
            Menu {
                //add a toggle for the horizontal scroll
                Toggle("Wrap Lines", isOn: $lineHorizontalWrap)
                
                
                Picker("Style", selection: $styleName) {
                    ForEach(HighlightStyle.Name.allCases) { styleName in
                        Text(styleName.rawValue)
                            .tag(styleName)
                    }
                }
            } label: {
                systemImage("paintpalette")
            }
        }
    }
    
    
    @State private var isCopied = false
    var copyButton: some View {
        Button(action: {
//            let success = text.copyToClipboard()
            let success = text.copyAsMarkdownCodeBlockToClipboard(self.codeLanguage)
            if success {
                withAnimation { isCopied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isCopied = false
                    }
                }
            }
        }) {
            #if os(macOS)
            Label(isCopied ? "Copied!" : "Copy Code", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                .font(.callout)
                .foregroundColor(isCopied ? .green : .secondary)
                .frame(height: 34)
            #else
            systemImage(isCopied ? "checkmark" : "doc.on.doc",
                        withBackground: true,
                        foregroundColor: isCopied ? .green : .secondary
            )
            #endif
        }
    }
    
    
    
    func systemImage(_ systemName: String,
                     withBackground: Bool = true,
                     foregroundColor: Color = Color.secondary) -> some View {
        Text("\(Image(systemName: systemName))")
            .font(.callout)
            .foregroundColor(foregroundColor)
            .frame(width: 34, height: 34)
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
            }
    }
    
    func languageNameTopBar(_ result: HighlightResult) -> some View {
        Text(result.languageName)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
//            .background {
//                Capsule()
//                    .fill(.ultraThinMaterial)
//            }
    }
    
    
    
    func languageName(_ result: HighlightResult) -> some View {
        Text(result.languageName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
            }
    }
}

@available(iOS 16.1, *)
struct CodeCard_Previews: PreviewProvider {
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
        ScrollView {
            CodeCard(code)
                .padding()
        }
    }
}
