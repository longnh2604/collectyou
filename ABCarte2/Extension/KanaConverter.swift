//
//  KanaConverter.swift
//  ABCarte2
//
//  Created by Oluxe on 2020/05/18.
//  Copyright © 2020 Oluxe. All rights reserved.
//

import Foundation

private extension CFStringTokenizer {
    var hiragana: String { string(to: kCFStringTransformLatinHiragana) }
    var katakana: String { string(to: kCFStringTransformLatinKatakana) }

    private func string(to transform: CFString) -> String {
        var output: String = ""
        while !CFStringTokenizerAdvanceToNextToken(self).isEmpty {
            output.append(letter(to: transform))
        }
        return output
    }

    private func letter(to transform: CFString) -> String {
        let mutableString: NSMutableString =
            CFStringTokenizerCopyCurrentTokenAttribute(self, kCFStringTokenizerAttributeLatinTranscription)
                .flatMap { $0 as? NSString }
                .map { $0.mutableCopy() }
                .flatMap { $0 as? NSMutableString } ?? NSMutableString()
        CFStringTransform(mutableString, nil, transform, false)
        return mutableString as String
    }
}

enum Kana { case hiragana, katakana }

func convert(_ input: String, to kana: Kana) -> String {
    let trimmed: String = input.trimmingCharacters(in: .whitespacesAndNewlines)
    let tokenizer: CFStringTokenizer =
        CFStringTokenizerCreate(kCFAllocatorDefault,
                                trimmed as CFString,
                                CFRangeMake(0, trimmed.utf16.count),
                                kCFStringTokenizerUnitWordBoundary,
                                Locale(identifier: "ja") as CFLocale)
    switch kana {
    case .hiragana: return tokenizer.hiragana
    case .katakana: return tokenizer.katakana
    }
}

extension String {
    var hiragana: String { convert(self, to: .hiragana) }
    var katakana: String { convert(self, to: .katakana) }
}
