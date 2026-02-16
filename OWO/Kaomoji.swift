//
//  Kaomoji.swift
//  OWO
//
//  Created by Katherine Palevich on 2/12/26.
//

import Foundation
import FoundationModels

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
    
    @Guide(description: "The explanation for what the kaomoji is supposed to convey")
    let description: String
}
