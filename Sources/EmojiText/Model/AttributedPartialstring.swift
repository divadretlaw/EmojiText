//
//  AttributedPartialstring.swift
//  EmojiText
//
//  Created by David Walter on 26.12.23.
//

import SwiftUI

struct AttributedPartialstring: AttributedStringProtocol, Sendable {
    fileprivate var substrings: [AttributedSubstring]
    
    init() {
        self.substrings = []
    }
    
    mutating func append(_ substring: AttributedSubstring) {
        substrings.append(substring)
    }
    
    mutating func consume() -> [AttributedSubstring] {
        defer {
            self.substrings = []
        }
        return self.substrings
    }
    
    // MARK: - AttributedStringProtocol
    
    var startIndex: AttributedString.Index {
        AttributedString(self).startIndex
    }
    
    var endIndex: AttributedString.Index {
        AttributedString(self).endIndex
    }
    
    var runs: AttributedString.Runs {
        AttributedString(self).runs
    }
    
    var characters: AttributedString.CharacterView {
        AttributedString(self).characters
    }
    
    var unicodeScalars: AttributedString.UnicodeScalarView {
        AttributedString(self).unicodeScalars
    }
    
    subscript<K>(_ value: K.Type) -> K.Value? where K: AttributedStringKey, K.Value: Sendable {
        get {
            AttributedString(self)[value]
        }
        set {
            substrings = substrings.map { substring in
                var substring = substring
                substring[value] = newValue
                return substring
            }
        }
    }
    
    subscript<K>(dynamicMember keyPath: KeyPath<AttributeDynamicLookup, K>) -> K.Value? where K: AttributedStringKey, K.Value: Sendable {
        get {
            AttributedString(self)[dynamicMember: keyPath]
        }
        set {
            substrings = substrings.map { substring in
                var substring = substring
                substring[dynamicMember: keyPath] = newValue
                return substring
            }
        }
    }
    
    subscript<S>(dynamicMember keyPath: KeyPath<AttributeScopes, S.Type>) -> ScopedAttributeContainer<S> where S: AttributeScope {
        get {
            AttributedString(self)[dynamicMember: keyPath]
        }
        set {
            substrings = substrings.map { substring in
                var substring = substring
                substring[dynamicMember: keyPath] = newValue
                return substring
            }
        }
    }
    
    subscript<R>(bounds: R) -> AttributedSubstring where R: RangeExpression, R.Bound == AttributedString.Index {
        AttributedString(self)[bounds]
    }
    
    mutating func setAttributes(_ attributes: AttributeContainer) {
        substrings = substrings.map { substring in
            var substring = substring
            substring.setAttributes(attributes)
            return substring
        }
    }
    
    mutating func mergeAttributes(_ attributes: AttributeContainer, mergePolicy: AttributedString.AttributeMergePolicy) {
        substrings = substrings.map { substring in
            var substring = substring
            substring.mergeAttributes(attributes, mergePolicy: mergePolicy)
            return substring
        }
    }
    
    mutating func replaceAttributes(_ attributes: AttributeContainer, with others: AttributeContainer) {
        substrings = substrings.map { substring in
            var substring = substring
            substring.replaceAttributes(attributes, with: others)
            return substring
        }
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        AttributedString(self).description
    }
}

private extension AttributedString {
    init(_ value: AttributedPartialstring) {
        self = value.substrings.reduce(AttributedString()) { partialResult, substring in
            partialResult + substring
        }
    }
}
