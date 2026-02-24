//
//  Kaomoji.swift
//  OWO
//
//  Created by Katherine Palevich on 2/12/26.
//

import Foundation
import FoundationModels

@Generable
enum Sentiment: String, CaseIterable, Equatable {
    case anger
    case joy
    case jealousy
    case sadness
    case confusion
    case fear
}

@Generable
struct KaomojiList: Equatable {
    @Guide(description: "A list of kaomojis")
    @Guide(.count(5))
    let kaomojis: [Kaomoji]
}

@Generable
struct Kaomoji: Equatable {
    @Guide(description: "The string version of the kaomoji")
    let text: String
    
    @Guide(description: "The explanation for what the kaomoji is supposed to convey. Limit length to around 10 words")
    let description: String

    @Guide(description: "The sentiment of the kaomoji")
    let sentiment: Sentiment
}
