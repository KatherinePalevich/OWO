//
//  SentimentTool.swift
//  OWO
//
//  Created by Katherine Palevich on 2/23/26.
//

import Foundation
import FoundationModels
import NaturalLanguage

struct SentimentTool: Tool {
    let name = "get_sentiment_score"
    let description = "Analyzes the sentiment of a given text and returns a score between -1.0 (very negative) and 1.0 (very positive). Use this to verify the emotional tone of the input text."

    @Generable
    struct Arguments {
        @Guide(description: "The text to analyze for sentiment.")
        let text: String
    }

    func call(arguments: Arguments) async throws -> String {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = arguments.text
        let (sentiment, _) = tagger.tag(at: arguments.text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        let score = sentiment?.rawValue ?? "0.0"
        print("SentimentTool called for text: \"\(arguments.text)\" - Resulting score: \(score)")
        return score
    }
}
