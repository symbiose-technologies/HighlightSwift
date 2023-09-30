//////////////////////////////////////////////////////////////////////////////////
//
//  SYMBIOSE
//  Copyright 2023 Symbiose Technologies, Inc
//  All Rights Reserved.
//
//  NOTICE: This software is proprietary information.
//  Unauthorized use is prohibited.
//
// 
// Created by: Ryan Mckinney on 6/14/23
//
////////////////////////////////////////////////////////////////////////////////

import Foundation
import LRUCache

public struct HighlightTextParams: Hashable {
    
    public var text: String
    public var language: String?
    public var ignoreIllegals: Bool?
    public var style: HighlightStyle
    
    public init(text: String,
                language: String? = nil,
                ignoreIllegals: Bool? = nil,
                style: HighlightStyle = .dark(.xcode)) {
        self.text = text
        self.language = language
        self.ignoreIllegals = ignoreIllegals
        self.style = style
    }
    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(text)
//        hasher.combine(language)
//        hasher.combine(ignoreIllegals)
//        hasher.combine(style)
//    }
    
    public static func == (lhs: HighlightTextParams, rhs: HighlightTextParams) -> Bool {
        return lhs.text == rhs.text &&
            lhs.language == rhs.language &&
            lhs.ignoreIllegals == rhs.ignoreIllegals &&
            lhs.style == rhs.style
    }
    
}

public class HighlightCache {
    
    public static var shared = HighlightCache()
    
    private let cache: LRUCache<HighlightTextParams, HighlightResult>
    
    public init() {
        self.cache = .init(countLimit: 500)
    }
    
    public func getCachedFor(_ params: HighlightTextParams) -> HighlightResult? {
        if let cached = cache.value(forKey: params) {
//            print("HighlightCache: Found cached result!")
            return cached
        }
        return nil
    }
    public func getCachedFor(_ text: String,
                              language: String? = nil,
                              ignoreIllegals: Bool? = nil,
                             style: HighlightStyle) -> HighlightResult? {
        let params = HighlightTextParams(text: text, language: language, ignoreIllegals: ignoreIllegals, style: style)
        return self.getCachedFor(params)
    }
    
    func get(_ text: String,
                            language: String? = nil,
                            ignoreIllegals: Bool? = nil,
              style: HighlightStyle = .dark(.xcode)) async throws -> HighlightResult {
        let params = HighlightTextParams(text: text, language: language, ignoreIllegals: ignoreIllegals, style: style)
        if let cached = self.getCachedFor(params) {
            return cached
        } else {
            let result = try await Highlight.text(text, language: language, ignoreIllegals: ignoreIllegals, style: style)
            
            self.cache.setValue(result, forKey: params)
            return result
        }
        
    }
    
    
    
    
}

